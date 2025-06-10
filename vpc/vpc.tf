# VPC Resources
resource "aws_vpc" "vpc" {
  cidr_block            = "15.20.0.0/16"
  enable_dns_hostnames  = true

  tags   = {
    Name = "techn_vpc"
  }
}

# List availability zones in region
data "aws_availability_zones" "az_list" {
  state = "available"
}

# public subnets
resource "aws_subnet" "pub1_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "15.20.25.0/24"
  availability_zone = data.aws_availability_zones.az_list.names[0]

  tags   = {
    Name = "techn_vpc_pub1_subnet"
  }
}

resource "aws_subnet" "pub2_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "15.20.30.0/24"
  availability_zone = data.aws_availability_zones.az_list.names[1]

  tags   = {
    Name = "techn_vpc_pub2_subnet"
  }
}


# Private subnets
resource "aws_subnet" "prv1_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "15.20.35.0/24"
  availability_zone = data.aws_availability_zones.az_list.names[0]

  tags   = {
    Name = "techn_vpc_prv1_subnet"
  }
}

resource "aws_subnet" "prv2_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "15.20.40.0/24"
  availability_zone = data.aws_availability_zones.az_list.names[1]

  tags   = {
    Name = "techn_vpc_prv2_subnet"
  }
}

# Nat Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub1_subnet.id

  tags   = {
    Name = "techn_vpc_nat"
  }

  depends_on = [aws_internet_gateway.gw]
}

# Elastic IP 
resource "aws_eip" "eip" {
  domain   = "vpc"

    tags   = {
    Name   = "techn_vpc_eip"
  }
}