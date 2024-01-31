data "aws_ami" "latest_amazon_linux_image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image_name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_key_pair" "ssh_key" {
  key_name = "amazon-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "dev_aws_instance" {
  ami = data.aws_ami.latest_amazon_linux_image.id
  instance_type = var.instance_type

  subnet_id = var.dev_subnet
  vpc_security_group_ids = [var.default_sg]
  availability_zone = var.availability_zone

  associate_public_ip_address = true
  # key_name = "formac"
  key_name = aws_key_pair.ssh_key.key_name

  # user_data = file("user-data.sh")
  user_data_replace_on_change = true
  
  connection{
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_location)
  }
  provisioner "file" {
    source = "user-data.sh"
    destination = "/home/ec2-user/user-data.sh"
  }
  # provisioner "remote-exec" {
  #   inline = ["/home/ec2-user/user-data.sh"]
  # }
  provisioner "remote-exec" {
    script = "user-data.sh"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > output.txt"
  }

  tags = {
    Name = "${var.env_prefix}server"
  }
}