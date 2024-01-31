output "default_sg" {
  value = aws_default_security_group.default_sg
}
output "dev_subnet" {
  value = aws_subnet.dev_subnet
}
output "dev_vpc" {
  value = aws_vpc.dev_vpc
}