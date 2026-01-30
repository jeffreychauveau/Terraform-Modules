terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = var.lb_name
  load_balancer_type         = var.lb_type
  subnets                    = var.public_subnet_ids
  vpc_id                     = var.vpc_id
  enable_deletion_protection = false
  create_security_group      = var.create_security_group

  security_group_ingress_rules = {
    for key, rule in var.ingress_rules : key => {
      from_port                    = rule.from_port
      to_port                      = rule.to_port
      protocol                     = rule.protocol
      type                         = rule.type
      cidr_ipv4                    = rule.cidr_ipv4
      referenced_security_group_id = rule.referenced_security_group_id
    }
  }

  security_group_egress_rules = {
    for key, rule in var.egress_rules : key => {
      from_port                    = rule.from_port
      to_port                      = rule.to_port
      protocol                     = rule.protocol
      type                         = rule.type
      cidr_ipv4                    = rule.cidr_ipv4
      referenced_security_group_id = rule.referenced_security_group_id
    }
  }

  listeners     = var.lb_listeners
  target_groups = var.target_groups
  #  additional_target_group_attachments = local.attachments
}

/*locals {
  instance_ids = var.instance_ids
  attachments = {
    for idx, inst_id in local.instance_ids : idx => {
      target_group_key = var.instance_attachments.target_group_key
      target_id        = inst_id
      port             = var.instance_attachments.port
    }
  }
}*/
