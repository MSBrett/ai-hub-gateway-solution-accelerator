# 🚀 LLM Backend Onboarding for AI Citadel Governance Hub

## Overview

Automate the onboarding of LLM backends to your APIM-based AI Gateway with a streamlined, infrastructure-as-code approach using **Bicep parameter files** (`.bicepparam`).

This package enables dynamic LLM backend routing without modifying APIM policies:

- 📦 **Automatic Backend Creation**: Create APIM backends from configuration
- ⚖️ **Load Balancing**: Distribute requests across multiple backends for the same model
- 🔄 **Automatic Failover**: Route to healthy backends when others are unavailable
- 🔌 **Multi-Provider Support**: Azure AI Foundry, Azure OpenAI, and external LLM providers
- 📝 **Declarative Configuration**: Simple `.bicepparam` files for version control

## What Gets Created

| Resource | Description |
|----------|-------------|
| **APIM Backends** | Individual backend resources for each LLM endpoint |
| **Backend Pools** | Load-balanced pools for models with multiple backends |
| **Policy Fragments** | Dynamic routing logic for model-based routing |
| **Universal LLM API** | Unified OpenAI-compatible endpoint (optional) |

## Quick Start

### 1. Copy the Parameter Template

```bash
cp main.bicepparam my-backends.bicepparam
```

### 2. Configure Your Backends

Edit `my-backends.bicepparam`:

```bicep
using 'main.bicep'

param apim = {
  subscriptionId: '<your-subscription-id>'
  resourceGroupName: 'rg-citadel-governance-hub'
  name: 'apim-citadel'
}

param apimManagedIdentity = {
  subscriptionId: '<your-subscription-id>'
  resourceGroupName: 'rg-citadel-governance-hub'
  name: 'id-apim-citadel'
}

param llmBackendConfig = [
  {
    backendId: 'aif-primary'
    backendType: 'ai-foundry'
    endpoint: 'https://my-foundry.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o', 'gpt-4o-mini']
  }
]
```

### 3. Deploy

```bash
az deployment sub create \
  --name llm-backend-onboarding \
  --location eastus \
  --template-file main.bicep \
  --parameters my-backends.bicepparam
```

## Configuration Reference

### Backend Configuration Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `backendId` | string | Yes | Unique identifier for the backend |
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
    backendId: 'aif-gpt4'
    backendType: 'ai-foundry'
    endpoint: 'https://my-foundry.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o', 'gpt-4o-mini', 'Phi-4']
  }
]
```

### Load Balancing Across Regions

```bicep
param llmBackendConfig = [
  {
    backendId: 'aif-eastus'
    backendType: 'ai-foundry'
    endpoint: 'https://foundry-eastus.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o']
    priority: 1
    weight: 100
  }
  {
    backendId: 'aif-westus'
    backendType: 'ai-foundry'
    endpoint: 'https://foundry-westus.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o']
    priority: 2
    weight: 50
  }
]
```

### Mixed Providers

```bicep
param llmBackendConfig = [
  {
    backendId: 'aif-llama'
    backendType: 'ai-foundry'
    endpoint: 'https://llama-project.services.ai.azure.com/models'
    authScheme: 'managedIdentity'
    supportedModels: ['Llama-3.3-70B-Instruct']
  }
  {
    backendId: 'aoai-gpt4'
    backendType: 'azure-openai'
    endpoint: 'https://my-openai.openai.azure.com/openai'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4', 'gpt-35-turbo']
  }
]
```

## Request Flow

```
1. Client → APIM Gateway
   POST /llm/openai/chat/completions
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

## RBAC Configuration

Control which clients can access which backends using the `allowedBackendPools` policy variable:

```xml
<!-- In your product policy -->
<set-variable name="allowedBackendPools" value="aif-gpt4,aif-embeddings" />
```

Leave empty to allow all backend pools:
```xml
<set-variable name="allowedBackendPools" value="" />
```

## Monitoring

### Key Metrics

| Metric | Description |
|--------|-------------|
| Backend Health | APIM → Backends → Health status |
| Request Distribution | Analytics → Backend dimension |
| Error Rates | Failures by backend |
| Latency | Response time per backend |

### Application Insights Query

```kusto
requests
| where name == "universal-llm-api"
| extend model = tostring(customDimensions.model)
| extend backend = tostring(customDimensions.backend)
| summarize count(), avg(duration) by model, backend, bin(timestamp, 5m)
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

1. Verify managed identity has required roles:
   - `Cognitive Services OpenAI User` for Azure OpenAI
   - `Cognitive Services User` for AI Foundry
2. Check named value `uami-client-id` is set correctly

## Prerequisites

- Existing APIM instance with:
  - User-assigned managed identity configured
  - Managed identity assigned to APIM
- LLM backends deployed and accessible:
  - AI Foundry projects with model deployments
  - Azure OpenAI resources with model deployments
- Managed identity has RBAC roles on backend resources

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

- [Citadel Access Contracts](../../guides/Citadel-Access-Contracts.md) - Configure use case access
- [Full Deployment Guide](../../guides/full-deployment-guide.md) - Complete Citadel deployment
- [Dynamic LLM Backend Configuration](../../guides/archived/dynamic-llm-backend-configuration.md) - Detailed routing guide
