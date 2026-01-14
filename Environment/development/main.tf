provider "aws" {
  region = "us-east-1"
  profile = "default"
}

module "my-vpc" {
  source      = "../../Modules/vpc"
  vpc_name    = "my-vpc-87031"
  vpc_cidr    = "10.0.0.0/16"
  environment = "development"
  enable_nat_gateway = false
}

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

/*module "my-ec2" {
  source                = "../../Modules/ec2"
  instance_name         = "ec2-87031"
  subnet_ids            = module.my-vpc.public_subnets
  security_group_vpc_id = module.my-vpc.vpc_id
  security_group_id     = [module.http-sg.sg_id]
  ec2_count             = 1
  create_security_group = false
  eip                   = true
  user_data             = <<-EOF
      #!/bin/bash
      sudo dnf update -y
      sudo dnf install -y httpd
      sudo systemctl start httpd
      sudo systemctl enable httpd
      echo "<html><h1>Welcome to $(hostname) over HTTPS! (Self-signed cert)</h1></html>" > /var/www/html/index.html
  EOF
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
