#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)/infra"
rm -rf "$ROOT_DIR"
mkdir -p "$ROOT_DIR"

cat > "$ROOT_DIR/backend.tf" <<'TF'
# Backend configuration for remote state (edit before use)
terraform {
  required_version = ">= 1.3.0"
  backend "s3" {
    bucket         = "REPLACE_WITH_YOUR_TFSTATE_BUCKET" # <- edit
    key            = "agentic/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_WITH_DYNAMODB_TABLE"      # <- edit (for locking)
    encrypt        = true
  }
}
TF

cat > "$ROOT_DIR/providers.tf" <<'TF'
terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 4.0" }
    random = { source = "hashicorp/random", version = ">= 3.0" }
  }
}

provider "aws" {
  region = var.region
  # Optionally configure profile or assume_role for CI
  # shared_credentials_file = "~/.aws/credentials"
  # profile = var.aws_profile
}
provider "random" {}
TF

cat > "$ROOT_DIR/variables.tf" <<'TF'
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
TF

cat > "$ROOT_DIR/main.tf" <<'TF'
locals { name = var.name }

# 1) VPC - using community module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 4.0.0"
  name = "${local.name}-vpc"
  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  enable_nat_gateway = true
  single_nat_gateway = true
  tags = merge({"Project" = local.name}, var.tags)
}

data "aws_availability_zones" "available" {}

# 2) KMS Key
resource "aws_kms_key" "agentic" {
  description             = "KMS key for Agentic platform"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = merge({"Project" = local.name}, var.tags)
}

# 3) Artifacts bucket (S3)
resource "aws_s3_bucket" "artifacts" {
  bucket = length(var.artifacts_bucket_name) > 0 ? var.artifacts_bucket_name : "${local.name}-artifacts-${var.region}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.agentic.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  tags = merge({"Project" = local.name}, var.tags)
}

# 4) Secrets Manager secret for DB credentials (value to set via separate secrets pipeline)
resource "random_password" "db" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "db_creds" {
  name       = "${local.name}-db-creds"
  description = "Postgres credentials for agentic metadata DB"
  kms_key_id = aws_kms_key.agentic.arn
  tags = merge({"Project" = local.name}, var.tags)
}

resource "aws_secretsmanager_secret_version" "db_creds_value" {
  secret_id     = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
  })
}

# 5) RDS Postgres (simple single-instance dev config - change to module for prod)
resource "aws_db_instance" "postgres" {
  identifier = "${local.name}-db"
  engine = "postgres"
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_type
  allocated_storage = var.rds_allocated_storage
  name = "${local.name}_meta"
  username = var.db_username
  password = random_password.db.result
  parameter_group_name = "default.postgres15"
  skip_final_snapshot = true
  publicly_accessible = false
  multi_az = false
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  storage_encrypted = true
  kms_key_id = aws_kms_key.agentic.arn
  tags = merge({"Project" = local.name}, var.tags)
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.name}-db-subnets"
  subnet_ids = module.vpc.private_subnets
  tags = merge({"Project" = local.name}, var.tags)
}

# 6) EKS (community module)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 19.0.0"
  cluster_name = "${local.name}-eks"
  cluster_version = var.eks_version
  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id

  node_groups = {
    default = {
      desired_capacity = var.eks_node_desired
      max_capacity     = var.eks_node_max
      min_capacity     = var.eks_node_min
      instance_types   = var.eks_instance_types
      key_name         = var.ssh_key_name
    }
  }
  manage_aws_auth = true
  tags = merge({"Project" = local.name}, var.tags)
}

# 7) Outputs (see outputs.tf for more)
TF

cat > "$ROOT_DIR/outputs.tf" <<'TF'
output "eks_cluster_name" {
  value = module.eks.cluster_name
}
output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}
output "s3_artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}
output "kms_key_id" {
  value = aws_kms_key.agentic.id
}
TF

cat > "$ROOT_DIR/terraform.tfvars.example" <<'TFV'
region = "us-east-1"
name = "agentic"
vpc_cidr = "10.0.0.0/16"
public_subnets = ["10.0.0.0/24","10.0.1.0/24"]
private_subnets = ["10.0.16.0/20","10.0.32.0/20"]
az_count = 2

eks_version = "1.27"
eks_node_desired = 2
eks_node_min = 1
eks_node_max = 3
eks_instance_types = ["t3.medium"]

rds_engine_version = "15.3"
rds_instance_type = "db.t3.medium"
rds_allocated_storage = 20
rds_backup_retention = 7

db_username = "agentic_admin"
TFV

cat > "$ROOT_DIR/README.md" <<'MD'
# Infra Terraform module (Agentic platform) - DEV skeleton

This folder contains a starter Terraform configuration that deploys:
- VPC (using terraform-aws-modules/vpc)
- KMS Key
- S3 bucket for artifacts
- Secrets Manager secret (with generated password)
- RDS Postgres instance (single AZ, dev-friendly)
- EKS cluster (with a basic node group)

**IMPORTANT**
- This is a starting point for dev/staging. For production:
  - Use multi-AZ RDS (or RDS cluster), automated backups, and snapshot retention.
  - Use managed/prod-grade S3 lifecycle & cross-region replication if required.
  - Harden IAM policies, enable IRSA, OIDC provider and attach least-privilege roles.
  - Replace inline RDS resource with terraform-aws-modules/rds/aws for production best practices.
- Do NOT check real secrets into git. Use `terraform.tfvars` (gitignored) or CI secret injection.

**How to use**
1. Edit `backend.tf` to point to your S3 backend & DynamoDB lock table (or delete backend block to use local state).
2. Copy `terraform.tfvars.example` → `terraform.tfvars` and edit values (do not commit `terraform.tfvars`).
3. Initialize & plan: