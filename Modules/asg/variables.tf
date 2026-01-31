variable "asg_name" {}
variable "vpc_id" {}
variable "vpc_public_subnets" {}
variable "vpc_cidr_block" {}
variable "asg_min_size" {
  type = number
}
variable "asg_max_size" {
  type = number
}
variable "asg_desired_capacity" {
  type = number
}
variable "user_data" {}
variable "asg_instance_type" {
  default = "t4g.nano"
}
variable "alb_tg_arn" {}
variable "security_group_id" {}