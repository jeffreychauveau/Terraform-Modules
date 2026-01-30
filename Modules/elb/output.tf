output "id" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.id
}
output "arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.arn
}
output "alb_security_group_id" {
  description = "ID of the security group"
  value       = module.alb.security_group_id
}
output "alb_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.alb.security_group_arn
}
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}
output "zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = module.alb.zone_id
}
output "alb_target_groups" {
  description = "Map of target groups created and their attributes"
  value       = module.alb.target_groups
}