# 🔌 Azure AI Foundry - APIM Connection Integration

This module enables Azure AI Foundry projects to access AI models through your Azure API Management (APIM) gateway, supporting the **Bring Your Own AI Gateway** pattern for enterprise AI governance.

## 📋 Overview

The APIM connection integration allows organizations to:

- **Maintain control** over model endpoints behind your existing governance hub
- **Build agents** that leverage models without exposing them publicly  
- **Apply governance** requirements to AI model access through APIM policies
- **Centralize access** through a single, governed AI gateway

### Architecture

```mermaid
flowchart LR
    subgraph Foundry["Azure AI Foundry"]
        Project[AI Project]
        Agent[Foundry Agent]
    end
    
    subgraph Connection["APIM Connection"]
        Conn[Connection Config]
        Creds[Credentials]
    end
    
    subgraph Gateway["Citadel Governance Hub"]
        APIM[Azure API Management]
        Policy[Policies & Routing]
    end
    
    subgraph Backend["AI Services"]
        AOAI[Azure OpenAI]
        Models[Other Models]
    end
    
    Project --> Conn
    Agent --> Conn
    Conn --> APIM
    APIM --> Policy
    Policy --> AOAI
    Policy --> Models
```

### Request Flow

```mermaid
sequenceDiagram
    participant Agent as Foundry Agent
    participant Conn as APIM Connection
    participant APIM as API Management
    participant Model as AI Model
    
    Agent->>Conn: Chat Completion Request
    Note over Conn: Add auth headers<br/>Apply custom headers
    Conn->>APIM: Forward Request
    APIM->>APIM: Apply Policies
    APIM->>Model: Route to Backend
    Model-->>APIM: Response
    APIM-->>Conn: Response
    Conn-->>Agent: Response
```

---

## 📁 Folder Structure

```
foundry-integration/
├── main.bicep                              # Main deployment template
├── main.bicepparam                         # Default parameters (APIM defaults)
├── README.md                               # This documentation
├── modules/
│   └── apim-connection-common.bicep        # Reusable connection module
└── samples/
    ├── static-models.bicepparam            # Static model list configuration
    ├── dynamic-discovery.bicepparam        # Custom discovery endpoints
    ├── custom-headers.bicepparam           # Custom headers for policies
    ├── custom-auth.bicepparam              # Custom authentication config
    └── full-config.bicepparam              # Complete reference example
```

---

## ✅ Prerequisites

| Requirement | Description |
|-------------|-------------|
| **Azure Subscription** | Access to subscription containing AI Foundry |
| **AI Foundry Project** | Existing Foundry account and project |
| **APIM Gateway** | Deployed Citadel Governance Hub or APIM instance |
| **APIM Subscription Key** | Valid subscription key for API access |
| **Azure CLI** | Latest version with Bicep support |
| **Permissions** | Contributor on Foundry resource group |

---

## 🚀 Quick Start

### Step 1: Configure Parameters

Copy and edit the default parameter file:

```bash
cd bicep/infra/foundry-integration
cp main.bicepparam my-connection.bicepparam
```

Edit `my-connection.bicepparam`:

```bicep
using 'main.bicep'

param aiFoundryAccountName = 'my-foundry-account'
param aiFoundryProjectName = 'my-project'
param connectionName = 'citadel-hub-connection'
param apimGatewayUrl = 'https://my-apim.azure-api.net'
param apiPath = 'openai'
param apimSubscriptionKey = 'your-subscription-key'
param deploymentInPath = 'true'
param inferenceAPIVersion = '2024-02-01'
// Leave staticModels empty to use APIM defaults
```

### Step 2: Deploy

```bash
# Login and set subscription
az login
az account set --subscription <foundry-subscription-id>

# Deploy the connection
az deployment group create --name foundry-integration --resource-group <foundry-resource-group> --template-file main.bicep --parameters main-local.bicepparam
```

### Step 3: Verify

Check the connection in Azure AI Foundry portal:
1. Navigate to your Foundry project
2. Go to **Operate → Admin → Connected resources**
3. Verify the connection appears and is active

---

## 🔧 Configuration Options

### Model Discovery Methods

Choose **one** of these approaches:

| Method | When to Use | Parameters |
|--------|-------------|------------|
| **APIM Defaults** | Standard APIM setup with `/deployments` endpoints | Leave `staticModels` empty and no custom discovery |
| **Static Models** | Fixed set of known models, no discovery needed | `staticModels = [...]` |
| **Custom Discovery** | Non-standard endpoints or OpenAI format | `listModelsEndpoint`, `getModelEndpoint`, `deploymentProvider` |

#### Option 1: APIM Defaults (Recommended)

Uses APIM's standard discovery endpoints:
- List: `/deployments`
- Get: `/deployment/{deploymentName}`
- Provider: `AzureOpenAI`

Simply don't provide `staticModels` or custom discovery parameters:

```bicep
// No staticModels or discovery params = APIM defaults
param deploymentInPath = 'false'
param inferenceAPIVersion = '2024-02-01'
```

#### Option 2: Static Model List

Define models explicitly when discovery isn't needed:

```bicep
param staticModels = [
  {
    name: 'gpt-4o'
    properties: {
      model: {
        name: 'gpt-4o'
        version: '2024-11-20'
        format: 'OpenAI'
      }
    }
  }
]
```

#### Option 3: Custom Discovery

For non-standard endpoints or OpenAI format:

