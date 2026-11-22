terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_string" "unique" {
  length  = 5
  special = false
  upper   = false
}

locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.location_short}"
  tags = merge(
    {
      Project      = var.project_name
      Environment  = var.environment
      Owner        = var.owner
      ManagedBy    = "Terraform"
      CostCenter   = var.cost_center
      Criticality  = var.criticality
      Architecture = "Hub-and-Spoke-HA"
    },
    var.extra_tags
  )

  # Cloud-Init script for Frontend (Nginx reverse proxy to Internal LB)
  frontend_cloud_init = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx jq
    cat <<'HTML' > /var/www/html/index.html
    <!DOCTYPE html>
    <html>
    <head><title>Enterprise Hub-and-Spoke - Frontend</title></head>
    <body style="font-family: Arial; padding: 40px; text-align: center;">
      <h1 style="color: #0078D4;">Enterprise Azure Hub-and-Spoke High Availability</h1>
      <p>Tier: <strong>Frontend Linux VMSS</strong></p>
      <p>Availability Zone: Multizone Redundant</p>
      <p>Routing: Ingress through WAF_v2, Egress through Azure Firewall Premium</p>
    </body>
    </html>
HTML
    mkdir -p /var/www/html/healthz
    echo "OK" > /var/www/html/healthz/index.html
    systemctl restart nginx
  EOF

  # Cloud-Init script for Backend (Internal API service with /healthz)
  backend_cloud_init = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3
    mkdir -p /opt/app
    cat <<'PY' > /opt/app/server.py
import http.server
import socketserver

class HealthHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/healthz' or self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status":"healthy","tier":"backend-vmss","service":"core-api"}')
        else:
            self.send_response(404)
            self.end_headers()

with socketserver.TCPServer(("", 8080), HealthHandler) as httpd:
    httpd.serve_forever()
PY
    cat <<'SVC' > /etc/systemd/system/backend-api.service
[Unit]
Description=Backend API Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /opt/app/server.py
Restart=always

[Install]
WantedBy=multi-user.target
SVC
    systemctl daemon-reload
    systemctl enable backend-api
    systemctl start backend-api
  EOF
}

# ==============================================================================
# RESOURCE GROUPS
# ==============================================================================
module "hub_rg" {
  source   = "../../modules/resource-group"
  name     = "${local.name_prefix}-hub-rg"
  location = var.location
  tags     = local.tags
}

module "spoke_rg" {
  source   = "../../modules/resource-group"
  name     = "${local.name_prefix}-spoke-rg"
  location = var.location
  tags     = local.tags
}

module "data_rg" {
  source   = "../../modules/resource-group"
  name     = "${local.name_prefix}-data-rg"
  location = var.location
  tags     = local.tags
}

# ==============================================================================
# MONITORING & OBSERVABILITY
# ==============================================================================
module "monitoring" {
  source              = "../../modules/monitoring"
  name                = "${local.name_prefix}-law"
  resource_group_name = module.hub_rg.name
  location            = module.hub_rg.location
  retention_in_days   = 30
  alert_email         = "platform-sre@company.com"
  enable_vmss_alert   = true
  monitored_vmss_id   = module.frontend_vmss.id
  enable_appgw_alert  = var.enable_application_gateway
  monitored_appgw_id  = var.enable_application_gateway ? module.application_gateway[0].id : null
  tags                = local.tags
}

# ==============================================================================
# HUB VIRTUAL NETWORK & SUBNETS
# ==============================================================================
module "hub_vnet" {
  source              = "../../modules/virtual-network"
  name                = "${local.name_prefix}-hub-vnet"
  resource_group_name = module.hub_rg.name
  location            = module.hub_rg.location
  address_space       = var.hub_address_space
  tags                = local.tags
}

module "hub_subnets" {
  source               = "../../modules/subnet"
  resource_group_name  = module.hub_rg.name
  virtual_network_name = module.hub_vnet.name

