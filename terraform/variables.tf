variable "region" {
  default = "us-east-1"
}

variable "my_ip" {
  description = "Public IP for SSH access"
}

variable "key_name" {
  description = "key pair name"
}

variable "image_tag" {
  description = "Docker image tag"
  default     = "v1.0.0"
}
