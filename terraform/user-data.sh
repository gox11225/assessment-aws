#!/bin/bash
set -euo pipefail

# Install tools
apt-get update
apt-get install -y docker.io docker-compose-v2
systemctl enable --now docker

apt-get install -y unzip
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# ECR login
ECR_REGISTRY=$(echo ${ecr_uri_a} | cut -d/ -f1)
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin "$ECR_REGISTRY"

# docker-compose.yml
cat > /home/ubuntu/docker-compose.yml <<EOF
services:
  service-a:
    image: ${ecr_uri_a}:${image_tag}
    ports:
      - "8080:5000"
    restart: unless-stopped

  service-b:
    image: ${ecr_uri_b}:${image_tag}
    ports:
      - "8081:5001"
    restart: unless-stopped
EOF

# Start all services
cd /home/ubuntu
docker compose up -d