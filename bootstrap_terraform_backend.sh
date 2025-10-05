#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   BUCKET=my-tfstate-bucket DYNAMODB_TABLE=terraform-locks REGION=us-east-1 ./bootstrap_terraform_backend.sh
#
# If you prefer, set AWS_PROFILE before running:
#   AWS_PROFILE=your-profile ./bootstrap_terraform_backend.sh

# Configurable via environment variables
BUCKET="${BUCKET:-your-terraform-state-bucket}"
DYNAMODB_TABLE="${DYNAMODB_TABLE:-terraform-locks}"
REGION="${REGION:-us-east-1}"
# Optional: set KMS_KEY_ID to the ARN or key id you want S3 to use for server-side encryption.
KMS_KEY_ID="${KMS_KEY_ID:-}"

AWS_CLI="${AWS_CLI:-aws}"   # override if aws in path is different

echo "Bootstrap Terraform backend"
echo "  bucket: $BUCKET"
echo "  dynamodb table: $DYNAMODB_TABLE"
echo "  region: $REGION"
if [ -n "$KMS_KEY_ID" ]; then
  echo "  using KMS key: $KMS_KEY_ID"
else
  echo "  using SSE-S3 (AWS-managed) for bucket encryption"
fi

# Helper to check aws cli
if ! command -v "${AWS_CLI}" >/dev/null 2>&1; then
  echo "ERROR: aws cli not found. Install and configure it first."
  exit 1
fi

# Ensure AWS credentials are available (basic check)
if ! "${AWS_CLI}" sts get-caller-identity --region "$REGION" >/dev/null 2>&1; then
  echo "ERROR: aws cli cannot call sts get-caller-identity. Check credentials and region."
  exit 1
fi

# 1) Create S3 bucket if not exists
echo "Checking S3 bucket..."
if "${AWS_CLI}" s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "Bucket $BUCKET already exists (accessible)."
else
  echo "Creating S3 bucket $BUCKET..."
  # Create bucket with region handling
  if [ "$REGION" = "us-east-1" ]; then
    "${AWS_CLI}" s3api create-bucket --bucket "$BUCKET" --region "$REGION"
  else
    "${AWS_CLI}" s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION"
  fi
  echo "Bucket created."
fi

# 1a) Enable versioning
echo "Ensuring versioning is enabled..."
"${AWS_CLI}" s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled --region "$REGION"
echo "Versioning enabled."

# 1b) Put encryption configuration
if [ -n "$KMS_KEY_ID" ]; then
  echo "Setting bucket to use KMS key for server-side encryption..."
  cat > /tmp/sse.json <<EOF
{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "$KMS_KEY_ID"
      }
    }
  ]
}
EOF
  "${AWS_CLI}" s3api put-bucket-encryption --bucket "$BUCKET" --server-side-encryption-configuration file:///tmp/sse.json --region "$REGION"
  rm -f /tmp/sse.json
  echo "Bucket encryption configured to use KMS key."
else
  echo "Configuring bucket to use SSE-S3 (AWS-managed) encryption..."
  cat > /tmp/sse2.json <<EOF
{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}
EOF
  "${AWS_CLI}" s3api put-bucket-encryption --bucket "$BUCKET" --server-side-encryption-configuration file:///tmp/sse2.json --region "$REGION"
  rm -f /tmp/sse2.json
  echo "Bucket encryption (SSE-S3) configured."
fi

# 1c) Block public access by default
echo "Applying public access block..."
"${AWS_CLI}" s3api put-public-access-block --bucket "$BUCKET" --public-access-block-configuration 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true' --region "$REGION"
echo "Public access blocked."

# 2) Create DynamoDB table if not exists
echo "Checking DynamoDB table..."
if "${AWS_CLI}" dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$REGION" >/dev/null 2>&1; then
  echo "DynamoDB table $DYNAMODB_TABLE already exists."
else
  echo "Creating DynamoDB table $DYNAMODB_TABLE..."
  "${AWS_CLI}" dynamodb create-table \
    --table-name "$DYNAMODB_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"
  echo "Waiting for table to become ACTIVE..."
  "${AWS_CLI}" dynamodb wait table-exists --table-name "$DYNAMODB_TABLE" --region "$REGION"
  echo "DynamoDB table created and active."
fi

# 3) Output suggested backend.tf snippet
cat <<EOF

Bootstrap completed.

Add (or update) your infra/backend.tf with this backend configuration:

terraform {
  backend "s3" {
    bucket         = "$BUCKET"
    key            = "agentic/terraform.tfstate"
    region         = "$REGION"
    dynamodb_table = "$DYNAMODB_TABLE"
    encrypt        = true
  }
}

NOTE:
- If you used a KMS key, ensure Terraform has kms:Decrypt permission or use an IAM role that can
  access the KMS key. If you used SSE-S3, no extra KMS perms required.
- Keep the bucket name and dynamodb table name secret-ish and do not commit them with credentials.

EOF

echo "Done."