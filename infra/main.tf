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
