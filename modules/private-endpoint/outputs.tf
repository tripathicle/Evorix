output "id" {
  description = "The ID of the Private Endpoint"
  value       = azurerm_private_endpoint.pe.id
}

output "name" {
  description = "The Name of the Private Endpoint"
  value       = azurerm_private_endpoint.pe.name
}

output "private_ip_address" {
  description = "The private IP address assigned to the Private Endpoint"
  value       = azurerm_private_endpoint.pe.private_service_connection[0].private_ip_address
}
