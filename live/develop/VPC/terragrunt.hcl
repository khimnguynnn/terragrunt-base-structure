include "backend" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../_env/VPC"
}

inputs = {
  vpc_name            = "khiemnd-develop-vpc"
  vpc_cidr            = "10.244.0.0/16"
  vpc_azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  vpc_private_subnets = []
  vpc_public_subnets  = ["10.244.1.0/24", "10.244.2.0/24"]

  vpc_tags = {
    Environment = "develop"
  }
}
