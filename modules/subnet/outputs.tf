output "subnets" {
  description = "Map of the created subnet objects"
  value       = azurerm_subnet.subnet
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet name to address prefixes"
  value       = { for k, v in azurerm_subnet.subnet : k => v.address_prefixes }
}
