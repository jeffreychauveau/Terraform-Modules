provider "aws" {
  alias   = "east"
  region  = "us-east-1"
  profile = "default"
}
provider "aws" {
  alias   = "west"
  region  = "us-west-2"
  profile = "default"
}
/*
## EAST REGION CONFIGURATION
module "east-route53" {
  source = "../../Modules/r53"
  record = {
    alb_alias = {
      name = "web"
      type = "A"
      set_identifier = "us-east-1"
      weighted_routing_policy = {
        weight = 50
      }
      alias = {
        name = module.east-alb.alb_dns_name
        zone_id = module.east-alb.zone_id
        evaluate_target_health = true
      }
    }
  }
}*/
module "east-vpc" {
  source = "../../Modules/vpc"
  providers = {
    aws = aws.east
  }
  vpc_name           = "East-VPC"
  vpc_cidr           = "10.0.0.0/16"
  environment        = "east-dev"
  enable_nat_gateway = false
  availability_zones = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  database_subnets   = ["10.0.111.0/24", "10.0.112.0/24"]
}
/*module "east-ec2" {
  source                = "../../Modules/ec2"
  providers = {
    aws = aws.east
  }
  instance_name         = "east-ec2"
  subnet_ids            = module.east-vpc.public_subnets
  security_group_vpc_id = module.east-vpc.vpc_id
  security_group_id     = [module.east-http-sg.sg_id]
  ec2_count             = 1
  create_security_group = false
  eip                   = true
  user_data             = <<-EOF
      #!/bin/bash
      sudo dnf update -y
      sudo dnf install -y httpd
      sudo systemctl start httpd
      sudo systemctl enable httpd
      echo "<html><h1>Welcome to EAST $(hostname) over HTTPS! (Self-signed cert)</h1></html>" > /var/www/html/index.html
  EOF
}*/
module "east-http-sg" {
  source = "../../Modules/csg"
  providers = {
    aws = aws.east
  }
  sg_name = "east-http-sg"
  vpc_id  = module.east-vpc.vpc_id
  rules = [{
    ingress_ports = "http-80-tcp"
    ingress_sg_id = module.east-alb.alb_security_group_id
  }]
  create_rules = [{
    ingress_with_sg  = 1
    egress_with_cidr = 1
  }]
}
module "east-alb" {
  source = "../../Modules/elb"
  providers = {
    aws = aws.east
  }
  lb_name               = "alb"
  lb_type               = "application"
  public_subnet_ids     = module.east-vpc.public_subnets
  vpc_id                = module.east-vpc.vpc_id
  vpc_cidr_block        = module.east-vpc.vpc_cidr_block
  create_security_group = true
  ingress_rules = {
    "http-in" = {
      from_port = 80
      to_port   = 80
      protocol  = "HTTP"
      type      = "ingress"
      cidr_ipv4 = "0.0.0.0/0"
    }
    "https-in" = {
      from_port = 443
      to_port   = 443
      protocol  = "HTTPS"
      type      = "ingress"
      cidr_ipv4 = "0.0.0.0/0"
    }
  }
  egress_rules = {
    "http-out" = {
      from_port = 80
      to_port   = 80
      protocol  = "HTTP"
      type      = "egress"
      cidr_ipv4 = "0.0.0.0/0"
    }
  }
  lb_listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"
      priority = 100
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:us-east-1:753047898568:certificate/c63037a4-caac-44e7-b06e-3cc472e5e0d6"
      forward = {
        target_group_key = "http-tg"
      }
    }
  }
  ## Port that the ELB will connect to the EC2 Instance
  target_groups = {
    http-tg = {
      create_attachment = false
      name_prefix       = "web-tg"
      port              = 80
    }
  }
}
/*module "east-lambda" {
  source = "../../Modules/lambda"
  providers = {
    aws = aws.east
  }
  function_name = "RedneckRenovations-Site"
  description = "Redneck Renovations Website"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.14"
  source_path = "./src/lambda_function.py"
  create_lambda_function_url = true
}*/
module "east-eb-app" {
  source                = "../../Modules/beanstalk"
  app_name              = "Dev-App"
  environment           = "Development"
  bucket_name           = "elasticbeanstalk-us-east-1-753047898568"
  key                   = "app-v1.zip"
  vpc_id                = module.east-vpc.vpc_id
  private_subnet_ids    = module.east-vpc.private_subnets
  public_subnet_ids     = module.east-vpc.public_subnets
  ec2_security_groups   = module.east-http-sg.sg_id
  alb_security_group_id = module.east-https-sg.sg_id
  alb_arn               = module.east-alb.arn
  enable_shared_alb     = true
  enable_public_ip      = true
  asg_min_size          = 1
  asg_max_size          = 1
  instance_type         = "t4g.nano"
  SSLCertificate_arn    = "arn:aws:acm:us-east-1:753047898568:certificate/c63037a4-caac-44e7-b06e-3cc472e5e0d6"
}















