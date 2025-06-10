# VPC Resources
resource "aws_vpc" "vpc" {
  cidr_block            = "15.20.0.0/16"
  enable_dns_hostnames  = true

  tags   = {
    Name = "techn_vpc"
  }
}