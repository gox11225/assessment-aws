output "alb_dns" {
  value = aws_lb.main.dns_name
}

output "ecr_uri_a" {
  value = aws_ecr_repository.service_a.repository_url
}

output "ecr_uri_b" {
  value = aws_ecr_repository.service_b.repository_url
}
