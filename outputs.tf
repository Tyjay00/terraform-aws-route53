output "hosted_zone_id" {
  description = "The hosted zone ID"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.hosted_zone_id
}

output "name_servers" {
  description = "The name servers for the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : []
}

output "domain_name" {
  description = "The domain name"
  value       = var.domain_name
}

output "health_check_id" {
  description = "The health check ID"
  value       = var.enable_health_check ? aws_route53_health_check.main[0].id : ""
}