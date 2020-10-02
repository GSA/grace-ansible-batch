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
