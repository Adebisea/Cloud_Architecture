# VPC Resources
resource "aws_vpc" "vpc" {
  cidr_block            = "15.20.0.0/16"
  enable_dns_hostnames  = true

  tags   = {
    Name = "techn_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags   = {
    Name = "techn_vpc_igw"
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


# Public Subnets Route tables
resource "aws_route_table" "pub_routes" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags   = {
    Name = "techn_vpc_pub_rt"
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
    Name = "techn_vpc_prv_rt"
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