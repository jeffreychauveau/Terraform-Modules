terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
module "s3_bucket" {
  source                        = "terraform-aws-modules/s3-bucket/aws"
  bucket                        = var.bucket_name
  attach_lb_log_delivery_policy = var.lb_log_policy

  versioning = {
    enabled = var.versioning
  }

}