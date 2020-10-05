// g-ansible-batch-job executes files/run.sh to execute the creation of
// secrets.yaml followed by the execution of ansible
resource "aws_batch_job_definition" "job" {
  name = "g-ansible-batch-job"
  type = "container"

  container_properties = templatefile("${path.module}/files/image.json", {
    bucket = aws_s3_bucket.bucket.id
    region = var.region
    role   = aws_iam_role.job.arn
  })
}

resource "aws_batch_job_queue" "batch" {
  name     = "g-ansible-batch-environment"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.batch.arn
  ]
}

resource "aws_batch_compute_environment" "batch" {
  compute_environment_name = "g-ansible-batch-environment"

  compute_resources {
    instance_role = aws_iam_instance_profile.ec2.arn
    instance_type = var.instance_types

    max_vcpus = var.max_vcpus
    min_vcpus = var.min_vcpus

    security_group_ids = [aws_security_group.sample.id]
    subnets = var.subnets
    type = "EC2"
  }

  service_role = aws_iam_role.service.arn
  type         = "MANAGED"

  depends_on   = [aws_iam_role_policy_attachment.service]
}