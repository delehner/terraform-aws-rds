variable "application_name" {
  type        = string
  description = "Application name. Used in resource names."
}

variable "environment" {
  type        = string
  description = "Environment where the resource is deployed (e.g. development, staging, production)."
}

variable "database_name" {
  type        = string
  default     = "app"
  description = "Name of the initial database created in the cluster."
}

variable "master_username" {
  type        = string
  default     = "app"
  description = "Master username for the cluster."
}

variable "engine_version" {
  type        = string
  default     = "16.4"
  description = "Aurora PostgreSQL engine version."
}

variable "min_capacity_acu" {
  type        = number
  default     = 0.5
  description = "Serverless v2 minimum Aurora Capacity Units."
}

variable "max_capacity_acu" {
  type        = number
  default     = 4
  description = "Serverless v2 maximum Aurora Capacity Units."
}

variable "vpc_id" {
  type        = string
  description = "VPC to place the cluster and RDS Proxy security groups in."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the DB subnet group and the RDS Proxy."
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "Security groups allowed to reach the RDS Proxy on 5432 (e.g. the in-VPC app security group)."
}

variable "manage_master_password" {
  type        = bool
  default     = true
  description = "Let RDS manage the master password in an AWS-managed Secrets Manager secret. Required for the RDS Proxy auth used by this module."

  validation {
    condition     = var.manage_master_password
    error_message = "manage_master_password must be true — the RDS Proxy auth in this module references the AWS-managed master secret."
  }
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Prevent accidental deletion of the cluster."
}

variable "backup_retention_days" {
  type        = number
  default     = 7
  description = "Automated backup retention in days."
}
