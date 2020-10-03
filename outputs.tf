output "ecr_arn" {
  description = "The Amazon Resource Name (ARN) identifying the ECR"
  value       = aws_ecr_repository.ecr.arn
}

output "ecr_id" {
  description = "The registry ID of the ECR repository"
  value       = aws_ecr_repository.ecr.registry_id
}

output "ecr_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.ecr.repository_url
}

output "ecr_kms_key_arn" {
  value       = aws_kms_key.kms_key.arn
  description = "The ARN for the ECR KMS encryption key"
}
