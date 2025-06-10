

resource "tls_private_key" "tls_prv_key" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits

  tags = {
    Name = "techn_tls_key"
  }
}

resource "aws_key_pair" "prv_key" {
  key_name   = "techn_prvkey"
  public_key = tls_private_key.tls_prv_key.public_key_openssh 
}

#ec2 security group
resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow inbound traffic from the Internet,  and ssh connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.dest_cidr_block]
  }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.dest_cidr_block]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.dest_cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.dest_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.dest_cidr_block]
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


resource "aws_instance" "ec2_techn" {
  ami                    = data.aws_ami_ids.ubuntu.ids[0]
  instance_type          = var.instance_type
  key_name               =  aws_key_pair.prv_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]
  subnet_id = var.prv2_subnet_id
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "ec2_techn"
    Environment = var.environment
  }
}