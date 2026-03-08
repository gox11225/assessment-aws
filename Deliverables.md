# Deliverables

## README.md

[README file](README.md)

## docker-compose.yml

[docker-compose.yml](terraform/docker-compose.yml)

## verify_endpoints.py

[verify_endpoints.py](verify_endpoints.py)

## Screenshots and command output

### ECR Repository Images

```bash

$ aws ecr describe-images --repository-name service-a --region us-east-1 --no-cli-pager                                    <aws:prod>
{
    "imageDetails": [
        {
            "registryId": "422921064977",
            "repositoryName": "service-a",
            "imageDigest": "sha256:85a1e462be8359aa32f2d82979e886af1a9dad0b632861df1905f3f3417937e6",
            "imageTags": [
                "v1.0.0"
            ],
            "imageSizeInBytes": 49969020,
            "imagePushedAt": "2026-03-07T19:53:42.175000-05:00",
            "imageManifestMediaType": "application/vnd.docker.distribution.manifest.v2+json",
            "artifactMediaType": "application/vnd.docker.container.image.v1+json",
            "lastRecordedPullTime": "2026-03-07T19:56:18.218000-05:00"
        }
    ]
}

 $ aws ecr describe-images --repository-name service-b  --region us-east-1 --no-cli-pager                                   <aws:prod>
{
    "imageDetails": [
        {
            "registryId": "422921064977",
            "repositoryName": "service-b",
            "imageDigest": "sha256:05276801d496bc73917257cca2825ac55e87007cfc35b9783e969c97a39ad77d",
            "imageTags": [
                "v1.0.0"
            ],
            "imageSizeInBytes": 49969021,
            "imagePushedAt": "2026-03-07T19:53:17.693000-05:00",
            "imageManifestMediaType": "application/vnd.docker.distribution.manifest.v2+json",
            "artifactMediaType": "application/vnd.docker.container.image.v1+json",
            "lastRecordedPullTime": "2026-03-07T19:56:18.371000-05:00"
        }
    ]
}

```

### Docker Running on EC2 Instances

#### Instance 1

```bash
  ssh ubuntu@3.236.255.22
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.17.0-1007-aws x86_64)
...
ubuntu@ip-172-31-53-178:~$ sudo docker ps
CONTAINER ID   IMAGE                                                           COMMAND           CREATED       STATUS       PORTS                                         NAMES
c333756ed417   422921064977.dkr.ecr.us-east-1.amazonaws.com/service-b:v1.0.0   "python app.py"   2 hours ago   Up 2 hours   0.0.0.0:8081->5001/tcp, [::]:8081->5001/tcp   ubuntu-service-b-1
aa826889a36c   422921064977.dkr.ecr.us-east-1.amazonaws.com/service-a:v1.0.0   "python app.py"   2 hours ago   Up 2 hours   0.0.0.0:8080->5000/tcp, [::]:8080->5000/tcp   ubuntu-service-a-1
ubuntu@ip-172-31-53-178:~$ 

```

#### Instance 2

```bash
  ssh ubuntu@3.91.9.141
...  
ubuntu@ip-172-31-29-223:~$ sudo docker ps
CONTAINER ID   IMAGE                                                           COMMAND           CREATED       STATUS       PORTS                                         NAMES
31529b16255c   422921064977.dkr.ecr.us-east-1.amazonaws.com/service-a:v1.0.0   "python app.py"   2 hours ago   Up 2 hours   0.0.0.0:8080->5000/tcp, [::]:8080->5000/tcp   ubuntu-service-a-1
e56bf4eb18fa   422921064977.dkr.ecr.us-east-1.amazonaws.com/service-b:v1.0.0   "python app.py"   2 hours ago   Up 2 hours   0.0.0.0:8081->5001/tcp, [::]:8081->5001/tcp   ubuntu-service-b-1

```

### Curl Responses

```bash
  curl http://services-alb-801896148.us-east-1.elb.amazonaws.com/service-a       
{"message":"Hello from Service A"}
  curl http://services-alb-801896148.us-east-1.elb.amazonaws.com/service-a/health
{"service":"service-a","status":"ok"}
  curl http://services-alb-801896148.us-east-1.elb.amazonaws.com/service-b       
{"message":"Hello from Service B"}
  curl http://services-alb-801896148.us-east-1.elb.amazonaws.com/service-b/health
{"service":"service-b","status":"ok"}

```

### Verification Script

```bash
  python3 verify_endpoints.py $(terraform output -raw alb_dns)                                                        <aws:prod>
=== Checking ALB endpoints ===
[PASS] http://services-alb-801896148.us-east-1.elb.amazonaws.com/service-a/health -> 200
[PASS] http://services-alb-801896148.us-east-1.elb.amazonaws.com/service-b/health -> 200

All checks passed.
```

#### ASG Scale-Out Evidence

Scale-out was triggered by stressing CPU above the 40% threshold by the `stress` tool:

```bash
root@ip-172-31-53-178:~# stress --cpu 2 --timeout 300
stress: info: [5833] dispatching hogs: 2 cpu, 0 io, 0 vm, 0 hdd

```

## F. Cleanup Confirmation

```bash
$ terraform destroy
```