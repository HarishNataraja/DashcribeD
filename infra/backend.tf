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
