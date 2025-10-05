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
