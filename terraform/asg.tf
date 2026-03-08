resource "aws_launch_template" "main" {
  name_prefix   = "services-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  vpc_security_group_ids = [aws_security_group.instances.id]

  user_data = base64encode(templatefile("user-data.sh", {
    region    = var.region
    ecr_uri_a = aws_ecr_repository.service_a.repository_url
    ecr_uri_b = aws_ecr_repository.service_b.repository_url
    image_tag = var.image_tag
  }))
}

resource "aws_autoscaling_group" "main" {
  name                = "services-asg"
  min_size            = 2
  desired_capacity    = 2
  max_size            = 4
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [
    aws_lb_target_group.service_a.arn,
    aws_lb_target_group.service_b.arn,
  ]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "services-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "cpu-scale-out"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
}
