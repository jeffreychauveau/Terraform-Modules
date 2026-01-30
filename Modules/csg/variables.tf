variable "sg_name" {}
variable "vpc_id" {}
variable "rules" {
  type = list(object({
    ingress_ports = optional(string, "all-all")
    ingress_cidr  = optional(string, "0.0.0.0/0")
    ingress_sg_id = optional(string)
    egress_ports  = optional(string, "all-all")
    egress_cidr   = optional(string, "0.0.0.0/0")
    egress_sg_id  = optional(string)
  }))
}
variable "create_rules" {
  type = list(object({
    ingress_with_cidr = optional(number, 0)
    ingress_with_sg   = optional(number, 0)
    egress_with_cidr  = optional(number, 0)
    egress_with_sg    = optional(number, 0)
  }))
}