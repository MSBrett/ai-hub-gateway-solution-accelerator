# LLM Backend Onboarding Guide

This guide explains how to onboard LLM backends (Azure OpenAI, AI Foundry, or external providers) to an existing AI Hub Gateway APIM instance using the independent LLM Backend Onboarding deployment.

## Overview

The LLM Backend Onboarding deployment enables dynamic routing of LLM requests across multiple backend instances without requiring a full infrastructure deployment. It creates:

- **Backend Resources**: Individual APIM backends with circuit breakers
- **Backend Pools**: Load-balanced pools for models available on multiple backends
- **Policy Fragments**: Dynamic routing logic using C# expressions
- **Universal LLM API** (optional): A unified API supporting both OpenAI and Models Inference patterns

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          APIM Gateway                               │
├─────────────────────────────────────────────────────────────────────┤
│  Universal LLM API                                                  │
│  ├── /chat/completions                                              │
│  ├── /completions                                                   │
│  ├── /embeddings                                                    │
│  └── /images/generations                                            │
├─────────────────────────────────────────────────────────────────────┤
│  Policy Fragments                                                   │
│  ├── set-backend-pools (dynamic pool routing)                       │
│  ├── set-backend-authorization (managed identity/API key)           │
│  ├── set-target-backend-pool (load balancing)                       │
│  └── set-llm-requested-model (model extraction)                     │
├─────────────────────────────────────────────────────────────────────┤
│  Backend Pools                                                      │
│  ├── pool-gpt-4o (multiple backends)                                │
│  └── pool-gpt-4o-mini (multiple backends)                           │
├─────────────────────────────────────────────────────────────────────┤
│  Backends                                                           │
│  ├── llm-foundry-east-us (AI Foundry)                               │
│  ├── llm-foundry-west-us (AI Foundry)                               │
│  └── llm-openai-sweden (Azure OpenAI)                               │
└─────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- Existing APIM instance deployed via the AI Hub Gateway Solution Accelerator
- APIM Managed Identity with appropriate permissions
- At least one existing LLM backend (Azure OpenAI, AI Foundry, or external)
- Azure CLI and Bicep CLI installed

## Quick Start

### 1. Copy the Parameter Template

```bash
cd bicep/infra/llm-backend-onboarding
cp main.bicepparam llm-onboarding-dev-local.bicepparam
```

### 2. Configure Your Backends

Edit the parameter file with your backend configuration:

```bicep
param llmBackendConfig = [
  {
    backendId: 'foundry-east-us'
    backendType: 'ai-foundry'
    endpoint: 'https://my-foundry-project.eastus.models.ai.azure.com'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o', 'gpt-4o-mini']
    priority: 1
    weight: 100
  }
  {
    backendId: 'foundry-west-us'
    backendType: 'ai-foundry'
    endpoint: 'https://my-foundry-project.westus.models.ai.azure.com'
    authScheme: 'managedIdentity'
    supportedModels: ['gpt-4o', 'gpt-4o-mini']
    priority: 1
    weight: 100
  }
]
```

### 3. Deploy

```bash
az deployment sub create --name llm-onboarding-deployment --location swedencentral --template-file main.bicep --parameters llm-onboarding-dev-local.bicepparam
```

## Configuration Reference

### Backend Configuration Object

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `backendId` | string | Yes | Unique identifier for the backend |
| `backendType` | string | Yes | Type: `ai-foundry`, `azure-openai`, or `external` |
| `endpoint` | string | Yes | Full URL to the backend service |
| `authScheme` | string | Yes | Authentication: `managedIdentity`, `apiKey`, or `token` |
| `supportedModels` | array | Yes | List of model names this backend supports |
| `priority` | int | No | Priority for load balancing (lower = higher priority) |
| `weight` | int | No | Weight for weighted round-robin (default: 100) |

### Backend Types

#### AI Foundry (`ai-foundry`)
```bicep
{
  backendId: 'foundry-instance'
  backendType: 'ai-foundry'
  endpoint: 'https://project.region.models.ai.azure.com'
  authScheme: 'managedIdentity'
  supportedModels: ['gpt-4o', 'Phi-4']
}
```

#### Azure OpenAI (`azure-openai`)
```bicep
{
  backendId: 'openai-instance'
  backendType: 'azure-openai'
  endpoint: 'https://myopenai.openai.azure.com'
  authScheme: 'managedIdentity'
  supportedModels: ['gpt-4o', 'text-embedding-ada-002']
}
```