/*
## WEST REGION CONFIGURATION
module "west-route53" {
  source = "../../Modules/r53"
  record = {
    alb_alias = {
      name = "web"
      type = "A"
      set_identifier = "us-west-1"
      weighted_routing_policy = {
        weight = 50
      }
      alias = {
        name = module.west-alb.alb_dns_name
        zone_id = module.west-alb.zone_id
        evaluate_target_health = true
      }
    }
  }
}
module "west-vpc" {
  source = "../../Modules/vpc"
  providers = {
    aws = aws.west
  }
  vpc_name = "West-VPC"
  vpc_cidr = "10.1.0.0/16"
  environment = "west-dev"
  enable_nat_gateway           = false
  availability_zones = ["us-west-2a","us-west-2b"]
  private_subnets = ["10.1.101.0/24","10.1.102.0/24"]
  public_subnets = ["10.1.1.0/24","10.1.2.0/24"]
  database_subnets = ["10.1.111.0/24","10.1.112.0/24"]
}
module "west-ec2" {
  source                = "../../Modules/ec2"
  providers = {
    aws = aws.west
  }
  instance_name         = "west-ec2"
  subnet_ids            = module.west-vpc.public_subnets
  security_group_vpc_id = module.west-vpc.vpc_id
  security_group_id     = [module.west-http-sg.sg_id]
  ec2_count             = 1
  create_security_group = false
  eip                   = true
  user_data             = <<-EOF
      #!/bin/bash
      sudo dnf update -y
      sudo dnf install -y httpd
      sudo systemctl start httpd
      sudo systemctl enable httpd
      echo "<html><h1>Welcome to WEST $(hostname) over HTTPS! (Self-signed cert)</h1></html>" > /var/www/html/index.html
  EOF
}
module "west-http-sg" {
  source = "../../Modules/csg"
  providers = {
    aws = aws.west
  }
  sg_name = "west-http-sg"
  vpc_id = module.west-vpc.vpc_id
  rules = [{
    ingress_ports = "http-80-tcp"
    ingress_sg_id = module.west-alb.alb_security_group_id
  }]
  create_rules = [{
    ingress_with_sg = 1
    egress_with_cidr = 1
  }]
}
module "west-alb" {
  source                = "../../Modules/elb"
  providers = {
    aws = aws.west
  }
  lb_name              = "alb"
  lb_type               = "application"
  public_subnet_ids     = module.west-vpc.public_subnets
  vpc_id                = module.west-vpc.vpc_id
  instance_ids          = module.west-ec2.ec2_instance_ids
  vpc_cidr_block        = module.west-vpc.vpc_cidr_block
  create_security_group = true
  ingress_rules = {
    "http-in" = {
      from_port = 80
      to_port   = 80
      protocol  = "HTTP"
      type      = "ingress"
      cidr_ipv4 = "0.0.0.0/0"
    }
    "https-in" = {
      from_port = 443
      to_port   = 443
      protocol  = "HTTPS"
      type      = "ingress"
      cidr_ipv4 = "0.0.0.0/0"
    }
  }
  egress_rules = {
    "http-out" = {
      from_port                    = 80
      to_port                      = 80
      protocol                     = "HTTP"
      type                         = "egress"
      cidr_ipv4 = "10.1.0.0/16"
    }
  }
  lb_listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:us-west-2:753047898568:certificate/f33f7b83-63e4-4cc0-bc69-557f81671f6c"
      forward = {
        target_group_key = "http-tg"
      }
    }
  }
  target_groups = {
    http-tg = {
      create_attachment = false
      name_prefix       = "web-tg"
      port              = 80
    }
  }
  instance_attachments = {
    target_group_key = "http-tg"
    port             = 80
  }
}*/













