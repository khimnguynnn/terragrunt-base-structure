variable "ec2_name" {
  type = string
}

variable "ec2_instance_type" {
  type = string
}

variable "ec2_key_name" {
  type = string
}

variable "ec2_monitoring" {
  type = bool
}

variable "ec2_subnet_id" {
  type = string
}

# variable "ec2_security_group_id" {
#   type = string
# }

variable "ec2_tags" {
  type = map(string)
}

variable "ec2_ebs_volumes" {
  type = map(object({
    size      = number
    type      = string
    encrypted = bool
  }))
  default = {}
}
