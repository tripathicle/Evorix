output "id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "name" {
  description = "The Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "address_space" {
  description = "The address space of the Virtual Network"
  value       = azurerm_virtual_network.vnet.address_space
}

output "guid" {
  description = "The GUID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.guid
}
