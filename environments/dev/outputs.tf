# Dev Environment - outputs.tf

output "hub_resource_group_name" {
  value = module.hub_rg.name
}

output "spoke_resource_group_name" {
  value = module.spoke_rg.name
}

output "hub_virtual_network_name" {
  value = module.hub_vnet.name
}

output "spoke_virtual_network_name" {
  value = module.spoke_vnet.name
}

output "firewall_private_ip" {
  value = var.enable_firewall ? module.firewall[0].private_ip : null
}

output "application_gateway_public_ip" {
  value = var.enable_application_gateway ? module.application_gateway[0].public_ip : null
}

output "internal_load_balancer_private_ip" {
  value = module.internal_lb.private_ip
}

output "log_analytics_workspace_id" {
  value = module.monitoring.workspace_id
}
