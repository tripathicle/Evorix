# Operational Troubleshooting and Diagnostic Guide

## 1. Network Routing & UDR Issues

### Issue: VMs in Frontend or Backend Subnet Cannot Access Internet
- **Symptoms**: `curl` commands to external endpoints hang or timeout.
- **Root Cause Analysis**:
  1. Verify the route table associated with the subnet has `0.0.0.0/0` pointing to `10.0.1.4` (Azure Firewall).
  2. Verify Azure Firewall rules allow the outbound destination port/protocol.
  3. Verify IP Forwarding is active and no conflicting route overrides exist.
- **Diagnostic Command**:
  ```bash
  az network nic show-effective-route-table --resource-group gd-ent-prod-eus-spoke-rg --name <VM_NIC_NAME> -o table
  ```

---

## 2. DNS Resolution Failures

### Issue: PaaS FQDN Resolves to Public IP Instead of Private Endpoint IP
- **Symptoms**: Database connection attempts fail with access denied or firewall blocked.
- **Root Cause Analysis**:
  1. Virtual Network Link missing between Spoke VNet and Private DNS Zone (`privatelink.database.windows.net`).
  2. Private Endpoint DNS zone group was not attached or registration failed.
- **Diagnostic Command**:
  ```bash
  az network private-dns link vnet list --resource-group gd-ent-prod-eus-hub-rg --zone-name "privatelink.database.windows.net" -o table
  ```

---

## 3. Application Gateway & WAF Diagnostics

### Issue: Application Gateway Returns HTTP 502 Bad Gateway
- **Symptoms**: Browsing to public IP returns standard 502 error.
- **Root Cause Analysis**:
  1. Backend VMSS instance health probe is failing. Verify Nginx/Application is running on port 80 on frontend VMs.
  2. Subnet NSG on `FrontendSubnet` is blocking HTTP from `AppGatewaySubnet` (`10.1.1.0/24`).
- **Diagnostic Command**:
  ```bash
  az network application-gateway show-backend-health --resource-group gd-ent-prod-eus-spoke-rg --name gd-ent-prod-eus-appgw -o table
  ```

---

## 4. Log Analytics KQL Diagnostic Queries

Run these Kusto (KQL) queries in Azure Monitor Log Analytics:

### Azure Firewall Denied Traffic Query
```kusto
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule" or Category == "AzureFirewallApplicationRule"
| where msg_s has "Deny"
| project TimeGenerated, msg_s
| order by TimeGenerated desc
| take 50
```

### Application Gateway WAF Blocked Requests
```kusto
AzureDiagnostics
| where Category == "ApplicationGatewayFirewallLog"
| where action_s == "Blocked"
| project TimeGenerated, clientIp_s, requestUri_s, ruleId_s, Message
| order by TimeGenerated desc
```
