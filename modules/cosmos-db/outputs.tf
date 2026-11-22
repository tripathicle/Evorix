output "id" {
  description = "The ID of the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.cosmos.id
}

output "name" {
  description = "The Name of the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.cosmos.name
}

output "endpoint" {
  description = "The endpoint of the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.cosmos.endpoint
}
