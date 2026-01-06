
#ec2 security group
resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic-${var.prefix}"
  description = "Allow inbound traffic from the ALB, and ssh connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.egress_cidr_block]
  }
}

data "aws_ami_ids" "ubuntu" {
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/*/ubuntu-*-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  sort_ascending = true

}

resource "aws_iam_role" "ec2_role" {
  name = "techn_ec2-role--${var.prefix}"
  description = "iam role for ec2 access to ssm and secretmanager"
  assume_role_policy = jsonencode(
                                    {
                                      Version = "2012-10-17",
                                      Statement = [
                                        {
                                          Effect = "Allow",
                                          Principal = {
                                            Service = "ec2.amazonaws.com"
                                          },
                                          Action = "sts:AssumeRole"
                                        }
                                      ]
                                    }
                                  )
                                }

resource "aws_iam_role_policy_attachment" "ssm_ec2_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# policy for ec2 to access Secrets Manager
resource "aws_iam_policy" "secrets_access" {
  name = "techn_secrets_access-${var.prefix}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = var.secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}


#policy for ec2 to access S3
resource "aws_iam_policy" "ec2_s3_policy" {
  name = "ec2-s3-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::technn-deployment-bucket",
          "arn:aws:s3:::technn-deployment-bucket/*"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

# iam_instance_profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-${var.prefix}"
  role = aws_iam_role.ec2_role.name
}

# ec2 instance
resource "aws_instance" "ec2_techn" {
  ami                    = data.aws_ami_ids.ubuntu.ids[0]
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
  subnet_id              = var.prv2_subnet_id
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
            volume_size  = 8
             }
  user_data = file("ec2/user_data.sh")

  tags = {
    Name = "ec2_techn-${var.prefix}"
    Environment = var.environment
  }

}