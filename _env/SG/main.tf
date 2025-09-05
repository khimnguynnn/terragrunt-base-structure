module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name                = var.sg_name
  description         = var.sg_description
  vpc_id              = var.sg_vpc_id
  ingress_cidr_blocks = var.sg_ingress_cidr_blocks

  tags = merge(var.sg_tags, {
    terraform = "true"
  })
}
