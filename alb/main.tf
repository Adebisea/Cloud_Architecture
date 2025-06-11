#aws ALB resources


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


resource "aws_s3_bucket" "bucket" {
  bucket = "techn_alb_log_acess"

  tags = {
    Name        = "techn_bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "bk_policy" {
  bucket =aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "techn bucket policy to allow alb put objects in s3"
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
                                    "Resource": aws_s3_bucket.bucket.arn,
                                    "Condition": {
                                        "ArnLike": {
                                        "aws:SourceArn": aws_lb.alb.arn
                                        }
                                    }
                                    }
                                ]
                            }
                        )
                    } 