variable "region" { type = string; default = "us-east-1" }
variable "name" { type = string; default = "agentic" }

# VPC
variable "vpc_cidr" { type = string; default = "10.0.0.0/16" }
variable "public_subnets" { type = list(string); default = ["10.0.0.0/24","10.0.1.0/24"] }
variable "private_subnets" { type = list(string); default = ["10.0.16.0/20","10.0.32.0/20"] }
variable "az_count" { type = number; default = 2 }

# EKS
variable "eks_version" { type = string; default = "1.27" }
variable "eks_node_desired" { type = number; default = 2 }
variable "eks_node_min" { type = number; default = 1 }
variable "eks_node_max" { type = number; default = 3 }
variable "eks_instance_types" { type = list(string); default = ["t3.medium"] }
variable "ssh_key_name" { type = string; default = "" }

# RDS
variable "rds_engine_version" { type = string; default = "15.3" }
variable "rds_instance_type" { type = string; default = "db.t3.medium" }
variable "rds_allocated_storage" { type = number; default = 20 }
variable "rds_backup_retention" { type = number; default = 7 }
variable "db_username" { type = string; default = "agentic_admin" }

# Artifacts
variable "artifacts_bucket_name" { type = string; default = "" } # optional override

# Misc
variable "tags" { type = map(string); default = {} }
