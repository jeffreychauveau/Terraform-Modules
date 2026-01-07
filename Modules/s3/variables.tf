variable "bucket_name" {}
variable "bucket_acl" {
  default = "private"
}
variable "versioning" {
    type = bool
}
variable "lb_log_policy" {
  type = bool
}
