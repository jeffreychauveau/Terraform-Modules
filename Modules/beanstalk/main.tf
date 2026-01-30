terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
# Optional: data source to get latest platform version (recommended)
data "aws_elastic_beanstalk_solution_stack" "nodejs" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux 2023 v6.* running Node\\.js 2[2-9]$"
}
data "aws_elastic_beanstalk_solution_stack" "python" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux 2023 v4.* running Python 3.[1-9][1-9]$"
}
resource "aws_elastic_beanstalk_application" "app" {
  name        = var.app_name
  description = "Sample web app deployed via Terraform"
}
# New versions for code updates (this is how you "reuse" the env)
resource "aws_elastic_beanstalk_application_version" "v1" {
  name        = "v1-${formatdate("YYYYMMDD-HHmm", timestamp())}" # or use git sha / semver
  application = aws_elastic_beanstalk_application.app.name
  bucket      = var.bucket_name
  key         = var.key

  # Optional: depends_on if upload happens externally
}
resource "aws_elastic_beanstalk_environment" "env" {
  name                = var.environment
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.nodejs.name
  version_label       = aws_elastic_beanstalk_application_version.v1.name # ← this is what you change to "reuse"

  # ──────────────────────────────────────────────
  #  VPC & Subnets (required when using custom VPC)
  # ──────────────────────────────────────────────
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets" # EC2 instance subnets (usually private)
    value     = join(",", var.public_subnet_ids)
  }
  # ──────────────────────────────────────────────
  #  Enable public IP on the EC2 instances
  # ──────────────────────────────────────────────
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = var.enable_public_ip # ← This is the key line
  }
  # ──────────────────────────────────────────────
  #  Choose load balancer type
  # ──────────────────────────────────────────────
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application" # "application" | "network"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerIsShared"
    value     = var.enable_shared_alb
  }
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SharedLoadBalancer"
    value     = var.alb_arn # or .id
  }
  # Optional: single-instance (classic LB) for cheap testing
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.asg_min_size
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.asg_max_size
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets" # Load balancer subnets (must be public for internet-facing)
    value     = join(",", var.private_subnet_ids)
  }
  # Optional: make it cheaper/faster for demo
  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = var.instance_type
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.ec2_security_groups
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Rules"
    value     = "default"   # ← key line: forces the default rule to  be created in the HTTPS:443 listener
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name = "SSLCertificateArns"
    value = var.SSLCertificate_arn
  }
  # Use the standard AWS-managed instance profile (works in most regions/accounts)
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role" # ← This is the default name
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "DisableDefaultEC2SecurityGroup"
    value     = true
  }
  # Optional: environment variables
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENVIRONMENT"
    value     = var.environment
  }
  # Tags
  tags = {
    Name        = "${var.app_name}-environment"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
