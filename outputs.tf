output "proxy_endpoint" {
  description = "RDS Proxy endpoint. Clients (Lambdas) connect here, never the cluster endpoint."
  value       = aws_db_proxy.main.endpoint
}

output "writer_endpoint" {
  description = "Aurora cluster writer endpoint."
  value       = aws_rds_cluster.main.endpoint
}

output "reader_endpoint" {
  description = "Aurora cluster reader endpoint (heavy report queries)."
  value       = aws_rds_cluster.main.reader_endpoint
}

output "port" {
  description = "Database port."
  value       = aws_rds_cluster.main.port
}

output "database_name" {
  description = "Initial database name."
  value       = aws_rds_cluster.main.database_name
}

output "master_secret_arn" {
  description = "ARN of the AWS-managed master-password Secrets Manager secret."
  value       = try(aws_rds_cluster.main.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "Security group ID of the RDS Proxy (add ingress rules against this)."
  value       = aws_security_group.proxy.id
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster."
  value       = aws_rds_cluster.main.arn
}
