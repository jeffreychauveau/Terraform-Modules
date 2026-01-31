terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
# Create a new load balancer attachment
resource "aws_alb_target_group_attachment" "elb" {
  target_group_arn = var.target_group_arn
  target_id        = var.target_ec2_id
}

