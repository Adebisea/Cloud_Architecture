

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