```bicep
param listModelsEndpoint = '/models'
param getModelEndpoint = '/models/{deploymentName}'
param deploymentProvider = 'OpenAI'  // or 'AzureOpenAI'
```

### Deployment Path Configuration

Controls how model names are passed in requests:

| Value | URL Format | Request Body |
|-------|------------|--------------|
| `'true'` | `/deployments/{model}/chat/completions` | N/A |
| `'false'` | `/chat/completions` | `{"model": "{model}"}` |

### Custom Headers

Add headers for APIM policy routing:

```bicep
param customHeaders = {
  'X-Environment': 'production'
  'X-Route-Policy': 'premium'
  'X-Client-App': 'foundry-agents'
}
```

### Custom Authentication

Customize the API key header format:

```bicep
// Standard APIM subscription header
param authConfig = {
  type: 'api_key'
  name: 'Ocp-Apim-Subscription-Key'
  format: '{api_key}'
}

// Bearer token format
param authConfig = {
  type: 'api_key'
  name: 'Authorization'
  format: 'Bearer {api_key}'
}
```

---

## 📋 Parameter Reference

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `aiFoundryAccountName` | string | Name of the AI Foundry account |
| `aiFoundryProjectName` | string | Name of the project within Foundry |
| `connectionName` | string | Unique name for the connection |
| `apimGatewayUrl` | string | APIM gateway URL (e.g., `https://my-apim.azure-api.net`) |
| `apiPath` | string | API path in APIM (e.g., `openai`) |
| `apimSubscriptionKey` | string | APIM subscription key (secure) |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `authType` | string | `'ApiKey'` | Authentication type |
| `isSharedToAll` | bool | `false` | Share with all project users |
| `deploymentInPath` | string | `'true'` | Deployment name in URL path |
| `inferenceAPIVersion` | string | `''` | API version for inference |
| `deploymentAPIVersion` | string | `''` | API version for discovery |
| `staticModels` | array | `[]` | Static model list |
| `listModelsEndpoint` | string | `''` | Custom list endpoint |
| `getModelEndpoint` | string | `''` | Custom get endpoint |
| `deploymentProvider` | string | `''` | Discovery provider format |
| `customHeaders` | object | `{}` | Custom request headers |
| `authConfig` | object | `{}` | Custom auth configuration |

---

## 📦 Sample Configurations

### Using APIM Defaults
```bash
az deployment group create \
  --resource-group <rg> \
  --template-file main.bicep \
  --parameters main.bicepparam
```

### With Static Models
```bash
az deployment group create \
  --resource-group <rg> \
  --template-file main.bicep \
  --parameters samples/static-models.bicepparam
```

### With Custom Headers
```bash
az deployment group create \
  --resource-group <rg> \
  --template-file main.bicep \
  --parameters samples/custom-headers.bicepparam
```

### With Custom Authentication
```bash
az deployment group create \
  --resource-group <rg> \
  --template-file main.bicep \
  --parameters samples/custom-auth.bicepparam
```

---

## 🧪 Using the Connection in Agents

After creating the connection, reference it in your Foundry agent:

```python
import os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

# Configure model deployment name as: {connection-name}/{model-name}
model_deployment = "citadel-hub-connection/gpt-4o"
os.environ["AZURE_AI_MODEL_DEPLOYMENT_NAME"] = model_deployment

# Create agent client
client = AIProjectClient(
    credential=DefaultAzureCredential(),
    endpoint="https://your-foundry.cognitiveservices.azure.com/"
)

# Create and run agent
agent = client.agents.create_agent(
    model=model_deployment,
    name="my-agent",
    instructions="You are a helpful assistant."
)
```

---

## 🔍 Troubleshooting

### Connection Not Appearing

1. Verify you're in the correct subscription:
   ```bash
   az account show
   ```

2. Check deployment succeeded:
   ```bash
   az deployment group show \
     --resource-group <rg> \
     --name <deployment-name>
   ```

### Authentication Errors

1. Verify APIM subscription key is valid
2. Check APIM subscription has access to the API
3. Verify `authConfig` matches APIM expectations

### Model Discovery Failing

1. If using custom discovery, verify endpoints are correct
2. Check `deploymentProvider` matches your API response format
3. Try using static models instead

### Agent Can't Access Models

1. Verify connection is shared (`isSharedToAll = true`) or user has access
2. Check model deployment name format: `{connection-name}/{model-name}`
3. Verify APIM policies allow the request

---

## 📚 References

- [Bring Your Own AI Gateway to Foundry](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/how-to/ai-gateway)
- [APIM Connection Objects](https://github.com/azure-ai-foundry/foundry-samples/blob/main/infrastructure/infrastructure-setup-bicep/01-connections/apim/APIM-Connection-Objects.md)
- [Foundry Samples Repository](https://github.com/azure-ai-foundry/foundry-samples)
- [Azure AI Projects Agent Samples](https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/ai/azure-ai-projects/samples/agents)

---

## ⚠️ Current Limitations

| Limitation | Details |
|------------|---------|
| **Preview Status** | Feature is in preview with potential breaking changes |
| **UI Support** | Requires Azure CLI for connection management |
| **Agent Support** | Supports Prompt Agents in the Agent SDK |
| **APIM Tiers** | Only Standard v2 and Premium tiers supported |
| **Auth Types** | Only ApiKey authentication currently (AAD coming soon) |

