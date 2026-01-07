module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = var.bucket_name
  acl = var.bucket_acl
  attach_lb_log_delivery_policy  = var.lb_log_policy

  versioning = {
    enabled = var.versioning
  }

}