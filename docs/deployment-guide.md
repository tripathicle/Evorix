# Enterprise Deployment Guide

## 1. Prerequisites

Before deploying the Enterprise Hub-and-Spoke Landing Zone, verify the following prerequisites:

1. **Azure Subscription**: Active subscription with `Owner` or `User Access Administrator` + `Contributor` permissions.
2. **Azure CLI**: Version `2.50.0` or higher (`az --version`).
3. **Terraform**: Version `1.5.0` or higher (`terraform version`).
4. **Git**: Installed and configured for version control.
5. **OpenSSH Key**: Generated SSH keypair for Linux VMSS administration:
   ```bash
   ssh-keygen -t ed25519 -C "enterprise-admin@company.com" -f ~/.ssh/azure_landing_zone_id
   ```

---

## 2. Phase 1: Bootstrapping Remote Terraform State

To establish a secure, collaborative, locked remote state backend, deploy the bootstrap state storage first:

```bash
# 1. Navigate to the bootstrap directory
cd bootstrap/terraform-backend

# 2. Review variables or create terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

# 3. Initialize and apply bootstrap
terraform init
terraform plan -out=bootstrap.tfplan
terraform apply bootstrap.tfplan
```

### Capturing Backend Outputs
Upon completion, the bootstrap outputs the backend configuration. Note the generated Storage Account name:
```bash
terraform output backend_config_template
```

---

## 3. Phase 2: Environment Provisioning

Deploy environments in order: `dev` -> `staging` -> `prod`.

### Deploying the Production Environment

```bash
# 1. Navigate to production environment
cd environments/prod

# 2. Configure backend.tf
# Uncomment the backend "azurerm" block in backend.tf and insert your storage account name.

# 3. Initialize Terraform with remote backend
terraform init

# 4. Review the Terraform Plan
terraform plan -var-file="terraform.tfvars" -out="prod.tfplan"

# 5. Apply with Production Approvals
terraform apply "prod.tfplan"
```

---

## 4. Phase 3: Post-Deployment Verification

Execute the following post-deployment sanity checks:

1. **Verify Hub-to-Spoke Peering**:
   ```bash
   az network vnet peering list --resource-group gd-ent-prod-eus-hub-rg --vnet-name gd-ent-prod-eus-hub-vnet -o table
   ```
   *Expected status: `Connected` in both directions.*

2. **Verify Application Gateway Ingress**:
   Retrieve the Application Gateway public IP:
   ```bash
   APPGW_IP=$(az network public-ip show --resource-group gd-ent-prod-eus-spoke-rg --name gd-ent-prod-eus-appgw-pip --query ipAddress -o tsv)
   curl -I "http://${APPGW_IP}/healthz"
   ```
   *Expected response: HTTP 200 OK.*

3. **Verify Private DNS Resolution**:
   From a VM inside `FrontendSubnet` or `BackendSubnet` via Azure Bastion:
   ```bash
   nslookup gd-ent-prod-eus-sqlsvr-<suffix>.database.windows.net
   ```
   *Expected result: Resolves to an IP in `10.1.5.0/24` (PrivateEndpointSubnet).*

4. **Verify Azure Firewall Forced Tunneling**:
   From `BackendSubnet`, test egress routing:
   ```bash
   curl -s https://ifconfig.me
   ```
   *Expected result: Matches the Azure Firewall Public IP address.*
