# 🚀 LLM Backend Onboarding for AI Citadel Governance Hub

## Overview

Automate the onboarding of LLM backends to your APIM-based AI Gateway with a streamlined, infrastructure-as-code approach using **Bicep parameter files** (`.bicepparam`).

This package enables dynamic LLM backend routing without modifying APIM policies:

- 📦 **Automatic Backend Creation**: Create APIM backends from configuration
- ⚖️ **Load Balancing**: Distribute requests across multiple backends for the same model
- 🔄 **Automatic Failover**: Route to healthy backends when others are unavailable
- 🔌 **Multi-Provider Support**: Microsoft Foundry, Azure OpenAI, and external LLM providers
- 📝 **Declarative Configuration**: Simple `.bicepparam` files for version control

## What Gets Created

| Resource | Description |
|----------|-------------|
| **APIM Backends** | Individual backend resources for each LLM endpoint |
| **Backend Pools** | Load-balanced pools for models with multiple backends |
| **Policy Fragments** | Dynamic routing logic for model-based routing |

## Prerequisites

- Existing deployment of AI Citadel Governance Hub with:
  - User-assigned managed identity configured
  - APIs for Universal LLM API and Azure OpenAI API
- LLM backends deployed and accessible:
  - Microsoft Foundry with model deployments
  - Azure OpenAI resources with model deployments
  - APIM can reach the target backends from network perspective
- Verify APIM's user assigned managed identity has required roles:
   - `Cognitive Services OpenAI User` for Azure OpenAI
   - `Cognitive Services User` for Microsoft Foundry

## Quick Start

### 1. Copy the Parameter Template

```bash
cp main.bicepparam llm-backends-dev-local.bicepparam
```

### 2. Configure Your Backends

Edit `llm-backends-dev-local.bicepparam`:

```bicep
using 'main.bicep'

param apim = {
  subscriptionId: '00000000-0000-0000-0000-000000000000' // Replace with your subscription ID
  resourceGroupName: 'rg-citadel-governance-hub'         // Replace with your APIM resource group
  name: 'apim-citadel-governance-hub'                    // Replace with your APIM name
}

param apimManagedIdentity = {
  subscriptionId: '00000000-0000-0000-0000-000000000000' // Replace with your subscription ID
  resourceGroupName: 'rg-citadel-governance-hub'         // Replace with your identity resource group
  name: 'id-apim-citadel'                                // Replace with your managed identity name
}

param llmBackendConfig = [
  {
    backendId: 'aif-citadel-primary'
    backendType: 'ai-foundry'
    endpoint: 'https://aif-RESOURCE_TOKEN-0.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o', 'gpt-4o-mini', 'DeepSeek-R1', 'Phi-4']
    priority: 1
    weight: 100
  }
]
```

### 3. Deploy

```bash
az deployment sub create --name llm-backend-onboarding --location eastus --template-file main.bicep --parameters llm-backends-dev-local.bicepparam
```

## Configuration Reference

### Backend Configuration Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `backendId` | string | Yes | Unique identifier for the backend (usually the name of the backend resource) |
| `backendType` | string | Yes | `ai-foundry`, `azure-openai`, or `external` |
| `endpoint` | string | Yes | Base URL of the LLM service |
| `authScheme` | string | Yes | `managedIdentity`, `apiKey`, or `token` |
| `supportedModels` | array | Yes | Model names this backend supports |
| `priority` | number | No | 1-5, default 1 (lower = higher priority) |
| `weight` | number | No | 1-1000, default 100 (load balancing weight) |

### Backend Types

#### AI Foundry (`ai-foundry`)
- Uses Azure AI Foundry project endpoints
- Endpoint format: `https://<resource>.services.ai.azure.com/models`
- Authentication: Managed identity with Cognitive Services scope
- No URL rewriting required

#### Azure OpenAI (`azure-openai`)
- Uses Azure OpenAI Service endpoints
- Endpoint format: `https://<resource>.openai.azure.com/openai`
- Authentication: Managed identity with Cognitive Services scope
- Automatic URL rewriting to include `/deployments/{model}/`

#### External (`external`)
- Uses external LLM provider endpoints
- Authentication: API key or backend credentials
- No URL rewriting

## Example Configurations

### Single AI Foundry Backend

```bicep
param llmBackendConfig = [
  {
    backendId: 'aif-citadel-primary'
    backendType: 'ai-foundry'
    endpoint: 'https://aif-RESOURCE_TOKEN-0.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o', 'gpt-4o-mini', 'DeepSeek-R1', 'Phi-4']
    priority: 1
    weight: 100
  }
]
```

### Load Balancing Across Regions

