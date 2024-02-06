resource "aws_vpc" "dev_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name : "${var.env_prefix}vpc"
  }
}
resource "aws_subnet" "dev_subnet" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name : "${var.env_prefix}subnet"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name : "${var.env_prefix}igw"
  }
}

#provision a route table and rt-assoc
# resource "aws_route_table" "dev_route_table" {
#   vpc_id = aws_vpc.dev_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.dev_igw.id
#   }
#   tags = {
#     Name: "${var.env_prefix}rtb"
#   }
# }

# resource "aws_route_table_association" "dev_rtb_assoc" {
#   subnet_id = aws_subnet.dev_subnet.id
#   route_table_id = aws_route_table.dev_route_table.id
# }

#assoc with main/default route table
resource "aws_default_route_table" "main_rtb" {
  default_route_table_id = aws_vpc.dev_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }
  tags = {
    Name : "${var.env_prefix}main-rtb"
  }
}

# firewall
# resource "aws_security_group" "dev_sg" {
#   name = "${var.env_prefix}sg"
#   vpc_id = aws_vpc.dev_vpc.id
#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "TCP"
#     cidr_blocks = [var.my_ip]
#   }
#   ingress {
#     from_port = 8080
#     to_port = 8080
#     protocol = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     prefix_list_ids = []
#   }
#   tags = {
#     Name: "${var.env_prefix}sg"
#   }
# }

# default firewall
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.dev_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name : "${var.env_prefix}default-sg"
  }
}

data "aws_ami" "latest_amazon_linux_image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "amazon-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "dev_aws_instance" {
  ami           = data.aws_ami.latest_amazon_linux_image.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.dev_subnet.id
  vpc_security_group_ids = [aws_default_security_group.default_sg.id]
  availability_zone      = var.availability_zone
  count = 3

  associate_public_ip_address = true
  # key_name = "formac"
  key_name = aws_key_pair.ssh_key.key_name

  # user_data = file("user-data.sh")
  user_data_replace_on_change = true

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_location)
  }
  provisioner "file" {
    source      = "user-data.sh"
    destination = "/home/ec2-user/user-data.sh"
  }
  # provisioner "remote-exec" {
  #   inline = ["/home/ec2-user/user-data.sh"]
  # }
  provisioner "remote-exec" {
    script = "user-data.sh"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> output.txt"
  }

  tags = {
    Name = "${var.env_prefix}server-${count.index}"
  }
}