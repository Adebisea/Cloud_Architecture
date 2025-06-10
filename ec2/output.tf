output "private_key" {
  value = tls_private_key.example.private_key_pem
  sensitive = true 
}

output "aws_key_pair_id" {
  value = aws_key_pair.example.key_pair_id
}