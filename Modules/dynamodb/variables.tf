variable "table_class" {
  default = "STANDARD"
}
variable "autoscaling_enabled" {
  type    = bool
  default = false
}
variable "ignore_changes_global_secondary_index" {
  type    = bool
  default = true
}
variable "db_table_info" {
  type = list(object({
    name      = string
    hash_key  = string
    range_key = string
  }))
}