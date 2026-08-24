output "company_domain" {
  description = "Internal company domain"
  value       = var.company_domain
}

output "users" {
  description = "Defined company users"
  value       = local.users
}

output "groups" {
  description = "Defined security groups"
  value       = local.groups
}

output "access_rules" {
  description = "Identity access-control model"
  value       = local.access_rules
}
