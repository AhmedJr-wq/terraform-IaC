# Networking: VPC, public subnet, internet gateway, route table.
# Nothing here should ever take an app-specific input -- this changes rarely and
# is shared by everything else in the stack.

resource "aws_vpc" "staging" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_tag}-vpc"
    Project = var.project_tag
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.staging.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_tag}-public-subnet"
    Project = var.project_tag
  }
}

resource "aws_internet_gateway" "staging" {
  vpc_id = aws_vpc.staging.id

  tags = {
    Name    = "${var.project_tag}-igw"
    Project = var.project_tag
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.staging.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.staging.id
  }

  tags = {
    Name    = "${var.project_tag}-public-rt"
    Project = var.project_tag
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
