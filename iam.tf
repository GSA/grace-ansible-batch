resource "aws_iam_role" "iam_role" {
  name        = "g-ansible-batch-lambda"
  description = "Role for GRACE Ansible Batch Lambda function"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}


resource "aws_iam_policy" "iam_policy" {
  name        = "g-ansible-batch-lambda"
  description = "Policy to allow GRACE Ansible Batch Lambda function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:PutImage",
        "ecr:Describe*",
        "ecr:List*",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "${aws_kms_key.kms_key.arn}"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

# g-ansible-batch-job IAM Role grants the needed permissions for
# AWS Batch job execution, S3 Access, and Cloudwatch Event creation
data "aws_iam_policy_document" "job" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.bucket.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      "arn:aws:s3:::packages.*.amazonaws.com/*",
      "arn:aws:s3:::repo.*.amazonaws.com/*",
      "arn:aws:s3:::amazonlinux.*.amazonaws.com/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.kms.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "g-ansible-batch-job"
  description = "Policy to allow AWS Batch Job access to S3 bucket and Cloudwatch"
  policy      = data.aws_iam_policy_document.job.json
}

resource "aws_iam_role" "job" {
  name = "g-ansible-batch-job"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "job" {
  role       = aws_iam_role.job.name
  policy_arn = aws_iam_policy.job.arn
}

# g-ansible-batch-ec2 IAM Role grants privileges necessary
# for AWS Batch instances to execute commands against the AWS API
resource "aws_iam_role" "ec2" {
  name = "g-ansible-batch-ec2"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "g-ansible-batch-ec2"
  role = aws_iam_role.ec2.name
}


# g-ansible-batch-service IAM Role grants necessary permissions
# to AWS Batch for the service functionality
resource "aws_iam_role" "service" {
  name = "g-ansible-batch-service"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "batch.amazonaws.com"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_instance_profile" "profile" {
  name = local.app_name
  role = aws_iam_role.role.name
}