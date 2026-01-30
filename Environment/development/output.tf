/*output "public_ip" {
  value = module.my-ec2.ec2_public_ips
}
output "ec2_private_ips" {
  value = module.my-ec2.ec2_private_ips
}
output "ec2_instance_ids" {
  value = module.my-ec2.ec2_instance_ids
}*/
output "alb_security_group_id" {
  value = module.east-alb.alb_security_group_id
}
output "alb_security_group_arn" {
  value = module.east-alb.alb_security_group_arn
}
output "alb_dns_name" {
  value = module.east-alb.alb_dns_name
}
output "alb_arn" {
  value = module.east-alb.arn
}
output "alb_target_groups" {
  value = module.east-alb.alb_target_groups
}
/*output "nlb_dns_name" {
  value = module.my-nlb.nlb_dns_name
}*/