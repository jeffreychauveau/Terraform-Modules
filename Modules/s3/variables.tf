variable "bucket_name" {}
variable "bucket_acl" {}
variable "versioning" {
    type = bool
}
variable "lb_log_policy" {
  type = bool
}
