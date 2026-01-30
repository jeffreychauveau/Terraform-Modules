terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
module "zone" {
  source = "terraform-aws-modules/route53/aws"

  name        = "redneckrenovations.click"
  comment     = "Public zone for personal domain"
  create_zone = false

  records = var.record
}