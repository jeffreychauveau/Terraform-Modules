variable "instance_type" {
  default = "t4g.nano"
}
variable "instance_name" {}
variable "subnet_ids" {}
variable "security_group_vpc_id" {}
variable "ec2_count" {
  default = 1
}
variable "user_data" {}
variable "security_group_id" {}
variable "create_security_group" {
  type = bool
}
variable "eip" {
  type = bool
}