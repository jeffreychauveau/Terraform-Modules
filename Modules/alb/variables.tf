variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)

}
variable "lb_name" {}
variable "vpc_id" {}
variable "lb_type" {}
variable "instance_ids" {}
variable "vpc_cidr_block" {}
variable "create_security_group" {
  type = bool
}
variable "ingress_rules" {
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = optional(string, "HTTP")
    type        = optional(string, "ingress")
    referenced_security_group_id = optional(string)
    cidr_ipv4   = optional(string)
    description = optional(string)
  }))
  default = {}
}
variable "egress_rules" {
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = optional(string, "HTTP")
    type        = optional(string, "egress")
    referenced_security_group_id = optional(string)
    cidr_ipv4   = optional(string)
    description = optional(string)
  }))
  default = {}
}
variable "lb_listeners" {
  description = "Map of LB listeners"
  type = map(object({
    port            = number
    protocol        = string
    certificate_arn = optional(string) # Required for HTTPS
    ssl_policy      = optional(string)
    action_type     = optional(string, "redirect") # forward, redirect, fixed-response
    redirect = optional(object({
      port        = string
      protocol    = string
      status_code = string
    }))
    forward = optional(object({
      target_group_key = string
    }))
  }))
  default = {}
}
variable "target_groups" {
  description = "Map of target groups"
  type = map(object({
    create_attachment = optional(bool, true)
    name_prefix       = string
    port              = number
    protocol          = optional(string, "HTTP")
    target_type       = optional(string, "instance")
  }))
  default = {}
}
variable "instance_attachments" {
  description = "Map of additional instance attachments across target groups. Key is arbitrary."
  type = object({
    target_group_key = string
    port             = number
  })
  default = {
    target_group_key = null
    port             = null
  }
}