output "id" {
  description = "The ID of the Private DNS Resolver"
  value       = azurerm_private_dns_resolver.resolver.id
}

output "inbound_endpoint_ip" {
  description = "Private IP address of the inbound DNS endpoint"
  value       = azurerm_private_dns_resolver_inbound_endpoint.inbound.ip_configurations[0].private_ip_address
}

output "ruleset_id" {
  description = "The ID of the DNS forwarding ruleset"
  value       = azurerm_private_dns_resolver_dns_forwarding_ruleset.ruleset.id
}
