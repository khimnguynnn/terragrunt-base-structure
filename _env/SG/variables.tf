variable "sg_name" {
  type = string
}

variable "sg_description" {
  type = string
}

variable "sg_vpc_id" {
  type = string
}

variable "sg_ingress_cidr_blocks" {
  type = list(string)
}

variable "sg_tags" {
  type = map(string)
}
