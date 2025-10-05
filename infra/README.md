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
