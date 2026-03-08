resource "aws_lb" "main" {
  name               = "services-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "service_a" {
  name     = "service-a-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_target_group" "service_b" {
  name     = "service-b-tg"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "service_a" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/service-a*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_a.arn
  }
}

resource "aws_lb_listener_rule" "service_b" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  condition {
    path_pattern {
      values = ["/service-b*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_b.arn
  }
}