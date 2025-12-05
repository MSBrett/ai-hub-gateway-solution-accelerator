
# Network Architecture

## Network Deployment Approaches

AI Citadel Governance Hub supports **two architectural patterns** for network integration.

Based on your decisions in the earlier checklist, choose one of the following approaches:

### **Approach 1: Hub-Based (Citadel as Part of Hub)**

Citadel Governance Hub deployed **within** your existing hub VNet.

```
┌─────────────────────────────────────┐
│         Hub Network (VNet)          │
│  ┌──────────────────────────────┐   │
│  │   Citadel Governance Hub     │   │
│  │   - APIM Subnet              │   │
│  │   - Private Endpoints subnet │   │
│  │   - Logic app subnet         │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │   Shared Services            │   │
│  │   - Azure Firewall           │   │
│  │   - DNS,...                  │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
           │           │
           ▼           ▼
    ┌──────────┐  ┌──────────┐
    │ Spoke 1  │  │ Spoke 2  │
    │ Agents   │  │ Agents   │
    └──────────┘  └──────────┘
```

**Deployment Configuration:**
```bicep
param useExistingVnet = true
param vnetName = 'vnet-hub-eastus'
param existingVnetRG = 'rg-network-hub'
param apimSubnetName = 'snet-citadel-apim'
param privateEndpointSubnetName = 'snet-citadel-private-endpoints'
param dnsZoneRG = 'rg-network-hub'
param dnsSubscriptionId = '<hub-subscription-id>'
```

**When to Use:**
- ✅ Citadel manages all enterprise AI traffic
- ✅ Direct spoke-to-hub connectivity
- ✅ Simplified network topology

---

### **Approach 2: Hub-Spoke-Hub (Citadel as Dedicated Spoke)**

Citadel deployed in a **dedicated spoke network** with enterprise hub firewall in between.

```
                 ┌─────────────┐
                 │ Hub Network │
                 │  - Firewall │
                 │  - DNS      │
                 └──────┬──────┘
                        │
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
  ┌────────────┐ ┌──────────────┐ ┌────────────┐
  │  Spoke 1   │ │  Citadel     │ │  Spoke 2   │
  │  Agents    │ │  Governance  │ │  Agents    │
  └────────────┘ │   Hub        │ └────────────┘
                 │  - APIM      │
                 │  - PE        │
                 │  - Logic app │
                 └──────────────┘
```

**Deployment Configuration:**
```bicep
param useExistingVnet = false  // Creates new spoke VNet
param vnetName = 'vnet-citadel-eastus'
param vnetAddressPrefix = '10.170.0.0/24'
param apimSubnetPrefix = '10.170.0.0/26'
param privateEndpointSubnetPrefix = '10.170.0.64/26'
param functionAppSubnetPrefix = '10.170.0.128/26'
param dnsZoneRG = 'rg-network-hub'
param dnsSubscriptionId = '<hub-subscription-id>'

// Post-deployment: Configure VNet peering to hub
```

**When to Use:**
- ✅ Defense-in-depth security (dual inspection)
- ✅ Isolated AI workloads from general traffic
- ✅ Separate cost centers/subscriptions
- ✅ Compliance requirements for network isolation

>Note: Post deployment, you must configure VNet peering, DNS servers and route tables between the Citadel spoke and your hub VNet to enable connectivity.

---

## Network Setup Options

### **Option 1: Create New Network (Greenfield)**

Accelerator will create all networking components:

```bicep
param useExistingVnet = false
param vnetAddressPrefix = '10.170.0.0/24'
param apimSubnetPrefix = '10.170.0.0/26'
param privateEndpointSubnetPrefix = '10.170.0.64/26'
param functionAppSubnetPrefix = '10.170.0.128/26'

// Network access
param apimNetworkType = 'External'  // or 'Internal' for production
param apimV2UsePrivateEndpoint = true
param cosmosDbPublicAccess = 'Disabled'
param eventHubNetworkAccess = 'Enabled'  // Required during deployment of APIM v2 SKUs
```

**Includes:**
- ✅ Virtual Network with subnets
- ✅ Network Security Groups
- ✅ Private DNS Zones
- ✅ Private Endpoints for all services
- ✅ Route table (needed for APIM Developer and Premium SKUs)

---

### **Option 2: Bring Your Own Network (Brownfield)**

Integrate with existing enterprise network:

```bicep
param useExistingVnet = true
param vnetName = 'vnet-hub-prod-eastus'
param existingVnetRG = 'rg-network-prod'

// Subnet names (must exist)
param apimSubnetName = 'snet-citadel-apim'
param privateEndpointSubnetName = 'snet-citadel-pe'
param functionAppSubnetName = 'snet-citadel-functions'

// DNS configuration
param dnsZoneRG = 'rg-network-dns'
param dnsSubscriptionId = '00000000-0000-0000-0000-000000000000'
```

