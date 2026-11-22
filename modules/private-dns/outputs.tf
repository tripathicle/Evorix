output "zone_ids" {
  description = "Map of Private DNS Zone names to their Resource IDs"
  value       = { for k, v in azurerm_private_dns_zone.zone : k => v.id }
}

output "zone_names" {
  description = "List of created Private DNS Zone names"
  value       = [for k, v in azurerm_private_dns_zone.zone : v.name]
}
