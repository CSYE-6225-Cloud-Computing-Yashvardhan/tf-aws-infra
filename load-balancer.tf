resource "aws_lb" "web_app_lb" {
  name               = "web-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "web-app-lb"
  }
}

resource "aws_lb_target_group" "web_app_tg" {
  name     = "web-app-target-group"
  port     = var.custom_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "web-app-target-group"
  }
}

resource "aws_lb_listener" "web_app_listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.demo_ssl_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_tg.arn
  }
}
