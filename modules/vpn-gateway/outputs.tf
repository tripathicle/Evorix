output "id" {
  description = "The ID of the Virtual Network Gateway"
  value       = azurerm_virtual_network_gateway.vpngw.id
}

output "name" {
  description = "The Name of the Virtual Network Gateway"
  value       = azurerm_virtual_network_gateway.vpngw.name
}

output "public_ip_1" {
  description = "Primary Public IP of the Gateway"
  value       = azurerm_public_ip.pip1.ip_address
}

output "public_ip_2" {
  description = "Secondary Public IP of the Gateway (if active-active)"
  value       = var.active_active ? azurerm_public_ip.pip2[0].ip_address : null
}
