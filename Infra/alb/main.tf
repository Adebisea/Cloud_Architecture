#aws ALB resources


resource "aws_lb" "alb" {
  name               = "techn-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets_ids

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.bucket.id
    prefix  = "techn-alb"
    enabled = true
  }

  tags = {
    Name = "techn-alb"
    Environment = "production"
  }
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.arn
  }
}

resource "aws_lb_target_group" "lb-tg" {
  name     = "techn-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "alb-tg-attachment" {
  target_group_arn = aws_lb_target_group.lb-tg.arn
  target_id        = var.instance_id
  port             = 80
}

#alb security group
resource "aws_security_group" "alb_sg" {
  name        = "techn_sg_alb"
  description = "Allow inbound traffic from internet and outbound to ec2 instances"
  vpc_id      = var.vpc_id

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.ec2_sg]
    description     = "Forward traffic to instance listener port"
      }
    }

resource "aws_s3_bucket" "bucket" {
  bucket = "techn-alb-log-acess"

  tags = {
    Name        = "techn_bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "bk_policy" {
  bucket      =  aws_s3_bucket.bucket.id
  policy      = jsonencode(
                            {
                                "Version": "2012-10-17",
                                "Statement": [
                                    {
                                    "Sid": "AllowELBLogDelivery",
                                    "Effect": "Allow",
                                    "Principal": {
                                        "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
                                        },
                                    "Action": "s3:PutObject",
                                    "Resource": "${aws_s3_bucket.bucket.arn}/*"
                                }
                            ]
                        }
                    )
                } 