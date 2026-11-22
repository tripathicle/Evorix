output "id" {
  description = "ID of the Bastion host"
  value       = azurerm_bastion_host.bastion.id
}

output "name" {
  description = "Name of the Bastion host"
  value       = azurerm_bastion_host.bastion.name
}

output "dns_name" {
  description = "The FQDN for the Bastion Host"
  value       = azurerm_bastion_host.bastion.dns_name
}
