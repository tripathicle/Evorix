output "id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.nsg.id
}

output "name" {
  description = "The Name of the Network Security Group"
  value       = azurerm_network_security_group.nsg.name
}

output "rules" {
  description = "Map of created security rules"
  value       = azurerm_network_security_rule.rules
}
