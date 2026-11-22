# Route Table Module - main.tf

resource "azurerm_route_table" "rt" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  bgp_route_propagation_enabled = !var.disable_bgp_route_propagation
  tags                          = var.tags
}

resource "azurerm_route" "routes" {
  for_each = { for r in var.routes : r.name => r }

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rt.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = lookup(each.value, "next_hop_in_ip_address", null)
}

resource "azurerm_subnet_route_table_association" "assoc" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = azurerm_route_table.rt.id
}
