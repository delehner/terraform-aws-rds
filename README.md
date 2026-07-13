# Terraform - RDS Module

Aurora PostgreSQL **Serverless v2** with an **RDS Proxy** in front and an
AWS-managed master-password secret. Clients (e.g. Lambdas) connect to the RDS
Proxy endpoint, never the cluster, so per-execution connection pools are
multiplexed.

## Usage

```hcl
module "read_database" {
  source  = "app.terraform.io/<org>/rds/aws"
  version = "~> 1.0"

  application_name = "prummo"
  environment      = "development"
  database_name    = "prummo_read"

  min_capacity_acu = 0.5
  max_capacity_acu = 4

  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.private_subnet_ids
  allowed_security_group_ids = [module.network.app_security_group_id]

  deletion_protection   = true
  backup_retention_days = 7
}
```

## What it creates

- An `aws_rds_cluster` (Aurora PostgreSQL, `engine_mode = "provisioned"` + a `serverlessv2_scaling_configuration`) with a `db.serverless` instance — i.e. Serverless v2. Storage encrypted; master password managed by RDS in Secrets Manager.
- An **RDS Proxy** (`engine_family = "POSTGRESQL"`) authenticating with that managed secret, plus its IAM role (`secretsmanager:GetSecretValue` + scoped `kms:Decrypt`) and default target group pointing at the cluster.
- Two security groups: the **proxy** SG (ingress 5432 from `allowed_security_group_ids`) and the **cluster** SG (ingress 5432 from the proxy only).

## Outputs

`proxy_endpoint` (connect here), `writer_endpoint`, `reader_endpoint`, `port`, `database_name`, `master_secret_arn`, `security_group_id` (the proxy SG), `cluster_arn`.

## Notes

- `manage_master_password` must stay `true` — the RDS Proxy auth references the AWS-managed secret this creates.
- `deletion_protection` defaults to `true`; a final snapshot is taken in `production` and skipped elsewhere.
