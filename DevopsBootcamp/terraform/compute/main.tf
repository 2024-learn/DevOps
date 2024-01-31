module "dev_ec2_network" {
  source = "./modules/network"
  vpc_cidr = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  env_prefix = var.env_prefix
  availability_zone = var.availability_zone
  my_ip = var.my_ip
}

module "dev_ec2_instance" {
  source = "./modules/webserver"
  public_key_location = var.public_key_location
  private_key_location = var.private_key_location
  instance_type = var.instance_type
  env_prefix = var.env_prefix
  availability_zone = var.availability_zone
  default_sg = module.dev_ec2_network.default_sg.id
  dev_subnet = module.dev_ec2_network.dev_subnet.id
  image_name = var.image_name
}
