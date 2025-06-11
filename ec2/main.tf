

resource "tls_private_key" "tls_prv_key" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

resource "aws_key_pair" "prv_key" {
  key_name   = "techn_prvkey"
  public_key = tls_private_key.tls_prv_key.public_key_openssh 
}

#ec2 security group
resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow inbound traffic from the ALB, and ssh connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.ssh_cidr_block]
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

resource "aws_iam_role" "ssm_ec2_role" {
  name = "techn_ssm-ec2-role"

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
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_ec2_profile" {
  name = "ssm-ec2-profile"
  role = aws_iam_role.ssm_ec2_role.name
}


resource "aws_instance" "ec2_techn" {
  ami                    = data.aws_ami_ids.ubuntu.ids[0]
  instance_type          = var.instance_type
  key_name               =  aws_key_pair.prv_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
  subnet_id              = var.prv2_subnet_id
  iam_instance_profile  = aws_iam_instance_profile.ssm_ec2_profile.name
  root_block_device {
            volume_size  = 8
             }

  tags = {
    Name = "ec2_techn"
    Environment = var.environment
  }

  user_data = file("ec2/user_data.sh")
}