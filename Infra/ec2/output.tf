
output "instance_id"  {
  value = aws_instance.ec2_techn.id
  }

output "ec2_sg" {
    value = aws_security_group.allow_traffic.id
}