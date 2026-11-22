output "id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.id
}

output "name" {
  description = "The Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.name
}

output "workspace_id" {
  description = "The Workspace ID (GUID) of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.workspace_id
}

output "action_group_id" {
  description = "The ID of the platform alert action group"
  value       = azurerm_monitor_action_group.ag.id
}
