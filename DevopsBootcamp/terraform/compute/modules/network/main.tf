resource "aws_vpc" "dev_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name: "${var.env_prefix}vpc"
  }
}

resource "aws_subnet" "dev_subnet" {
  vpc_id = aws_vpc.dev_vpc.id
  cidr_block = var.subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name: "${var.env_prefix}subnet"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name: "${var.env_prefix}igw"
  }
}

resource "aws_default_route_table" "main_rtb" {
  default_route_table_id = aws_vpc.dev_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }
  tags = {
    Name: "${var.env_prefix}main-rtb"
  }
}

# default firewall
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.dev_vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name: "${var.env_prefix}default-sg"
  }
}
