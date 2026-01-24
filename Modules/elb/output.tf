output "id" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.id
}
output "alb_security_group_id" {
  value = module.alb.security_group_id
}
output "alb_dns_name" {
  value = module.alb.dns_name
}
output "zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = module.alb.zone_id
}
