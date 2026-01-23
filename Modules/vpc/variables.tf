variable "vpc_name" {}
variable "vpc_cidr" {}
variable "enable_nat_gateway" {
  type    = bool
  default = false
}
variable "create_database_subnet_group" {
  type    = bool
  default = false
}
variable "availability_zones" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "database_subnets" {}
variable "environment" {}