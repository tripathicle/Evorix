# Azure Private DNS Resolver Module - main.tf

resource "azurerm_private_dns_resolver" "resolver" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.virtual_network_id
  tags                = var.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "inbound" {
  name                    = "${var.name}-inbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.resolver.id
  location                = var.location

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = var.inbound_subnet_id
  }

  tags = var.tags
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "outbound" {
  name                    = "${var.name}-outbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.resolver.id
  location                = var.location
  subnet_id               = var.outbound_subnet_id
  tags                    = var.tags
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "ruleset" {
  name                                       = "${var.name}-ruleset"
  resource_group_name                        = var.resource_group_name
  location                                   = var.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.outbound.id]
  tags                                       = var.tags
}

resource "azurerm_private_dns_resolver_forwarding_rule" "rules" {
  for_each                  = var.forwarding_rules
  name                      = each.key
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.ruleset.id
  domain_name               = each.value.domain_name
  enabled                   = lookup(each.value, "enabled", true)

  dynamic "target_dns_servers" {
    for_each = each.value.target_dns_servers
    content {
      ip_address = target_dns_servers.value.ip_address
      port       = lookup(target_dns_servers.value, "port", 53)
    }
  }
}

resource "azurerm_private_dns_resolver_virtual_network_link" "vnet_links" {
  count                     = length(var.linked_virtual_network_ids)
  name                      = "link-${count.index}"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.ruleset.id
  virtual_network_id        = var.linked_virtual_network_ids[count.index]
}
