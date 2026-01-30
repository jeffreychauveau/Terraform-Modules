terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
module "sg" {
  source = "terraform-aws-modules/security-group/aws"
  name   = var.sg_name
  vpc_id = var.vpc_id

  computed_ingress_with_cidr_blocks = [{
    rule        = var.rules[0].ingress_ports
    cidr_blocks = var.rules[0].ingress_cidr
  }]
  number_of_computed_ingress_with_cidr_blocks = var.create_rules[0].ingress_with_cidr

  computed_ingress_with_source_security_group_id = [{
    rule                     = var.rules[0].ingress_ports
    source_security_group_id = var.rules[0].ingress_sg_id
  }]
  number_of_computed_ingress_with_source_security_group_id = var.create_rules[0].ingress_with_sg

  computed_egress_with_cidr_blocks = [{
    rule        = var.rules[0].egress_ports
    cidr_blocks = var.rules[0].egress_cidr
  }]
  number_of_computed_egress_with_cidr_blocks = var.create_rules[0].egress_with_cidr

  computed_egress_with_source_security_group_id = [{
    rule                     = var.rules[0].egress_ports
    source_security_group_id = var.rules[0].egress_sg_id
  }]
  number_of_computed_egress_with_source_security_group_id = var.create_rules[0].egress_with_sg
}