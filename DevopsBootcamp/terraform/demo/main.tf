resource "aws_vpc" "dev_vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {
    name: var.cidr_blocks[0].name
  }
}
resource "aws_subnet" "dev_subnet" {
  vpc_id = aws_vpc.dev_vpc.id
  cidr_block = var.cidr_blocks[1].cidr_block
  availability_zone = "ca-central-1a"
  tags = {
    name: var.cidr_blocks[1].name
  }
}
output "dev_vpc_id" {
  value = aws_vpc.dev_vpc.id
}
