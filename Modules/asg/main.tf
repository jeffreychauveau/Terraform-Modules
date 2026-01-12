data "aws_ami" "amazon_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-20*-*kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_autoscaling_group" "my_asg" {
  min_size = var.asg_min_size
  max_size = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
  vpc_zone_identifier = var.asg_subnet_ids
  launch_template {
    id = aws_launch_template.asg_ec2.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "asg_ec2" {
  name = var.asg_name
  image_id = data.aws_ami.amazon_ami.id
  instance_type = var.asg_instance_type
  key_name  = "my-key"
  user_data = base64encode(var.user_data)
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.asg_ec2_sg]
  }
}


