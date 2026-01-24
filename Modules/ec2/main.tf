terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
data "aws_ami" "amazon_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-*arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = var.instance_name
  ami                         = data.aws_ami.amazon_ami.id
  instance_type               = var.instance_type
  key_name                    = "my-key"
  subnet_id                   = element(var.subnet_ids, count.index)
  security_group_vpc_id       = var.security_group_vpc_id
  associate_public_ip_address = var.eip
  create_eip                  = var.eip
  count                       = var.ec2_count
  create_security_group       = var.create_security_group
  vpc_security_group_ids      = var.security_group_id

  user_data = var.user_data

  tags = {
    Name        = var.instance_name
    Environment = "development"
  }
}