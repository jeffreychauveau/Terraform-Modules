variable "sg_name" {}
variable "vpc_id" {}
variable "ingress_rules_cidr" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
variable "ingress_rules_sg" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    sg_id     = string
  }))
  default = []
}
variable "egress_rules_cidr" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
variable "egress_rules_sg" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    sg_id     = string
  }))
  default = []
}
