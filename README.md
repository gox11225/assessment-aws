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

### 1. Configure variables

```bash
 Edit terraform.tfvars with your values
```

### 2. Create ECR repos and push images
We need to create ECR repos first to be able to push service images to it 
```bash
terraform init
terraform apply -target=aws_ecr_repository.service_a -target=aws_ecr_repository.service_b

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 422921064977.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag service-a:v1.0.0 $(terraform output -raw ecr_uri_a):v1.0.0
docker push $(terraform output -raw ecr_uri_a):v1.0.0

docker tag service-b:v1.0.0 $(terraform output -raw ecr_uri_b):v1.0.0
docker push $(terraform output -raw ecr_uri_b):v1.0.0
```

### 3. Deploy the rest of the infrastructure

```bash
terraform apply
```
[terraform-apply.txt](terraform/terraform-apply.txt)