output "id" {
  description = "The ID of the Linux Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "name" {
  description = "The Name of the Linux Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.name
}

output "principal_id" {
  description = "System Assigned Managed Identity Principal ID"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
}
