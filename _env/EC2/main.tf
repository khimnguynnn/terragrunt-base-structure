module "EC2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name          = var.ec2_name
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name
  monitoring    = var.ec2_monitoring
  subnet_id     = var.ec2_subnet_id
  # vpc_security_group_ids = [var.ec2_security_group_id]
  ebs_volumes = var.ec2_ebs_volumes

  tags = merge(var.ec2_tags, {
    terraform = "true"
  })
}
