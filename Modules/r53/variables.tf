variable "record" {
  type = map(object({
    name                    = string
    type                    = string
    aws_region              = optional(string)
    records                 = optional(list(string))
    set_identifier          = optional(string)
    weighted_routing_policy = optional(object({ weight = number }))
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, false)
    }))
  }))
}
