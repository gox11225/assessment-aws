# Microservices Deployment - AWS PoC

## Deliverables can be found here:
[Deliverables.md](Deliverables.md)

## Architecture

```
                    Internet
                       │
                  ┌────┴────┐
                  │   ALB   │  :80
                  └────┬────┘
                 /service-a*  /service-b*
                  ┌────┴────┐
           ┌──────┤   ASG   ├──────┐
           │      └─────────┘      │
     ┌─────┴─────┐          ┌─────┴─────┐
     │  EC2 (a)  │          │  EC2 (b)  │
     │ :8080 (A) │          │ :8080 (A) │
     │ :8081 (B) │          │ :8081 (B) │
     └───────────┘          └───────────┘
           │                       │
           └───────┬───────────────┘
                   │
              ┌────┴────┐
              │   ECR   │
              │ svc-a   │
              │ svc-b   │
              └─────────┘
```

**Region:** us-east-1 (configurable via `terraform.tfvars`)

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Docker
- An existing EC2 key pair

## Deployment Steps

### 1. Edit terraform.tfvars with your values

### 2. Create ECR repos and push images
We need to create the ECR repositories first so we can push the service images to them.
```bash
terraform init
terraform apply -target=aws_ecr_repository.service_a -target=aws_ecr_repository.service_b

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 422921064977.dkr.ecr.us-east-1.amazonaws.com

# Build and push
docker build -t 422921064977.dkr.ecr.us-east-1.amazonaws.com/service-a:v1.0.0 .
docker push 422921064977.dkr.ecr.us-east-1.amazonaws.com/service-a:v1.0.0

docker build -t 422921064977.dkr.ecr.us-east-1.amazonaws.com/service-b:v1.0.0 .
docker push 422921064977.dkr.ecr.us-east-1.amazonaws.com/service-b:v1.0.0
```

### 3. Deploy the rest of the infrastructure

```bash
terraform apply
```

[output](terraform/terraform-apply.txt)