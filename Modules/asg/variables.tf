variable "asg_name" {}
variable "vpc_id" {}
variable "asg_min_size" {
  type = number
}
variable "asg_max_size" {
  type = number
}
variable "asg_desired_capacity" {
  type = number
}
variable "asg_subnet_ids" {}
variable "user_data" {}
variable "asg_instance_type" {
  default = "t3a.nano"
}
variable "asg_ec2_sg" {}
