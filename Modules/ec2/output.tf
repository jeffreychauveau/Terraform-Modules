output "ec2_public_ips" {
  value = module.ec2_instance[*].public_ip
}
output "ec2_private_ips" {
  value = module.ec2_instance[*].private_ip
}
output "ec2_security_group_ids" {
  value = module.ec2_instance[*].security_group_id
}
output "ec2_amis" {
  value = module.ec2_instance[*].ami
}
output "ec2_instance_ids" {
  value = module.ec2_instance[*].id
}
output "ec2_instance_name" {
  value = var.instance_name
}
