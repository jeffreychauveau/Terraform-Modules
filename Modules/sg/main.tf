resource "aws_security_group" "sg" {
  name   = var.sg_name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules_cidr

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  dynamic "ingress" {
    for_each = var.ingress_rules_sg

    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = [ingress.value.sg_id]
    }
  }
  dynamic "egress" {
    for_each = var.egress_rules_cidr

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = var.egress_rules_sg

    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      security_groups = [egress.value.sg_id]
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
