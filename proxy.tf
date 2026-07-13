# RDS Proxy — Lambdas connect here (never the cluster endpoint) so per-execution
# connection pools are multiplexed. It authenticates to the cluster with the
# AWS-managed master-password secret.
data "aws_iam_policy_document" "proxy_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "proxy" {
  name               = "${local.name}-rds-proxy"
  assume_role_policy = data.aws_iam_policy_document.proxy_assume.json

  lifecycle {
    ignore_changes = [tags]
  }
}

data "aws_iam_policy_document" "proxy_secret" {
  statement {
    sid       = "GetSecretValue"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_rds_cluster.main.master_user_secret[0].secret_arn]
  }

  statement {
    sid       = "DecryptViaSecretsManager"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.current.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "proxy_secret" {
  name   = "${local.name}-rds-proxy-secret"
  role   = aws_iam_role.proxy.id
  policy = data.aws_iam_policy_document.proxy_secret.json
}

resource "aws_db_proxy" "main" {
  name                   = "${local.name}-rds"
  engine_family          = "POSTGRESQL"
  role_arn               = aws_iam_role.proxy.arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = [aws_security_group.proxy.id]
  require_tls            = true

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_rds_cluster.main.master_user_secret[0].secret_arn
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "main" {
  db_proxy_name         = aws_db_proxy.main.name
  target_group_name     = aws_db_proxy_default_target_group.main.name
  db_cluster_identifier = aws_rds_cluster.main.cluster_identifier

  # Register the target only once the cluster has an available instance,
  # otherwise the proxy target can be created before the instance and fail.
  depends_on = [aws_rds_cluster_instance.main]
}
