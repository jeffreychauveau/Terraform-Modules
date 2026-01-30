variable "app_name" {
  description = "Application name"
  type        = string
  default     = "terraform-eb-app"
}
variable "bucket_name" {}
variable "key" {}
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "environment" {}
variable "ec2_security_groups" {}
variable "alb_security_group_id" {}
variable "alb_arn" {}
variable "enable_shared_alb" {
  type = bool
}
variable "enable_public_ip" {
  type = bool
}
variable "asg_min_size" {}
variable "asg_max_size" {}
variable "instance_type" {}
variable "SSLCertificate_arn" {}
