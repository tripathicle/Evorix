output "id" {
  description = "The ID of the Route Table"
  value       = azurerm_route_table.rt.id
}

output "name" {
  description = "The Name of the Route Table"
  value       = azurerm_route_table.rt.name
}

output "subnets" {
  description = "The Subnet IDs associated with the Route Table"
  value       = var.subnet_ids
}
