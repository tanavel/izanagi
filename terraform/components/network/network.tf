#================================================#
# Internet Gateway
#================================================#
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.sys}-${terraform.workspace}-igw"
  }
}

#================================================#
# VPC
#================================================#
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.sys}-${terraform.workspace}-vpc"
  }
}

#================================================#
# Subnet(Public)
#================================================#
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-public-subnet-2"
  }
}

resource "aws_subnet" "public_3" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1d"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-public-subnet-3"
  }
}

#================================================#
# Subnet(Private)
#================================================#
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-private-subnet-2"
  }
}

resource "aws_subnet" "private_3" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-1d"
  tags = {
    Name = "${var.sys}-${terraform.workspace}-private-subnet-3"
  }
}

#================================================#
# Route Table(Public)
#================================================#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.sys}-${terraform.workspace}-public-route-table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1.id
}

resource "aws_route_table_association" "public_2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_2.id
}

resource "aws_route_table_association" "public_3" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_3.id
}

#================================================#
# Route Table(Private)
#
# NOTE:
# - 本来はNAT Gateway経由でインターネットアクセスしたい
# - しかし、NGWは高いのでIGWを通すようにしている
#================================================#
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.sys}-${terraform.workspace}-private-route-table"
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_1" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_1.id
}

resource "aws_route_table_association" "private_2" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_2.id
}

resource "aws_route_table_association" "private_3" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_3.id
}
