output "ec2_public_ip" {
  value = module.dev_ec2_instance.ec2_public_ip
}
output "aws_ami_id" {
  value = module.dev_ec2_instance.aws_ami_id
}
output "dev_vpc_id" {
  value = module.dev_ec2_network.dev_vpc.id
}