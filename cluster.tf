resource "aws_db_subnet_group" "main" {
  name       = "${local.name}-rds"
  subnet_ids = var.subnet_ids

  tags = { Name = "${local.name}-rds" }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Aurora PostgreSQL Serverless v2: engine_mode "provisioned" + a
# serverlessv2_scaling_configuration on a db.serverless instance.
resource "aws_rds_cluster" "main" {
  cluster_identifier = "${local.name}-rds"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username

  manage_master_user_password = var.manage_master_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.cluster.id]

  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity_acu
    max_capacity = var.max_capacity_acu
  }

  storage_encrypted       = true
  backup_retention_period = var.backup_retention_days
  deletion_protection     = var.deletion_protection

  skip_final_snapshot       = var.environment != "production"
  final_snapshot_identifier = var.environment == "production" ? "${local.name}-rds-final" : null

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_rds_cluster_instance" "main" {
  identifier           = "${local.name}-rds-1"
  cluster_identifier   = aws_rds_cluster.main.id
  instance_class       = "db.serverless"
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_subnet_group_name = aws_db_subnet_group.main.name

  lifecycle {
    ignore_changes = [tags]
  }
}
