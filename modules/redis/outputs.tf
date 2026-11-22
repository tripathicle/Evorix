output "id" {
  description = "The ID of the Azure Cache for Redis"
  value       = azurerm_redis_cache.redis.id
}

output "name" {
  description = "The Name of the Azure Cache for Redis"
  value       = azurerm_redis_cache.redis.name
}

output "hostname" {
  description = "The Hostname of the Azure Cache for Redis"
  value       = azurerm_redis_cache.redis.hostname
}

output "ssl_port" {
  description = "The SSL Port of the Azure Cache for Redis"
  value       = azurerm_redis_cache.redis.ssl_port
}
