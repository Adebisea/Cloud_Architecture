output "private_key" {
  value = tls_private_key.tls_prv_key.private_key_pem
  sensitive = true 
}

output "aws_key_pair_id" {
  value = aws_key_pair.prv_key.key_pair_id
}

output "instance_id"  {
  value = aws_instance.ec2_techn.id
  }

output "ec2_sg" {
    value = aws_security_group.allow_traffic.id
}