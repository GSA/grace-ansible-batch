resource "aws_ecr_repository" "ecr" {
  name = var.ecr_name

  image_scanning_configuration {
    scan_on_push = var.scan_image
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.kms_key.arn
  }
}

resource "aws_ecr_lifecycle_policy" "ecr" {
  repository = aws_ecr_repository.ecr.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only ${var.max_image_count} tagged images, expire all others",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ${jsonencode(var.tag_prefix_list)},
                "countType": "imageCountMoreThan",
                "countNumber": ${var.max_image_count}
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2   ,
            "description": "Expire images older than ${var.expiration_days} days",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ${jsonencode(var.tag_prefix_list)},
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": ${var.expiration_days}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "ecr" {
  repository = aws_ecr_repository.ecr.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ECR Repo Policy",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.account_id}:root"
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}
