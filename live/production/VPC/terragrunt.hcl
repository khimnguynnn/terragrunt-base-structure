include "backend" {
  path = find_in_parent_folders()
}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../_env/VPC"
}

inputs = {
  vpc_name            = "${include.common.locals.name_prefix}-production-vpc"
  vpc_cidr            = include.common.locals.cidr_blocks.production
  vpc_azs             = include.common.locals.availability_zones
  vpc_private_subnets = ["10.246.1.0/24", "10.246.2.0/24", "10.246.3.0/24"]
  vpc_public_subnets  = ["10.246.10.0/24", "10.246.20.0/24", "10.246.30.0/24"]

  vpc_tags = merge(include.common.locals.common_tags, {
    Environment = "production"
  })
}