  subnets = {
    AzureFirewallSubnet = {
      address_prefixes = ["10.0.1.0/26"]
    }
    AzureFirewallManagementSubnet = {
      address_prefixes = ["10.0.1.64/26"]
    }
    AzureBastionSubnet = {
      address_prefixes = ["10.0.2.0/26"]
    }
    GatewaySubnet = {
      address_prefixes = ["10.0.3.0/27"]
    }
    InboundDnsResolverSubnet = {
      address_prefixes = ["10.0.4.0/28"]
      delegations = [{
        name = "Microsoft.Network.dnsResolvers"
        service_delegation = {
          name    = "Microsoft.Network/dnsResolvers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }]
    }
    OutboundDnsResolverSubnet = {
      address_prefixes = ["10.0.4.16/28"]
      delegations = [{
        name = "Microsoft.Network.dnsResolvers"
        service_delegation = {
          name    = "Microsoft.Network/dnsResolvers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }]
    }
    SharedServicesSubnet = {
      address_prefixes  = ["10.0.5.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
  }

  depends_on = [module.hub_vnet]
}

# ==============================================================================
# SPOKE VIRTUAL NETWORK & SUBNETS
# ==============================================================================
module "spoke_vnet" {
  source              = "../../modules/virtual-network"
  name                = "${local.name_prefix}-spoke-vnet"
  resource_group_name = module.spoke_rg.name
  location            = module.spoke_rg.location
  address_space       = var.spoke_address_space
  tags                = local.tags
}

module "spoke_subnets" {
  source               = "../../modules/subnet"
  resource_group_name  = module.spoke_rg.name
  virtual_network_name = module.spoke_vnet.name

  subnets = {
    AppGatewaySubnet = {
      address_prefixes = ["10.1.1.0/24"]
    }
    FrontendSubnet = {
      address_prefixes  = ["10.1.2.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    InternalLbSubnet = {
      address_prefixes = ["10.1.3.0/24"]
    }
    BackendSubnet = {
      address_prefixes  = ["10.1.4.0/24"]
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
    }
    PrivateEndpointSubnet = {
      address_prefixes                  = ["10.1.5.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }

  depends_on = [module.spoke_vnet]
}

# ==============================================================================
# HUB SECURITY & OBSERVABILITY GATEWAYS
# ==============================================================================
module "firewall" {
  count                      = var.enable_firewall ? 1 : 0
  source                     = "../../modules/firewall"
  name                       = "${local.name_prefix}-afw"
  resource_group_name        = module.hub_rg.name
  location                   = module.hub_rg.location
  subnet_id                  = module.hub_subnets.subnet_ids["AzureFirewallSubnet"]
  sku_tier                   = var.firewall_sku_tier
  zones                      = ["1", "2", "3"]
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags
}

module "bastion" {
  count                      = var.enable_bastion ? 1 : 0
  source                     = "../../modules/bastion"
  name                       = "${local.name_prefix}-bas"
  resource_group_name        = module.hub_rg.name
  location                   = module.hub_rg.location
  subnet_id                  = module.hub_subnets.subnet_ids["AzureBastionSubnet"]
  sku                        = "Standard"
  zones                      = ["1", "2", "3"]
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags
}

module "vpn_gateway" {
  count                      = var.enable_vpn_gateway ? 1 : 0
  source                     = "../../modules/vpn-gateway"
  name                       = "${local.name_prefix}-vpngw"
  resource_group_name        = module.hub_rg.name
  location                   = module.hub_rg.location
  subnet_id                  = module.hub_subnets.subnet_ids["GatewaySubnet"]
  sku                        = "VpnGw2AZ"
  active_active              = true
  enable_bgp                 = false
  zones                      = ["1", "2", "3"]
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags
}

module "dns_resolver" {
  source                     = "../../modules/dns-resolver"
  name                       = "${local.name_prefix}-dnsres"
  resource_group_name        = module.hub_rg.name
  location                   = module.hub_rg.location
  virtual_network_id         = module.hub_vnet.id
  inbound_subnet_id          = module.hub_subnets.subnet_ids["InboundDnsResolverSubnet"]
  outbound_subnet_id         = module.hub_subnets.subnet_ids["OutboundDnsResolverSubnet"]
  linked_virtual_network_ids = [module.spoke_vnet.id]
  tags                       = local.tags
}

# ==============================================================================
# BIDIRECTIONAL VNET PEERING
# ==============================================================================
module "vnet_peering" {
  source                    = "../../modules/vnet-peering"
  hub_resource_group_name   = module.hub_rg.name
  hub_vnet_name             = module.hub_vnet.name
  hub_vnet_id               = module.hub_vnet.id
  spoke_resource_group_name = module.spoke_rg.name
  spoke_vnet_name           = module.spoke_vnet.name
  spoke_vnet_id             = module.spoke_vnet.id
  allow_gateway_transit     = var.enable_vpn_gateway
  use_remote_gateways       = false # Set to true once VPN Gateway is provisioned
  depends_on                = [module.hub_subnets, module.spoke_subnets]
}

# ==============================================================================
# ROUTE TABLES (UDR - CENTRALIZED HUB FIREWALL ROUTING)
# ==============================================================================
module "appgw_route_table" {
  source              = "../../modules/route-table"
  name                = "${local.name_prefix}-appgw-rt"
  resource_group_name = module.spoke_rg.name
  location            = module.spoke_rg.location
  subnet_ids          = [module.spoke_subnets.subnet_ids["AppGatewaySubnet"]]
  routes = [
    {
      name           = "Direct-Internet-Ingress"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
  tags = local.tags
}

module "frontend_route_table" {
  source              = "../../modules/route-table"
  name                = "${local.name_prefix}-frontend-rt"
  resource_group_name = module.spoke_rg.name
  location            = module.spoke_rg.location
  subnet_ids          = [module.spoke_subnets.subnet_ids["FrontendSubnet"]]
  routes = var.enable_firewall ? [
    {
      name                   = "Egress-Via-Hub-Firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall[0].private_ip
    }
  ] : []
  tags = local.tags
}

module "backend_route_table" {
  source              = "../../modules/route-table"
  name                = "${local.name_prefix}-backend-rt"
  resource_group_name = module.spoke_rg.name
  location            = module.spoke_rg.location
  subnet_ids          = [module.spoke_subnets.subnet_ids["BackendSubnet"]]
  routes = var.enable_firewall ? [
    {
      name                   = "Egress-Via-Hub-Firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.firewall[0].private_ip
    }
  ] : []
  tags = local.tags
}

# ==============================================================================
# NETWORK SECURITY GROUPS (NSG)
# ==============================================================================
module "appgw_nsg" {
  source              = "../../modules/nsg"
  name                = "${local.name_prefix}-appgw-nsg"
  resource_group_name = module.spoke_rg.name
  location            = module.spoke_rg.location
  subnet_ids          = [module.spoke_subnets.subnet_ids["AppGatewaySubnet"]]
  security_rules = [
    {
      name                       = "Allow-HTTP-Inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTP ingress traffic from Internet"
    },
    {
      name                       = "Allow-HTTPS-Inbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow HTTPS ingress traffic from Internet"
    },
    {
      name                       = "Allow-GatewayManager-Inbound"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "65200-65535"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
      description                = "Required for Azure Application Gateway v2 control plane"
    },
    {
      name                       = "Allow-AzureLoadBalancer-Inbound"
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      description                = "Allow health probe from Azure Load Balancer"
    }
  ]
  tags = local.tags
}

module "frontend_nsg" {
  source              = "../../modules/nsg"
  name                = "${local.name_prefix}-frontend-nsg"
  resource_group_name = module.spoke_rg.name
  location            = module.spoke_rg.location
  subnet_ids          = [module.spoke_subnets.subnet_ids["FrontendSubnet"]]
  security_rules = [
    {
      name                       = "Allow-Traffic-From-AppGateway"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "10.1.1.0/24"
      destination_address_prefix = "10.1.2.0/24"
      description                = "Allow traffic from App Gateway subnet only"
    },
    {
      name                       = "Allow-Bastion-SSH-Inbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.2.0/26"
      destination_address_prefix = "10.1.2.0/24"
      description                = "Allow SSH management from Azure Bastion Subnet only"
    },
    {
      name                       = "Deny-All-Other-Inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Default deny all other inbound traffic"
    }
  ]
  tags = local.tags
}

module "internal_lb_nsg" {
  source              = "../../modules/nsg"
  name                = "${local.name_prefix}-ilb-nsg"
  resource_group_name = module.spoke_rg.name
  location            = module.spoke_rg.location
  subnet_ids          = [module.spoke_subnets.subnet_ids["InternalLbSubnet"]]
  security_rules = [
    {
      name                       = "Allow-Frontend-To-ILB"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "10.1.2.0/24"
      destination_address_prefix = "10.1.3.0/24"
      description                = "Allow traffic from Frontend VMSS to ILB"
    },
    {
      name                       = "Allow-AzureLoadBalancer-Probe"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      description                = "Allow Azure Load Balancer health check probes"
    }
  ]
  tags = local.tags
}

module "backend_nsg" {
  source              = "../../modules/nsg"
  name                = "${local.name_prefix}-backend-nsg"
  resource_group_name = module.spoke_rg.name
  location            = module.spoke_rg.location
  subnet_ids          = [module.spoke_subnets.subnet_ids["BackendSubnet"]]
  security_rules = [
    {
      name                       = "Allow-Traffic-From-ILB"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "10.1.3.0/24"
      destination_address_prefix = "10.1.4.0/24"
      description                = "Allow traffic from Internal Load Balancer only"
    },
    {
      name                       = "Allow-Bastion-SSH-Inbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.2.0/26"
      destination_address_prefix = "10.1.4.0/24"
      description                = "Allow SSH management from Azure Bastion Subnet only"
    },
    {
      name                       = "Deny-All-Other-Inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Default deny all other inbound traffic"
    }
  ]
  tags = local.tags
}

module "pe_nsg" {
  source              = "../../modules/nsg"
  name                = "${local.name_prefix}-pe-nsg"
  resource_group_name = module.spoke_rg.name
  location            = module.spoke_rg.location
  subnet_ids          = [module.spoke_subnets.subnet_ids["PrivateEndpointSubnet"]]
  security_rules = [
    {
      name                       = "Allow-Backend-To-PE"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["443", "1433", "6380"]
      source_address_prefix      = "10.1.4.0/24"
      destination_address_prefix = "10.1.5.0/24"
      description                = "Allow database and storage calls from Backend VMSS"
    },
    {
      name                       = "Deny-All-Other-Inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny direct public internet access to private endpoints"
    }
  ]
  tags = local.tags
}

# ==============================================================================
# HIGH AVAILABILITY APPLICATION INFRASTRUCTURE
# ==============================================================================
module "application_gateway" {
  count                      = var.enable_application_gateway ? 1 : 0
  source                     = "../../modules/application-gateway"
  name                       = "${local.name_prefix}-appgw"
  resource_group_name        = module.spoke_rg.name
  location                   = module.spoke_rg.location
  subnet_id                  = module.spoke_subnets.subnet_ids["AppGatewaySubnet"]
  waf_mode                   = "Prevention"
  zones                      = ["1", "2", "3"]
  min_capacity               = 2
  max_capacity               = 10
  backend_port               = 80
  health_probe_path          = "/healthz"
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags
}

module "internal_lb" {
  source                     = "../../modules/internal-load-balancer"
  name                       = "${local.name_prefix}-ilb"
  resource_group_name        = module.spoke_rg.name
  location                   = module.spoke_rg.location
  subnet_id                  = module.spoke_subnets.subnet_ids["InternalLbSubnet"]
  zones                      = ["1", "2", "3"]
  frontend_port              = 8080
  backend_port               = 8080
  probe_protocol             = "Http"
  probe_path                 = "/healthz"
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags
}

module "frontend_vmss" {
  source                                       = "../../modules/linux-vmss"
  name                                         = "${local.name_prefix}-fe-vmss"
  resource_group_name                          = module.spoke_rg.name
  location                                     = module.spoke_rg.location
  sku                                          = var.frontend_vm_sku
  instances                                    = var.frontend_instances
  admin_username                               = var.admin_username
  admin_ssh_public_key                         = var.admin_ssh_public_key
  zones                                        = ["1", "2", "3"]
  subnet_id                                    = module.spoke_subnets.subnet_ids["FrontendSubnet"]
  application_gateway_backend_address_pool_ids = var.enable_application_gateway ? [module.application_gateway[0].backend_address_pool_id] : []
  custom_data                                  = local.frontend_cloud_init
  tags                                         = local.tags
}

module "backend_vmss" {
  source                                 = "../../modules/linux-vmss"
  name                                   = "${local.name_prefix}-be-vmss"
  resource_group_name                    = module.spoke_rg.name
  location                               = module.spoke_rg.location
  sku                                    = var.backend_vm_sku
  instances                              = var.backend_instances
  admin_username                         = var.admin_username
  admin_ssh_public_key                   = var.admin_ssh_public_key
  zones                                  = ["1", "2", "3"]
  subnet_id                              = module.spoke_subnets.subnet_ids["BackendSubnet"]
  load_balancer_backend_address_pool_ids = [module.internal_lb.backend_address_pool_id]
  custom_data                            = local.backend_cloud_init
  tags                                   = local.tags
}

# ==============================================================================
# PRIVATE DNS ZONES
# ==============================================================================
module "private_dns" {
  source              = "../../modules/private-dns"
  resource_group_name = module.hub_rg.name
  dns_zone_names = [
    "privatelink.database.windows.net",
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.documents.azure.com",
    "privatelink.redis.cache.windows.net"
  ]
  virtual_network_ids = {
    hub   = module.hub_vnet.id
    spoke = module.spoke_vnet.id
  }
  tags = local.tags
}

# ==============================================================================
# AZURE PAAS & PRIVATE ENDPOINT INFRASTRUCTURE
# ==============================================================================
module "key_vault" {
  source                        = "../../modules/key-vault"
  name                          = substr(replace("${local.name_prefix}-kv-${random_string.unique.result}", "-", ""), 0, 24)
  resource_group_name           = module.hub_rg.name
  location                      = module.hub_rg.location
  sku_name                      = "standard"
  purge_protection_enabled      = true
  public_network_access_enabled = false
  log_analytics_workspace_id    = module.monitoring.id
  tags                          = local.tags
}

module "key_vault_pe" {
  count                = var.enable_private_endpoints ? 1 : 0
  source               = "../../modules/private-endpoint"
  name                 = "${local.name_prefix}-kv-pe"
  resource_group_name  = module.spoke_rg.name
  location             = module.spoke_rg.location
  subnet_id            = module.spoke_subnets.subnet_ids["PrivateEndpointSubnet"]
  target_resource_id   = module.key_vault.id
  subresource_names    = ["vault"]
  private_dns_zone_ids = [module.private_dns.zone_ids["privatelink.vaultcore.azure.net"]]
  tags                 = local.tags
}

module "storage_account" {
  source                        = "../../modules/storage-account"
  name                          = replace(lower("${var.project_name}${var.environment}${random_string.unique.result}sa"), "-", "")
  resource_group_name           = module.data_rg.name
  location                      = module.data_rg.location
  replication_type              = "GRS"
  public_network_access_enabled = false
  log_analytics_workspace_id    = module.monitoring.id
  tags                          = local.tags
}

module "storage_pe" {
  count                = var.enable_private_endpoints ? 1 : 0
  source               = "../../modules/private-endpoint"
  name                 = "${local.name_prefix}-sa-pe"
  resource_group_name  = module.spoke_rg.name
  location             = module.spoke_rg.location
  subnet_id            = module.spoke_subnets.subnet_ids["PrivateEndpointSubnet"]
  target_resource_id   = module.storage_account.id
  subresource_names    = ["blob"]
  private_dns_zone_ids = [module.private_dns.zone_ids["privatelink.blob.core.windows.net"]]
  tags                 = local.tags
}

module "sql_database" {
  source                        = "../../modules/sql-database"
  server_name                   = "${local.name_prefix}-sqlsvr-${random_string.unique.result}"
  database_name                 = "${local.name_prefix}-db"
  resource_group_name           = module.data_rg.name
  location                      = module.data_rg.location
  admin_username                = var.sql_admin_username
  admin_password                = var.sql_admin_password
  public_network_access_enabled = false
  sku_name                      = "GP_Gen5_2"
  zone_redundant                = true
  log_analytics_workspace_id    = module.monitoring.id
  tags                          = local.tags
}

module "sql_pe" {
  count                = var.enable_private_endpoints ? 1 : 0
  source               = "../../modules/private-endpoint"
  name                 = "${local.name_prefix}-sql-pe"
  resource_group_name  = module.spoke_rg.name
  location             = module.spoke_rg.location
  subnet_id            = module.spoke_subnets.subnet_ids["PrivateEndpointSubnet"]
  target_resource_id   = module.sql_database.server_id
  subresource_names    = ["sqlServer"]
  private_dns_zone_ids = [module.private_dns.zone_ids["privatelink.database.windows.net"]]
  tags                 = local.tags
}

module "cosmos_db" {
  count                         = var.enable_cosmos_db ? 1 : 0
  source                        = "../../modules/cosmos-db"
  name                          = "${local.name_prefix}-cosmos-${random_string.unique.result}"
  resource_group_name           = module.data_rg.name
  location                      = module.data_rg.location
  zone_redundant                = true
  public_network_access_enabled = false
  log_analytics_workspace_id    = module.monitoring.id
  tags                          = local.tags
}

module "cosmos_pe" {
  count                = var.enable_cosmos_db && var.enable_private_endpoints ? 1 : 0
  source               = "../../modules/private-endpoint"
  name                 = "${local.name_prefix}-cosmos-pe"
  resource_group_name  = module.spoke_rg.name
  location             = module.spoke_rg.location
  subnet_id            = module.spoke_subnets.subnet_ids["PrivateEndpointSubnet"]
  target_resource_id   = module.cosmos_db[0].id
  subresource_names    = ["Sql"]
  private_dns_zone_ids = [module.private_dns.zone_ids["privatelink.documents.azure.com"]]
  tags                 = local.tags
}

module "redis" {
  count                         = var.enable_redis ? 1 : 0
  source                        = "../../modules/redis"
  name                          = "${local.name_prefix}-redis-${random_string.unique.result}"
  resource_group_name           = module.data_rg.name
  location                      = module.data_rg.location
  sku_name                      = "Premium"
  family                        = "P"
  capacity                      = 1
  zones                         = ["1", "2"]
  public_network_access_enabled = false
  log_analytics_workspace_id    = module.monitoring.id
  tags                          = local.tags
}

module "redis_pe" {
  count                = var.enable_redis && var.enable_private_endpoints ? 1 : 0
  source               = "../../modules/private-endpoint"
  name                 = "${local.name_prefix}-redis-pe"
  resource_group_name  = module.spoke_rg.name
  location             = module.spoke_rg.location
  subnet_id            = module.spoke_subnets.subnet_ids["PrivateEndpointSubnet"]
  target_resource_id   = module.redis[0].id
  subresource_names    = ["redisCache"]
  private_dns_zone_ids = [module.private_dns.zone_ids["privatelink.redis.cache.windows.net"]]
  tags                 = local.tags
}

# ==============================================================================
# BACKUP & DISASTER RECOVERY
# ==============================================================================
module "backup" {
  count                 = var.enable_backup ? 1 : 0
  source                = "../../modules/backup"
  name                  = "${local.name_prefix}-rsv"
  resource_group_name   = module.hub_rg.name
  location              = module.hub_rg.location
  storage_mode_type     = "GeoRedundant"
  retention_daily_count = 30
  tags                  = local.tags
}
