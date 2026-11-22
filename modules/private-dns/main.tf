# Private DNS Module - main.tf

resource "azurerm_private_dns_zone" "zone" {
  for_each            = toset(var.dns_zone_names)
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  zone_vnet_links = flatten([
    for zone_name in var.dns_zone_names : [
      for vnet_name, vnet_id in var.virtual_network_ids : {
        key       = "${vnet_name}-${zone_name}"
        zone_name = zone_name
        vnet_id   = vnet_id
        vnet_name = vnet_name
      }
    ]
  ])
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each              = { for item in local.zone_vnet_links : item.key => item }
  name                  = "link-${each.value.vnet_name}-${substr(sha256(each.value.zone_name), 0, 10)}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zone[each.value.zone_name].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}