/*module "postgres-rds" {
  source = "../../Modules/rds/db"
  rds_identifier = "my-postgres"
  rds_db_engine = [{
    engine = "postgres"
    engine_version = "17"
    family = "postgres17"
    major_engine_version = "17"
    instance_class = "db.t4g.micro"
    multi_az = false
    allocated_storage = 5
  }]
  rds_db_info = [{
    db_name = "pgres"
    username = "myuser"
    port = 5432
    password_wo = "masterPassword"
    password_wo_version = 1
    manage_master_user_password = false
    skip_final_snapshot = true
  }]
  rds_db_sg = [{
   create_db_subnet_group = true
   subnet_ids = module.my-vpc.database_subnets
   vpc_security_group_ids = module.postgres-sg.sg_id
  }]
}*/

/*module "postgres-sg" {
  source = "../../Modules/csg"
  sg_name = "postgres-sg"
  vpc_id = module.my-vpc.vpc_id
  ingress_egress_rules = [{
    ingress_ports = "postgresql-tcp"
    ingress_cidr = "10.0.0.0/16"
    ingress_sg = "postgres-tcp"
  }]
  create_rules = [{
    ingress_with_cidr = 1
    egress_with_cidr = 1
  }]
}*/

/*module "my-dynamodb" {
  source = "../../Modules/rds/dynamodb"
  db_table_info = [{
    name      = "db-table"
    hash_key  = "id"
    range_key = "title"
  }]
  autoscaling_enabled = false
}*/

/*module "mysql-rds" {
  source = "../../Modules/rds/db"
  rds_identifier = "mysql-db"
  rds_db_engine = [{
    engine = "mysql"
    engine_version = "8.0"
    major_engine_version = "8.0"
    family = "mysql8.0"
    instance_class = "db.t4g.micro"
    allocated_storage = 5
    multi_az = false
  }]
  rds_db_info = [{
    db_name = "mytestdb"
    username = "admin"
    port = "3306"
    password_wo = "masterPassword"
    password_wo_version = 1
    manage_master_user_password = false
    skip_final_snapshot = false
  }]
  rds_db_sg = [{
    create_db_subnet_group = true
    subnet_ids = module.my-vpc.database_subnets
    vpc_security_group_ids = module.mysql-sg.sg_id
  }]
}*/

/*module "mysql-sg" {
  source = "../../Modules/csg"
  sg_name = "mysql-sg"
  vpc_id = module.my-vpc.vpc_id
  ingress_egress_rules = [{
    ingress_ports = "mysql-tcp"
    ingress_cidr = "10.0.0.0/16"
    ingress_sg = "mysql-tcp"
  }]
  create_rules = [{
    ingress_with_cidr = 1
    egress_with_cidr = 1
  }]
}*/

/*module "http-sg" {
  source = "../../Modules/csg"
  sg_name = "comp_sg"
  vpc_id = module.my-vpc.vpc_id
  ingress_egress_rules = [{
    ingress_sg = "http-80-tcp"
    ingress_sg_id = module.my-alb.alb_security_group_id
  }]
  create_rules = [{
    ingress_with_sg = 1
    egress_with_cidr = 1
  }]
}*/
## Use ASG only with VPC, Module creates security groups, elb, ec2, and sg
/*module "my-asg" {
  source = "../../Modules/asg"
  asg_name = "my-asg"
  vpc_id = module.my-vpc.vpc_id
  vpc_cidr_block = module.my-vpc.vpc_cidr_block
  vpc_public_subnets = module.my-vpc.public_subnets
  asg_min_size = 1
  asg_max_size = 2
  asg_desired_capacity = 1
  user_data = <<-EOF
      #!/bin/bash
      sudo dnf update -y
      sudo dnf install -y httpd
      sudo systemctl start httpd
      sudo systemctl enable httpd
      echo "<html><h1>Welcome to $(hostname) over HTTPS! (Self-signed cert)</h1></html>" > /var/www/html/index.html
  EOF
}*/
/*
module "my-s3" {
  source = "../../Modules/s3"
  bucket_name = "s3-87031"
  lb_log_policy = false
  versioning = false
}*/