```bicep
param llmBackendConfig = [
  {
    backendId: 'aif-citadel-primary'
    backendType: 'ai-foundry'
    endpoint: 'https://aif-RESOURCE_TOKEN-0.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o', 'gpt-4o-mini', 'DeepSeek-R1', 'Phi-4']
    priority: 1
    weight: 100
  }
  {
    backendId: 'aif-citadel-secondary'
    backendType: 'ai-foundry'
    endpoint: 'https://aif-RESOURCE_TOKEN-1.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-5', 'DeepSeek-R1']
    priority: 2
    weight: 50
  }
]
```

### Mixed Providers

```bicep
param llmBackendConfig = [
  {
    backendId: 'aif-citadel-primary'
    backendType: 'ai-foundry'
    endpoint: 'https://aif-RESOURCE_TOKEN-0.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o', 'gpt-4o-mini', 'DeepSeek-R1', 'Phi-4']
    priority: 1
    weight: 100
  }
  {
    backendId: 'aoai-eastus-gpt4'
    backendType: 'azure-openai'
    endpoint: 'https://YOUR-AOAI-RESOURCE.openai.azure.com/openai'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o', 'gpt-4o-mini', 'text-embedding-ada-002']
    priority: 1
    weight: 100
  }
]
```

## Request Flow

```
1. Client → APIM Gateway
   POST /models/chat/completions
   Body: { "model": "gpt-4o", "messages": [...] }

2. Extract Model
   → requestedModel = "gpt-4o"

3. Find Backend Pool
   → matches "gpt-4o-backend-pool" (load balanced)
   or direct backend if single provider

4. Authenticate
   → Get managed identity token
   → Set Authorization header

5. Route to Backend
   → Forward to healthy backend in pool

6. Return Response
   → Client receives response with usage headers
```

## Monitoring

### Key Metrics

Connected Application Insights to APIM provides insights into backend performance:

| Metric | Description |
|--------|-------------|
| Application Map | Visual representation of dependencies performance |
| Performance | For both operations and dependencies |
| Failures | Failures by backend |
| Latency | Response time per backend |

### Application Insights Query

```kusto
// this query calculates LLM backend duration percentiles and count by target
let start=ago(24h);
let end=now();
let timeGrain=5m;

let dataset=dependencies
// additional filters can be applied here
| where timestamp > start and timestamp < end
| where client_Type != "Browser"
;
// calculate duration percentiles and count for all dependencies (overall)
dataset
| summarize avg_duration=sum(itemCount * duration)/sum(itemCount), percentiles(duration, 50, 95, 99), count_=sum(itemCount)
| project operation_Name="Overall", avg_duration, percentile_duration_50, percentile_duration_95, percentile_duration_99, count_
| union(dataset
// change 'target' on the below line to segment by a different property
| summarize avg_duration=sum(itemCount * duration)/sum(itemCount), percentiles(duration, 50, 95, 99), count_=sum(itemCount) by target
| sort by avg_duration desc, count_ desc
)
```

## Troubleshooting

### "Model not supported" Error

1. Check model name in `supportedModels` array (case-insensitive)
2. Verify backend pool was created in APIM
3. Review policy fragment deployment

### "403 Forbidden" Error

1. Check `allowedBackendPools` policy variable
2. Verify RBAC configuration
3. Review product/subscription access

### "401 Unauthorized" Error

1. Verify APIM's managed identity has required roles:
   - `Cognitive Services OpenAI User` for Azure OpenAI
   - `Cognitive Services User` for AI Foundry
2. `Unauthorized model access` indicates used access contract product is restricted for the model
3. Check named value `uami-client-id` is set correctly to APIM's managed identity client ID

## Files

```
llm-backend-onboarding/
├── main.bicep                    # Main deployment template
├── main.bicepparam               # Parameter file template
├── README.md                     # This file
└── modules/
    ├── llm-backends.bicep        # Creates APIM backend resources
    ├── llm-backend-pools.bicep   # Creates load-balanced pools
    ├── llm-policy-fragments.bicep # Generates routing policy fragments
    ├── universal-llm-api.bicep   # Creates Universal LLM API
    └── policies/
        ├── frag-set-backend-pools.xml
        ├── frag-set-backend-authorization.xml
        ├── frag-set-target-backend-pool.xml
        ├── frag-set-llm-requested-model.xml
        ├── frag-set-llm-usage.xml
        ├── universal-llm-api-policy.xml
        ├── universal-llm-openapi.json
        └── models-inference-openapi.json
```

## Related Guides

- [Citadel Access Contracts](../../../guides/Citadel-Access-Contracts.md) - Configure use case access
- [Full Deployment Guide](../....//guides/full-deployment-guide.md) - Complete Citadel deployment
- [Dynamic LLM Backend Configuration](../../guides/archived/dynamic-llm-backend-configuration.md) - Detailed routing guide
