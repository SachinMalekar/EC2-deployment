# ALB 
resource "aws_lb" "dev-alb" {
  name               = "dev-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public_subet_a.id, aws_subnet.public_subet_b.id]

  depends_on = [aws_internet_gateway.dev_igw]

  tags = {
    Name = "dev-alb"
  }
}

# ALB listener 
resource "aws_lb_listener" "dev-alb-listener" {
  load_balancer_arn = aws_lb.dev-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev-tg.arn
  }
}

# ALB target group 
resource "aws_lb_target_group" "dev-tg" {
  name        = "dev-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.dev_vpc.id

  health_check {
    path                = "/notes"
    port                = 80
    protocol            = "HTTP"
    interval            = 30
    timeout             = 15
    healthy_threshold   = 3
    unhealthy_threshold = 10
  }
}
