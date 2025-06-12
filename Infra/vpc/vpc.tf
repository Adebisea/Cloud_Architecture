# VPC Resources
resource "aws_vpc" "vpc" {
  cidr_block            = var.vpc_cidr_block
  enable_dns_hostnames  = true

  tags   = {
    Name = "techn_vpc-${var.prefix}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags   = {
    Name = "techn_vpc_igw-${var.prefix}"
  }
}

# List availability zones in region
data "aws_availability_zones" "az_list" {
  state = "available"
}

# public subnets
resource "aws_subnet" "pub1_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub1_subnet_cidr_block
  availability_zone = data.aws_availability_zones.az_list.names[0]

  tags   = {
    Name = "techn_vpc_pub1_subnet-${var.prefix}"
  }
}

resource "aws_subnet" "pub2_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub2_subnet_cidr_block
  availability_zone = data.aws_availability_zones.az_list.names[1]

  tags   = {
    Name = "techn_vpc_pub2_subnet-${var.prefix}"
  }
}


# Private subnets
resource "aws_subnet" "prv1_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.prv1_subnet_cidr_block
  availability_zone = data.aws_availability_zones.az_list.names[0]

  tags   = {
    Name = "techn_vpc_prv1_subnet-${var.prefix}"
  }
}

resource "aws_subnet" "prv2_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.prv2_subnet_cidr_block
  availability_zone = data.aws_availability_zones.az_list.names[1]

  tags   = {
    Name = "techn_vpc_prv2_subnet-${var.prefix}"
  }
}

# Nat Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub1_subnet.id

  tags   = {
    Name = "techn_vpc_nat-${var.prefix}"
  }

  depends_on = [aws_internet_gateway.gw]
}

# Elastic IP 
resource "aws_eip" "eip" {
  domain   = "vpc"

    tags   = {
    Name   = "techn_vpc_eip-${var.prefix}"
  }
}


# Public Subnets Route tables
resource "aws_route_table" "pub_routes" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags   = {
    Name = "techn_vpc_pub_rt-${var.prefix}"
  }
}

# Private Subnets Route tables
resource "aws_route_table" "prv_routes" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags   = {
    Name = "techn_vpc_prv_rt-${var.prefix}"
  }
}

# Associate pub route table with public subnets
resource "aws_route_table_association" "pub1_subnet_route" {
  subnet_id      = aws_subnet.pub1_subnet.id
  route_table_id = aws_route_table.pub_routes.id
}

resource "aws_route_table_association" "pub2_subnet_route" {
  subnet_id      = aws_subnet.pub2_subnet.id
  route_table_id = aws_route_table.pub_routes.id
}

# Associate prv route table with private subnets
resource "aws_route_table_association" "prv1_subnet_route" {
  subnet_id      = aws_subnet.prv1_subnet.id
  route_table_id = aws_route_table.prv_routes.id
}

resource "aws_route_table_association" "prv2_subnet_route" {
  subnet_id      = aws_subnet.prv2_subnet.id
  route_table_id = aws_route_table.prv_routes.id
}