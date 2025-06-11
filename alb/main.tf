#aws ALB resources

resource "aws_s3_bucket" "bucket" {
  bucket = "techn_alb_log_acess"

  tags = {
    Name        = "techn_bucket"
    Environment = var.environment
  }
}

resource "aws_lb" "alb" {
  name               = "techn-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnets_ids

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.bucket.name
    prefix  = "techn-alb"
    enabled = true
  }

  tags = {
    Name = "techn-alb"
    Environment = "production"
  }
}