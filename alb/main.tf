#aws ALB resources

resource "aws_lb" "alb" {
  name               = "techn-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnets_ids

  enable_deletion_protection = true

  access_logs {
    bucket  = ""
    prefix  = "techn-alb"
    enabled = true
  }

  tags = {
    Name = "techn-alb"
    Environment = "production"
  }
}