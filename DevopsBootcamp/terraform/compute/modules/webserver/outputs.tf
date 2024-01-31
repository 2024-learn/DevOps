output "aws_ami_id" {
  value = data.aws_ami.latest_amazon_linux_image.id
}
output "ec2_public_ip" {
  value = aws_instance.dev_aws_instance.public_ip
}