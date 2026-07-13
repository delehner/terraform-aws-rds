# Changelog

## v1.0.0

### Added
- Initial RDS module: Aurora PostgreSQL Serverless v2 cluster + `db.serverless` instance, an RDS Proxy in front (managed-secret auth + IAM role), an AWS-managed master-password secret, and proxy/cluster security groups (Lambdas → proxy → cluster). Outputs `proxy_endpoint`, `writer_endpoint`, `reader_endpoint`, `port`, `database_name`, `master_secret_arn`, `security_group_id`, `cluster_arn`.