/*
module "my-http-sg" {
  source  = "../../Modules/sg"
  sg_name = "http-sg"
  vpc_id  = module.my-vpc.vpc_id
  ingress_rules_sg = [{
    from_port = 80
    to_port   = 80
    protocol  = "TCP"
    sg_id     = module.my-alb.alb_security_group_id
  }]
  egress_rules_cidr = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}*/

/*module "my-alb" {
  source                = "../../Modules/elb"
  lb_name              = "alb"
  lb_type               = "application"
  public_subnet_ids     = module.my-vpc.public_subnets
  vpc_id                = module.my-vpc.vpc_id
  instance_ids          = module.my-ec2.ec2_instance_ids
  vpc_cidr_block        = module.my-vpc.vpc_cidr_block
  create_security_group = true
  ingress_rules = {
    "http-in" = {
      from_port = 80
      to_port   = 80
      protocol  = "HTTP"
      type      = "ingress"
      cidr_ipv4 = "0.0.0.0/0"
    }
    "https-in" = {
      from_port = 443
      to_port   = 443
      protocol  = "HTTPS"
      type      = "ingress"
      cidr_ipv4 = "0.0.0.0/0"
    }
  }
  egress_rules = {
    "http-out" = {
      from_port                    = 80
      to_port                      = 80
      protocol                     = "HTTP"
      type                         = "egress"
      cidr_ipv4 = "10.0.0.0/16"
    }
  }
  lb_listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:us-east-1:753047898568:certificate/c63037a4-caac-44e7-b06e-3cc472e5e0d6"
      forward = {
        target_group_key = "http-tg"
      }
    }
  }
  target_groups = {
    http-tg = {
      create_attachment = false
      name_prefix       = "web-tg"
      port              = 80
    }
  }
  instance_attachments = {
    target_group_key = "http-tg"
    port             = 80
  }
}*/

/*module "my-ssh-sg" {
  source  = "../../Modules/sg"
  sg_name = "ssh-sg"
  vpc_id  = module.my-vpc.vpc_id
  ingress_rules_sg = [{
    from_port = 22
    to_port   = 22
    protocol  = "TCP"
    sg_id     = module.my-nlb.nlb_security_group_id
  }]
  egress_rules_cidr = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}*/

/*module "my-nlb" {
  source                = "../../Modules/elb"
  lb_name              = "nlb"
  lb_type               = "network"
  public_subnet_ids     = module.my-vpc.public_subnets
  vpc_id                = module.my-vpc.vpc_id
  instance_ids          = module.my-ec2.ec2_instance_ids
  vpc_cidr_block        = module.my-vpc.vpc_cidr_block
  create_security_group = true
  ingress_rules = {
    "ssh-in" = {
      from_port = 22
      to_port   = 22
      cidr_ipv4 = "0.0.0.0/0"
    }
  }
  egress_rules = {
    "ssh-out" = {
      from_port                    = 22
      to_port                      = 22
      referenced_security_group_id = module.my-ssh-sg.sg_id
    }
  }
  lb_listeners = {
    ex-ssh = {
      port     = 22
      protocol = "TCP"
      forward = {
        target_group_key = "ssh-tg"
      }
    }
  }
  target_groups = {
    ssh-tg = {
      create_attachment = false
      name_prefix       = "ssh-tg"
      port              = 22
    }
  }
  instance_attachments = {
    target_group_key = "ssh-tg"
    port             = 22
  }
}*/
