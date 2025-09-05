include "backend" {
  path = find_in_parent_folders()
}

include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "../../../_env/EC2"
}

inputs = {
  ec2_name              = "${include.common.locals.name_prefix}-develop-ec2"
  ec2_instance_type     = include.common.locals.instance_types.develop
  ec2_key_name          = include.common.locals.key_pair_name
  ec2_monitoring        = false
  ec2_subnet_id         = dependency.vpc.outputs.public_subnets[0]
  ec2_ebs_volumes = {
    "${include.common.locals.name_prefix}-develop-ec2-volume" = {
      size      = 30
      type      = "gp3"
      encrypted = true
    }
  }

  ec2_tags = merge(include.common.locals.common_tags, {
    Environment = "develop"
  })
}

dependency "vpc" {
  config_path = "../VPC"
}
