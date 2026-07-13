locals {
  name = "${var.application_name}-${var.environment}"
}

# RDS Proxy security group — the endpoint the Lambdas connect to. Ingress on
# 5432 comes only from the allowed (app) security groups.
resource "aws_security_group" "proxy" {
  name        = "${local.name}-rds-proxy"
  description = "RDS Proxy: ingress 5432 from allowed app security groups."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-rds-proxy" }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_security_group_rule" "proxy_ingress" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.proxy.id
  source_security_group_id = var.allowed_security_group_ids[count.index]
  description              = "Postgres from an allowed app security group."
}

# Aurora cluster security group — reachable only from the RDS Proxy.
resource "aws_security_group" "cluster" {
  name        = "${local.name}-rds-cluster"
  description = "Aurora cluster: ingress 5432 from the RDS Proxy only."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-rds-cluster" }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_security_group_rule" "cluster_ingress_from_proxy" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.proxy.id
  description              = "Postgres from the RDS Proxy."
}
