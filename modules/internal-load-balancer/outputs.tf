output "id" {
  description = "The ID of the Internal Load Balancer"
  value       = azurerm_lb.ilb.id
}

output "name" {
  description = "The Name of the Internal Load Balancer"
  value       = azurerm_lb.ilb.name
}

output "private_ip" {
  description = "The private frontend IP address allocated to the Internal Load Balancer"
  value       = azurerm_lb.ilb.frontend_ip_configuration[0].private_ip_address
}

output "backend_address_pool_id" {
  description = "The ID of the ILB backend address pool"
  value       = azurerm_lb_backend_address_pool.backend_pool.id
}
