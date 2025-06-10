

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