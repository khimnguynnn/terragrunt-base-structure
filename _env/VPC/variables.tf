variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "vpc_enable_nat_gateway" {
  type = bool
  default = false
}

variable "vpc_enable_vpn_gateway" {
  type = bool
  default = false
}

variable "vpc_tags" {
  type = map(string)
}