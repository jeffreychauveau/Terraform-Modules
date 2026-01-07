variable "vpc_name" {}
variable "vpc_cidr" {}
variable "enable_nat_gateway" {
  type = bool
}
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}
variable "private_subnets" {
  default = [
    "10.0.101.0/24",
  "10.0.102.0/24", ]
  #    "10.0.3.0/24"]
}
variable "public_subnets" {
  default = [
    "10.0.1.0/24",
  "10.0.2.0/24", ]
  #    "10.0.103.0/24"]
}
variable "environment" {}