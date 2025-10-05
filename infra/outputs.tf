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
