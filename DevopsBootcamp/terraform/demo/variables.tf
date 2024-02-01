variable "cidr_blocks" {
  type = list(object({
    cidr_block = string
    name       = string
  }))
}