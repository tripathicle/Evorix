output "server_id" {
  description = "The ID of the SQL Server"
  value       = azurerm_mssql_server.sql.id
}

output "server_name" {
  description = "The Name of the SQL Server"
  value       = azurerm_mssql_server.sql.name
}

output "server_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "database_id" {
  description = "The ID of the SQL Database"
  value       = azurerm_mssql_database.db.id
}

output "database_name" {
  description = "The Name of the SQL Database"
  value       = azurerm_mssql_database.db.name
}
