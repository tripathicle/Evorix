# Enterprise Azure Hub-and-Spoke High Availability Architecture

## 1. Executive Summary

This architecture establishes an enterprise-grade cloud landing zone within Microsoft Azure designed for mission-critical production workloads. Adhering to the Microsoft Cloud Adoption Framework (CAF) and Azure Well-Architected Framework (WAF), this architecture isolates centralized security, connectivity, and identity in a **Hub Virtual Network (10.0.0.0/16)** while delegating application hosting to an isolated **Spoke Virtual Network (10.1.0.0/16)**.

---

## 2. Overall Architecture Diagram

```mermaid
flowchart TD
    subgraph External["External Network Layer"]
        Internet["Public Internet"]
        OnPrem["On-Premises Corporate DC"]
    end

    subgraph Hub["Azure Hub VNet (10.0.0.0/16)"]
        AFW["Azure Firewall Premium<br/>(10.0.1.4)"]
        Bas["Azure Bastion Host<br/>(10.0.2.0/26)"]
        VPNGW["Active-Active VPN Gateway<br/>(10.0.3.0/27)"]
        DNSRes["Azure DNS Private Resolver<br/>(10.0.4.0/28)"]
        LAW["Log Analytics Workspace & Azure Monitor"]
        RSV["Recovery Services Vault (GRS)"]
    end

    subgraph Spoke["Azure Spoke VNet (10.1.0.0/16)"]
        AppGW["Application Gateway WAF_v2<br/>(10.1.1.0/24)"]
        FE["Frontend Linux VMSS<br/>(10.1.2.0/24)"]
        ILB["Standard Internal Load Balancer<br/>(10.1.3.0/24)"]
        BE["Backend Linux VMSS<br/>(10.1.4.0/24)"]
        PE["PaaS Private Endpoints<br/>(10.1.5.0/24)"]
    end

    subgraph PaaS["Azure Managed PaaS Services (Private Link)"]
        SQL["Azure SQL Database"]
        SA["Azure Storage Account (Blob)"]
        KV["Azure Key Vault"]
        Cosmos["Azure Cosmos DB"]
        Redis["Azure Cache for Redis"]
    end

    Internet -->|Ingress HTTPS:443| AppGW
    OnPrem <-->|S2S IPsec Active-Active| VPNGW
    VPNGW <--> AFW

    AppGW -->|Private HTTP:80| FE
    FE -->|Private HTTP:8080| ILB
    ILB -->|Load Balanced TCP:8080| BE
    BE -->|Private Link Queries| PE
    PE --- SQL
    PE --- SA
    PE --- KV
    PE --- Cosmos
    PE --- Redis

    FE -.->|Egress 0.0.0.0/0 via UDR| AFW
    BE -.->|Egress 0.0.0.0/0 via UDR| AFW
    AFW -.->|Inspected Egress| Internet
    Bas -.->|Secure Bastion Management| FE
    Bas -.->|Secure Bastion Management| BE
```

---

## 3. Core Architectural Pillars

### A. High Availability & Multi-Zone Redundancy
- **Availability Zones**: All gateway and compute instances (Firewall, Bastion, VPN Gateway, Application Gateway, Frontend VMSS, Internal LB, Backend VMSS) are deployed with multi-zone distribution across Zones `1`, `2`, and `3`.
- **Autoscaling**: Both Application Gateway (min 2, max 10 instances) and VMSS tiers automatically scale horizontally based on workload demand.
- **Health Probing**: Continuous health check probing monitors node availability and automatically removes degraded instances from traffic pools without service disruption.

### B. Network Isolation & Zero Trust
- **No Direct Public IPs**: Compute VMs are private-only. Individual scale set instances have zero public IP addresses.
- **Perimeter Defense**: Ingress traffic is inspected by Application Gateway WAF_v2 with OWASP Core Rule Sets in Prevention mode. Egress traffic from all workloads is forced through Azure Firewall Premium via User Defined Routes (UDRs).
- **Subnet Microsegmentation**: Dedicated Network Security Groups (NSGs) protect each subnet tier with default-deny rules.

### C. Private PaaS Connectivity
- All Azure PaaS resources (SQL Database, Blob Storage, Key Vault, Cosmos DB, and Redis) have public network access strictly disabled.
- In-transit traffic flows entirely across the Azure private backbone via Private Endpoints and Private DNS zones.

---

## 4. Terraform Module Dependency Flow

```mermaid
graph TD
    subgraph Foundation
        RG["Resource Group Module"]
        LAW_Mod["Monitoring Module"]
    end

    subgraph HubNetwork
        HubVNet["Virtual Network (Hub)"]
        HubSub["Subnet Module (Hub)"]
        AFW_Mod["Firewall Module"]
        Bas_Mod["Bastion Module"]
        VPN_Mod["VPN Gateway Module"]
        DNS_Mod["DNS Resolver Module"]
    end

    subgraph SpokeNetwork
        SpokeVNet["Virtual Network (Spoke)"]
        SpokeSub["Subnet Module (Spoke)"]
        Peering["VNet Peering Module"]
        RT_Mod["Route Table Module (UDR)"]
        NSG_Mod["NSG Module"]
    end

    subgraph AppWorkload
        AppGW_Mod["Application Gateway Module"]
        FE_VMSS["Frontend VMSS Module"]
        ILB_Mod["Internal LB Module"]
        BE_VMSS["Backend VMSS Module"]
    end

    subgraph DataServices
        PDNS["Private DNS Module"]
        PaaS_Res["PaaS Modules (SQL, KV, Storage, Cosmos, Redis)"]
        PE_Mod["Private Endpoint Module"]
    end

    RG --> HubVNet & SpokeVNet & PaaS_Res
    LAW_Mod --> AFW_Mod & Bas_Mod & AppGW_Mod & ILB_Mod
    HubVNet --> HubSub --> AFW_Mod & Bas_Mod & VPN_Mod & DNS_Mod
    SpokeVNet --> SpokeSub
    HubVNet & SpokeVNet --> Peering
    AFW_Mod --> RT_Mod --> SpokeSub
    SpokeSub --> NSG_Mod
    SpokeSub --> AppGW_Mod & FE_VMSS & ILB_Mod & BE_VMSS
    AppGW_Mod --> FE_VMSS
    ILB_Mod --> BE_VMSS
    HubVNet & SpokeVNet --> PDNS
    PaaS_Res & PDNS & SpokeSub --> PE_Mod
```
