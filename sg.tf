resource "aws_security_group" "service" {
  name = "g-ansible-batch-environment"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}