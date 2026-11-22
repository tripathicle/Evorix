# Standardized Tags for Governance, Compliance, and Cost Management

locals {
  default_tags = {
    Project       = var.project_name
    Environment   = var.environment
    Owner         = var.owner
    ManagedBy     = "Terraform"
    CostCenter    = var.cost_center
    Criticality   = var.criticality
    ProvisionDate = timestamp()
    Architecture  = "Hub-and-Spoke-HA"
  }

  merged_tags = merge(local.default_tags, var.extra_tags)
}
