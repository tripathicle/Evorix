output "id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "name" {
  description = "The Name of the Application Gateway"
  value       = azurerm_application_gateway.appgw.name
}

output "public_ip" {
  description = "The public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "backend_address_pool_id" {
  description = "The ID of the default backend address pool"
  value       = [for pool in azurerm_application_gateway.appgw.backend_address_pool : pool.id if pool.name == "frontend-backend-pool"][0]
}
