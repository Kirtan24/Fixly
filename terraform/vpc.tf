#########################################
# FIXLY — PRODUCTION VPC FOR ECS / ALB
#########################################

provider "aws" {
  region = "ap-south-1"
}

#########################################
# VPC
#########################################
resource "aws_vpc" "fixly_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "fixly-vpc"
  }
}

#########################################
# Internet Gateway
#########################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fixly_vpc.id

  tags = {
    Name = "fixly-igw"
  }
}

#########################################
# PUBLIC SUBNETS
#########################################
resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.fixly_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "fixly-public-1a"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id            = aws_vpc.fixly_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "fixly-public-1b"
  }
}

#########################################
# PRIVATE SUBNETS (FOR FUTURE USE)
#########################################
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.fixly_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "fixly-private-1a"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.fixly_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "fixly-private-1b"
  }
}

#########################################
# PUBLIC ROUTE TABLE
#########################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.fixly_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "fixly-public-rt"
  }
}

# Associate public subnets
resource "aws_route_table_association" "public_1a_assoc" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_1b_assoc" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public_rt.id
}

#########################################
# NAT GATEWAY (For private subnets)
#########################################
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "fixly-nat-eip"
  }
}


resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "fixly-nat-gateway"
  }
}

#########################################
# PRIVATE ROUTE TABLE
#########################################
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.fixly_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "fixly-private-rt"
  }
}

resource "aws_route_table_association" "private_1a_assoc" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_1b_assoc" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private_rt.id
}