#### External Provider (`external`)
```bicep
{
  backendId: 'external-llm'
  backendType: 'external'
  endpoint: 'https://api.externalprovider.com/v1'
  authScheme: 'apiKey'
  supportedModels: ['custom-model']
}
```

### Authentication Schemes

| Scheme | Description | Use Case |
|--------|-------------|----------|
| `managedIdentity` | Azure AD token via managed identity | Azure OpenAI, AI Foundry |
| `apiKey` | Static API key in named value | External providers |
| `token` | Bearer token from named value | OAuth-based services |

## Load Balancing

The deployment automatically creates backend pools for models available on multiple backends.

### Priority-Based Failover

Configure priority to create failover chains:

```bicep
[
  {
    backendId: 'primary-backend'
    priority: 1  // Primary
    weight: 100
    supportedModels: ['gpt-4o']
  }
  {
    backendId: 'secondary-backend'
    priority: 2  // Failover
    weight: 100
    supportedModels: ['gpt-4o']
  }
]
```

### Weighted Round-Robin

Configure weights for proportional distribution:

```bicep
[
  {
    backendId: 'high-capacity'
    priority: 1
    weight: 70  // 70% of traffic
    supportedModels: ['gpt-4o']
  }
  {
    backendId: 'standard-capacity'
    priority: 1
    weight: 30  // 30% of traffic
    supportedModels: ['gpt-4o']
  }
]
```

## Circuit Breaker Configuration

Each backend is configured with circuit breaker rules:

- **429 (Rate Limit)**: Trips after 3 occurrences in 10 seconds
- **5xx (Server Error)**: Trips after 3 occurrences in 10 seconds
- **Recovery**: Automatic after 10 seconds

## Universal LLM API

The optional Universal LLM API provides a unified endpoint supporting both OpenAI and Azure Models Inference patterns.

### Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/chat/completions` | POST | Chat completions |
| `/completions` | POST | Text completions |
| `/embeddings` | POST | Text embeddings |
| `/images/generations` | POST | Image generation |

### Configuration

```bicep
param deployUniversalLlmApi = true
param inferenceAPIPath = '/inference'
param inferenceAPIType = 'openai'  // or 'models-inference'
```

## Usage Examples

### Using with Azure OpenAI SDK

```python
from openai import AzureOpenAI

client = AzureOpenAI(
    azure_endpoint="https://your-apim.azure-api.net",
    api_key="your-subscription-key",
    api_version="2024-10-21"
)

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

### Using with REST API

```bash
curl -X POST "https://your-apim.azure-api.net/models/chat/completions" \
  -H "Content-Type: application/json" \
  -H "api-key: your-key" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Validation

Use the validation notebook to test your deployment:

```bash
cd validation
jupyter notebook llm-backend-onboarding-tests.ipynb
```

The notebook validates:
- Backend configuration
- API connectivity
- Load balancing behavior
- Circuit breaker failover
- Multi-model routing
- Latency performance

## Troubleshooting

### Backend Not Responding

1. Verify the endpoint URL is correct
2. Check managed identity permissions
3. Review APIM diagnostic logs

### Load Balancing Not Working

1. Ensure multiple backends support the same model
2. Verify priority and weight settings
3. Check that all backends are healthy

### Circuit Breaker Tripping

1. Review backend health and performance
2. Check for rate limiting (429 errors)
3. Verify backend capacity

## Related Documentation

- [LLM Routing Architecture](llm-routing-architecture.md)
- [Full Deployment Guide](full-deployment-guide.md)
- [Citadel Access Contracts](Citadel-Access-Contracts.md)

## File Structure

```
bicep/infra/llm-backend-onboarding/
├── main.bicep                 # Main deployment file
├── main.bicepparam            # Parameter template
├── README.md                  # Quick reference
└── modules/
    ├── llm-backends.bicep         # Backend resources
    ├── llm-backend-pools.bicep    # Backend pool creation
    ├── llm-policy-fragments.bicep # Policy fragment generation
    ├── universal-llm-api.bicep    # Universal API definition
    └── policies/
        ├── set-backend-pools.xml
        ├── set-backend-authorization.xml
        ├── set-target-backend-pool.xml
        ├── set-llm-requested-model.xml
        ├── set-llm-usage.xml
        ├── universal-llm-openapi.json
        └── models-inference-openapi.json
```