**Prerequisites:**
1. VNet with sufficient address space
2. Three subnets created (see [Subnet Requirements](#subnet-requirements))
    - APIM subnet /26 or larger
    - Function App subnet /26 or larger
    - Private Endpoints subnet /26 or larger
3. Private DNS zones created and linked (see [Required DNS Zones](#required-dns-zones))
4. NSG rules configured for APIM subnet (see [APIM Subnet](#apim-subnet))

---

## Subnet Requirements

### APIM Subnet

Dedicated subnet with `/26` or larger address space.

#### For Developer/Premium SKU (VNet Injection)

**NSG Rules Required:**

| Direction | Priority | Name | Port | Source | Destination | Purpose |
|-----------|----------|------|------|--------|-------------|---------|
| Inbound | 3000 | AllowPublicAccess* | 443 | Internet | VirtualNetwork | Gateway access |
| Inbound | 3010 | AllowAPIMManagement | 3443 | ApiManagement | VirtualNetwork | Control plane |
| Inbound | 3020 | AllowAPIMLoadBalancer | 6390 | AzureLoadBalancer | VirtualNetwork | Health probes |
| Inbound | 3030 | AllowAzureTrafficManager* | 443 | AzureTrafficManager | VirtualNetwork | Traffic routing |
| Outbound | 3000 | AllowStorage | 443 | VirtualNetwork | Storage | Configuration |
| Outbound | 3010 | AllowSql | 1433 | VirtualNetwork | Sql | Metadata |
| Outbound | 3020 | AllowKeyVault | 443 | VirtualNetwork | AzureKeyVault | Secrets |
| Outbound | 3030 | AllowMonitor | 1886, 443 | VirtualNetwork | AzureMonitor | Diagnostics |

> *Only required for External mode

**Route Table Required (Only for APIM Developer/Premium SKUs):**

```bicep
properties: {
  routes: [
    {
      name: 'apim-management'
      properties: {
        addressPrefix: 'ApiManagement'
        nextHopType: 'Internet'
      }
    }
  ]
}
```
>Note: This is a route record that you must add to your existing route table if using existing route table and it is ensure APIM can reach the control fabric communication, which fully private.

**Service Endpoints (if forced tunneling):**
- Microsoft.Storage
- Microsoft.Sql
- Microsoft.KeyVault
- Microsoft.ServiceBus
- Microsoft.EventHub
- Microsoft.AzureActiveDirectory

#### For StandardV2/PremiumV2 SKU (Private Endpoint)

- Subnet delegated to `Microsoft.Web/serverFarms`
- No route table required
- Private endpoint provides inbound connectivity

---

### Function App Subnet

Dedicated subnet with `/26` or larger, delegated to `Microsoft.Web/serverFarms`:

```bicep
{
  name: 'snet-citadel-functions'
  properties: {
    addressPrefix: '10.x.x.x/26'
    delegations: [
      {
        name: 'Microsoft.Web/serverFarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Enabled'
  }
}
```

---

### Private Endpoints Subnet

Dedicated subnet with `/26` or larger for all private endpoints:

```bicep
{
  name: 'snet-citadel-pe'
  properties: {
    addressPrefix: '10.x.x.x/26'
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}
```

> For APIM V2 SKUs, private endpoints in this subnet enable private inbound connectivity.

---

## DNS Configuration

### Private DNS Zones

Depending on your permissions and DNS zone distribution, choose one of these approaches:

**Option A: Use Existing DNS Zones with Resource IDs (Recommended)**

For maximum flexibility, specify each DNS zone by its full resource ID. This approach supports DNS zones across different subscriptions and resource groups:

```bicep
param existingPrivateDnsZones = {
  keyVault: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
  monitor: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.monitor.azure.com'
  eventHub: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net'
  cosmosDb: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com'
  storageBlob: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
  storageFile: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net'
  storageTable: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net'
  storageQueue: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net'
  cognitiveServices: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com'
  apimGateway: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net'
  aiServices: '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/privateDnsZones/privatelink.services.ai.azure.com'
}
```

> **Note:** You only need to specify the DNS zones relevant to your deployment. The `existingPrivateDnsZones` parameter takes precedence over the legacy `dnsZoneRG`/`dnsSubscriptionId` approach when both are provided.

**Option B: Use Existing Central DNS Zones (Legacy)**

If all your DNS zones are in a single subscription and resource group:

```bicep
param dnsZoneRG = 'rg-network-dns'
param dnsSubscriptionId = '<dns-subscription-id>'
```

> **Note:** This legacy approach is maintained for backward compatibility but Option A is recommended for new deployments.

**Option C: Create New DNS Zones**

Leave all DNS parameters empty to create new zones (requires manual VNet linking):

```bicep
param existingPrivateDnsZones = {}
param dnsZoneRG = ''
param dnsSubscriptionId = ''
```

> Post-deployment: Link new zones to your VNet or configure central DNS resolver.

### APIM Internal Mode DNS

When using `apimNetworkType = 'Internal'`, DNS resolution must be configured:

**Recommended: Custom Domains**
- Configure custom domains for Gateway, Management, and Portal endpoints
- Use wildcard CA-issued certificate (e.g., `*.api.az.company.com`)
- Ensure network DNS resolver routes to APIM private IPs

**Alternative: Private DNS Zone**
- Create `azure-api.net` private DNS zone
- Add A records for all 5 APIM endpoints pointing to private IP
- Link zone to VNet

> **WARNING:** Using private `azure-api.net` zone may conflict with external APIM instances using public DNS. Add public IP records for external instances if needed. Failure to do so may lead to resolution issues for other APIM services that are external or without network integration.

---

## Required DNS Zones

All zones must be linked to your VNet:

| DNS Zone | Purpose |
|----------|---------|
| `privatelink.cognitiveservices.azure.com` | Azure OpenAI / Cognitive Services |
| `privatelink.openai.azure.com` | Azure OpenAI |
| `privatelink.vaultcore.azure.net` | Key Vault |
| `privatelink.monitor.azure.com` | Azure Monitor |
| `privatelink.servicebus.windows.net` | Event Hub |
| `privatelink.documents.azure.com` | Cosmos DB |
| `privatelink.blob.core.windows.net` | Storage Blob |
| `privatelink.file.core.windows.net` | Storage File |
| `privatelink.table.core.windows.net` | Storage Table |
| `privatelink.queue.core.windows.net` | Storage Queue |
| `privatelink.azure-api.net` | APIM V2 SKUs |
| `privatelink.services.ai.azure.com` | Azure AI Foundry |

> **Azure Monitor:** Requires special Private Link Scope configuration post-deployment for centralized monitoring.
