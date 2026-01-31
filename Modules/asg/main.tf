terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
data "aws_ami" "amazon_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-*arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name            = var.asg_name
  use_name_prefix = false
  instance_name   = "my-asg-inst"

  ignore_desired_capacity_changes = true

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  wait_for_capacity_timeout = 0
  default_instance_warmup   = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.vpc_public_subnets
  #  service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn

  # Traffic source attachment
  traffic_source_attachments = {
    ex-alb = {
      traffic_source_identifier = var.alb_tg_arn
      traffic_source_type       = "elbv2" # default
    }
  }

  # Launch template
  launch_template_name        = var.asg_name
  launch_template_description = "Complete launch template example"
  update_default_version      = true

  image_id          = data.aws_ami.amazon_ami.image_id
  instance_type     = var.asg_instance_type
  user_data         = base64encode(var.user_data)
  ebs_optimized     = true
  enable_monitoring = false

  create_iam_instance_profile = true
  iam_role_name               = var.asg_name
  iam_role_path               = "/ec2/"
  iam_role_description        = "Complete IAM role example"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  network_interfaces = [{
    security_groups             = [var.security_group_id]
    associate_public_ip_address = true

  }]
}