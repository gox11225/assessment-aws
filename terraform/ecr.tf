resource "aws_ecr_repository" "service_a" {
  name         = "service-a"
  force_delete = true
}

resource "aws_ecr_repository" "service_b" {
  name         = "service-b"
  force_delete = true
}