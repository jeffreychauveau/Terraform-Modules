terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
module "dynamodb_table" {
  source                                = "terraform-aws-modules/dynamodb-table/aws"
  name                                  = var.db_table_info[0].name
  hash_key                              = var.db_table_info[0].hash_key
  range_key                             = var.db_table_info[0].range_key
  table_class                           = var.table_class
  deletion_protection_enabled           = false
  autoscaling_enabled                   = var.autoscaling_enabled
  ignore_changes_global_secondary_index = var.ignore_changes_global_secondary_index

  autoscaling_read = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 45
    max_capacity       = 10
  }

  autoscaling_write = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 45
    max_capacity       = 10
  }

  autoscaling_indexes = {
    TitleIndex = {
      read_max_capacity  = 30
      read_min_capacity  = 10
      write_max_capacity = 30
      write_min_capacity = 10
    }
  }
  attributes = [
    {
      name = var.db_table_info[0].hash_key
      type = "N"
    },
    {
      name = var.db_table_info[0].range_key
      type = "S"
    },
  ]
}