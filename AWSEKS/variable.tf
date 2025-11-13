variable "cidr_block" {
  description = "VPC CIDR Block"
  type        = string

}
variable "public_subnet" {
  description = "Public Subnet CIDR Blocks"
  type        = list(string)

}

variable "private_subnets" {
  description = "Private Subnet CIDR Blocks"
  type        = list(string)

}