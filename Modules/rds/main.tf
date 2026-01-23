terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
module "db" {
  source = "terraform-aws-modules/rds/aws"
  ## REQUIRED Items
  identifier = var.rds_identifier

  ## rds_db_engine map
  engine               = var.rds_db_engine[0].engine
  engine_version       = var.rds_db_engine[0].engine_version
  major_engine_version = var.rds_db_engine[0].major_engine_version
  family               = var.rds_db_engine[0].family
  instance_class       = var.rds_db_engine[0].instance_class
  allocated_storage    = var.rds_db_engine[0].allocated_storage
  multi_az             = var.rds_db_engine[0].multi_az

  ## rds_db_info map
  db_name                     = var.rds_db_info[0].db_name
  username                    = var.rds_db_info[0].username
  port                        = var.rds_db_info[0].port
  password_wo                 = var.rds_db_info[0].password_wo
  password_wo_version         = var.rds_db_info[0].password_wo_version
  manage_master_user_password = var.rds_db_info[0].manage_master_user_password
  skip_final_snapshot         = var.rds_db_info[0].skip_final_snapshot

  ## rds_db_sg map
  create_db_subnet_group = var.rds_db_sg[0].create_db_subnet_group
  subnet_ids             = var.rds_db_sg[0].subnet_ids
  vpc_security_group_ids = [var.rds_db_sg[0].vpc_security_group_ids]

}

