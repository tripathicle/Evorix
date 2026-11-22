output "id" {
  description = "The ID of the Azure Firewall"
  value       = azurerm_firewall.fw.id
}

output "name" {
  description = "The Name of the Azure Firewall"
  value       = azurerm_firewall.fw.name
}

output "private_ip" {
  description = "The private IP address of the Azure Firewall (used as next-hop for UDRs)"
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

output "public_ip" {
  description = "The public IP address of the Azure Firewall"
  value       = azurerm_public_ip.fw_pip.ip_address
}

output "policy_id" {
  description = "The ID of the Azure Firewall Policy"
  value       = azurerm_firewall_policy.policy.id
}
