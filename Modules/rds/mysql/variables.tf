variable "rds_identifier" {}
variable "rds_db_engine" {
  type = list(object({
    engine               = string
    engine_version       = string
    major_engine_version = string
    family               = string
    instance_class       = string
    allocated_storage    = number
    multi_az             = bool
  }))
}
variable "rds_db_info" {
  type = list(object({
    db_name                     = string
    username                    = string
    port                        = number
    password_wo                 = string
    password_wo_version         = number
    manage_master_user_password = bool
    skip_final_snapshot         = bool
  }))
}
variable "rds_db_sg" {
  type = list(object({
    create_db_subnet_group = bool
    subnet_ids             = list(string)
    vpc_security_group_ids = string
  }))
}
