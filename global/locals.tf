# Global local constants and default port definitions

locals {
  # Default Subnet CIDR Allocations
  default_hub_cidr   = ["10.0.0.0/16"]
  default_spoke_cidr = ["10.1.0.0/16"]

  # Standard Subnets in Hub
  hub_subnets = {
    AzureFirewallSubnet = {
      address_prefixes  = ["10.0.1.0/26"]
      service_endpoints = []
    }
    AzureFirewallManagementSubnet = {
      address_prefixes  = ["10.0.1.64/26"]
      service_endpoints = []
    }
    AzureBastionSubnet = {
      address_prefixes  = ["10.0.2.0/26"]
      service_endpoints = []
    }
    GatewaySubnet = {
      address_prefixes  = ["10.0.3.0/27"]
      service_endpoints = []
    }
    InboundDnsResolverSubnet = {
      address_prefixes  = ["10.0.4.0/28"]
      service_endpoints = []
      delegations = [{
        name = "Microsoft.Network.dnsResolvers"
        service_delegation = {
          name    = "Microsoft.Network/dnsResolvers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }]
    }
    OutboundDnsResolverSubnet = {
      address_prefixes  = ["10.0.4.16/28"]
      service_endpoints = []
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

  # Standard Subnets in Spoke
  spoke_subnets = {
    AppGatewaySubnet = {
      address_prefixes  = ["10.1.1.0/24"]
      service_endpoints = []
    }
    FrontendSubnet = {
      address_prefixes  = ["10.1.2.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
    InternalLbSubnet = {
      address_prefixes  = ["10.1.3.0/24"]
      service_endpoints = []
    }
    BackendSubnet = {
      address_prefixes  = ["10.1.4.0/24"]
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
    }
    PrivateEndpointSubnet = {
      address_prefixes  = ["10.1.5.0/24"]
      service_endpoints = []
    }
  }

  # Private DNS Zone Names for Azure PaaS
  private_dns_zones = {
    sql        = "privatelink.database.windows.net"
    blob       = "privatelink.blob.core.windows.net"
    vault      = "privatelink.vaultcore.azure.net"
    cosmos_sql = "privatelink.documents.azure.com"
    redis      = "privatelink.redis.cache.windows.net"
  }
}
