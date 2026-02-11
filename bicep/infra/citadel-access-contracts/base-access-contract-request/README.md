# 📋 Agent Access Contract Request

## Overview

The **Agent Access Contract Request** simplifies the onboarding of AI agents to the Citadel Gateway by replacing the need to manually author `.bicepparam` and APIM policy XML files with a single, user-friendly **JSON configuration file**.

Similar to how a Certificate Signing Request (CSR) is used to issue TLS certificates, the Access Contract Request provides a declarative specification of what an agent needs — models, capacity limits, safety policies, PII handling — and the system automatically generates the correct APIM policy XML and deploys the access contract.

### Before vs. After

| Aspect | Traditional Approach | Agent Access Contract Request |
|--------|---------------------|-------------------------------|
| **Requester provides** | `.bicepparam` + `.xml` policy (technical) | Single `.json` file (user-friendly) |
| **Policy authoring** | Manual XML with APIM expressions | Automatic from JSON flags + values |
| **Bicep knowledge required** | Yes | No (only JSON) |
| **Extensibility** | Edit XML directly | Add JSON fields + XML snippets |
| **Deployment** | `az deployment sub create --parameters main.bicepparam` | Same command, different entry point |

---

## Quick Start

### Step 1: Create your contract request JSON

Create a folder for your agent under `examples/` (or any location), and author an `access-contract-request.json`:

```json
{
  "$schema": "../../access-contract-request.schema.json",
  "contractInfo": {
    "businessUnit": "Sales",
    "useCaseName": "Assistant",
    "environment": "DEV"
  },
  "infrastructure": {
    "apim": {
      "subscriptionId": "YOUR-SUBSCRIPTION-ID",
      "resourceGroupName": "YOUR-APIM-RG",
      "name": "YOUR-APIM-NAME"
    },
    "keyVault": { "enabled": false },
    "foundry": { "enabled": false }
  },
  "apiNameMapping": {
    "LLM": ["universal-llm-api", "azure-openai-api"]
  },
  "services": [
    {
      "code": "LLM",
      "endpointSecretName": "SALES-LLM-ENDPOINT",
      "apiKeySecretName": "SALES-LLM-KEY"
    }
  ],
  "policies": {
    "modelAccess": {
      "enabled": true,
      "allowedModels": ["gpt-4o", "text-embedding-3-large"]
    },
    "capacityManagement": {
      "enabled": true,
      "mode": "subscription-level",
      "subscriptionLevel": {
        "tokensPerMinute": 1000,
        "tokenQuota": 100000,
        "tokenQuotaPeriod": "Monthly"
      }
    }
  }
}
```

### Step 2: Create a minimal `.bicepparam`

```bicep
using '../../main.bicep'

param contractRequest = loadJsonContent('access-contract-request.json')
```

### Step 3: Deploy

```bash
az deployment sub create \
  --name sales-assistant-dev \
  --location swedencentral \
  --template-file base-access-contract-request/main.bicep \
  --parameters examples/sales-agent/main.bicepparam
```

---

## Architecture

### How It Works

```
┌─────────────────────────────┐
│  access-contract-request.json│  ← Requester fills this in
│  (User-friendly JSON)        │
└──────────────┬──────────────┘
               │ loadJsonContent()
               ▼
┌─────────────────────────────┐
│  main.bicepparam             │  ← One-line loader
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐    ┌──────────────────────┐
│  base-access-contract-      │    │  snippets/*.xml      │
│  request/main.bicep         │◄───│  (Policy templates   │
│  (Policy builder + deploy)  │    │   with placeholders) │
└──────────────┬──────────────┘    └──────────────────────┘
               │ Generates policy XML
               │ + passes params
               ▼
┌─────────────────────────────┐
│  citadel-access-contracts/  │
│  main.bicep                 │  ← Existing deployment module
│  (Creates APIM products,    │
│   subscriptions, secrets)   │
└─────────────────────────────┘
```

### Policy Assembly Flow

The Bicep module:
1. Loads the JSON contract request
2. Loads XML snippet templates from the `snippets/` folder
3. Uses `replace()` to fill in values from the JSON (e.g., model names, TPM limits)
4. Conditionally includes/excludes policy sections based on JSON `enabled` flags
5. Assembles the final policy XML from the master template + processed snippets
6. Passes the generated policy and infrastructure params to the existing `main.bicep` module

---

## Repository Structure

```
base-access-contract-request/
├── README.md                               # This documentation
├── access-contract-request.schema.json     # JSON Schema for validation + IntelliSense
├── main.bicep                              # Bicep module: reads JSON → builds policy → deploys
├── main.bicepparam                         # Template .bicepparam (one-line loader)
├── policy-master-template.xml              # Master policy shell with section placeholders
├── snippets/                               # Individual policy XML templates
│   ├── model-extraction.xml                # Extract model parameter from request
│   ├── model-access.xml                    # Model access control (allowedModels)
│   ├── capacity-subscription-level.xml     # Subscription-level token limits
│   ├── capacity-per-model-wrapper.xml      # Per-model capacity <choose> wrapper
│   ├── capacity-per-model-entry.xml        # Per-model <when> entry template
│   ├── content-safety.xml                  # Content safety policy wrapper
│   ├── content-safety-category.xml         # Content safety category entry
│   ├── pii-anonymization-inbound.xml       # PII anonymization (inbound)
│   ├── pii-blocking-inbound.xml            # PII blocking (inbound)
│   ├── pii-regex-entry.xml                 # Custom regex pattern entry (C# fragment)
│   ├── pii-deanonymization-outbound.xml    # PII deanonymization (outbound)
│   ├── pii-state-saving.xml                # PII audit logging to Event Hub
│   ├── usage-tracking.xml                  # Custom dimensions for usage tracking
│   └── alerts-throttling.xml               # Throttling event alerts
└── examples/
    ├── hr-agent/                           # Complex example: full policy suite
    │   ├── access-contract-request.json
    │   └── main.bicepparam
    └── sales-agent/                        # Simple example: minimal policies
        ├── access-contract-request.json
        └── main.bicepparam
```

---

## JSON Schema Reference

The `access-contract-request.schema.json` provides full validation and IntelliSense in VS Code. Reference it in your JSON:

```json
{
  "$schema": "./access-contract-request.schema.json",
  ...
}
```

### Top-Level Structure

| Section | Required | Description |
|---------|----------|-------------|
| `contractInfo` | ✅ | Use case naming, environment, terms |
| `infrastructure` | ✅ | APIM, Key Vault, Foundry coordinates |
| `apiNameMapping` | ✅ | Service code → APIM API name mapping |
| `services` | ✅ | Services to onboard (creates products + subscriptions) |
| `policies` | ❌ | Policy configuration (all sections optional) |

### Contract Info

| Field | Required | Description | Example |
|-------|----------|-------------|---------|
| `businessUnit` | ✅ | Department or team | `"HR"` |
| `useCaseName` | ✅ | Use case identifier (PascalCase) | `"ChatAgent"` |
| `environment` | ✅ | Environment | `"DEV"`, `"PROD"` |
| `description` | ❌ | Human-readable description | `"HR Chat Agent..."` |
| `productTerms` | ❌ | Terms shown to subscribers | `"For HR use only"` |

### Infrastructure

| Field | Required | Description |
|-------|----------|-------------|
| `apim` | ✅ | `{ subscriptionId, resourceGroupName, name }` |
| `keyVault` | ❌ | `{ enabled, subscriptionId, resourceGroupName, name }` |
| `foundry` | ❌ | `{ enabled, subscriptionId, resourceGroupName, accountName, projectName, config? }` |

### Policy Options

All policy sections follow the same pattern: set `"enabled": true` to activate, provide configuration values. Omitted or `"enabled": false` sections are excluded from the generated policy.

#### Model Access (`policies.modelAccess`)

Controls which LLM models a product can access using the `validate-model-access` policy fragment.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | `false` | Enable model access control |
| `allowedModels` | string[] | `[]` | List of allowed model names |

#### Capacity Management (`policies.capacityManagement`)

Token rate limiting and quota management using `llm-token-limit` policy.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | `false` | Enable capacity management |
| `mode` | string | `"subscription-level"` | `"subscription-level"` or `"per-model"` |
| `subscriptionLevel` | object | - | `{ tokensPerMinute, tokenQuota, tokenQuotaPeriod }` |
| `perModel` | array | `[]` | Array of `{ model, tokensPerMinute, tokenQuota, tokenQuotaPeriod }` |
| `defaultModel` | object | - | Default limits for unlisted models (per-model mode) |

**Subscription-level** applies a single token limit for all models. **Per-model** creates individual `<when>` conditions for each model with its own limits + a fallback default.

#### Content Safety (`policies.contentSafety`)

Azure AI Content Safety enforcement using `llm-content-safety` policy.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | `false` | Enable content safety |
| `shieldPrompt` | bool | `true` | Enable prompt shielding |
| `categories` | array | `[]` | Array of `{ name, threshold }` |

Available categories: `Hate`, `Violence`, `SelfHarm`, `Sexual`. Threshold: 0 (most restrictive) to 7 (most permissive).

#### PII Handling (`policies.piiHandling`)

PII detection and processing using Azure AI Language Service.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | `false` | Enable PII processing |
| `mode` | string | `"anonymize"` | `"anonymize"` or `"block"` |
| `confidenceThreshold` | string | `"0.8"` | Detection confidence (string format, e.g. `"0.8"`) |
| `entityCategoryExclusions` | string | `""` | Categories to exclude (e.g., `"PersonType"`) |
| `language` | string | `"en"` | Detection language (`"auto"` for multilingual) |
| `stateSaving` | bool | `false` | Log PII activity to Event Hub (anonymize mode only) |
| `customRegexPatterns` | array | `[]` | Array of `{ pattern, category }` |

**Anonymize mode**: Replaces PII with placeholders in the request, restores in the response. **Block mode**: Rejects requests containing PII with HTTP 400.

> **Note**: `confidenceThreshold` must be a **string** (e.g., `"0.8"`) not a number, due to Bicep's integer-only type system.

#### Usage Tracking (`policies.usageTracking`)

Custom dimensions for LLM usage reporting.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | `false` | Enable custom usage dimensions |
| `appIdHeader` | string | `"x-app-id"` | Header for application ID |
| `customDimension1` | object | - | `{ header, default }` for first custom dimension |
| `customDimension2` | object | - | `{ header, default }` for second custom dimension |

#### Alerts (`policies.alerts`)

Alerting configuration for monitoring.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | `false` | Enable alerting features |
| `throttlingEvents` | bool | `false` | Raise events on HTTP 429 for App Insights alerting |

---

## Examples

### HR Agent (Complex - Full Policy Suite)

The HR Agent demonstrates every available policy:
- **3 models** (`gpt-4o`, `deepseek-r1`, `text-embedding-3-large`) with per-model capacity limits
- **Content safety** at threshold 4 with prompt shielding
- **PII anonymization** with custom regex patterns and Event Hub state saving
- **Usage tracking** with 2 custom dimensions (`x-sub-agent-id`, `x-enduser-id`)
- **Throttling alerts** enabled

See: [examples/hr-agent/access-contract-request.json](examples/hr-agent/access-contract-request.json)

### Sales Agent (Minimal - Basic Access)

The Sales Agent shows the simplest contract:
- **2 models** (`gpt-4o`, `text-embedding-3-large`) with model access control
- **Subscription-level capacity** (1000 TPM, 100K monthly quota)
- No content safety, PII, tracking, or alerts

See: [examples/sales-agent/access-contract-request.json](examples/sales-agent/access-contract-request.json)

---

## Extending with New Policies

The system is designed to be extensible. To add a new policy option:

### 1. Create a new XML snippet

Add a new file under `snippets/` with `{{PLACEHOLDER}}` markers for configurable values:

```xml
<!-- snippets/my-new-policy.xml -->
        <!-- My New Policy -->
        <my-policy-element attribute="{{MY_VALUE}}" />
```

> **Indentation**: Snippets should use 8 spaces of indentation to align with the `<inbound>`, `<outbound>`, or `<on-error>` sections in the master template.

### 2. Update the JSON schema

Add the new policy section to `access-contract-request.schema.json` under `policies.properties`:

```json
"myNewPolicy": {
  "type": "object",
  "properties": {
    "enabled": { "type": "boolean", "default": false },
    "myValue": { "type": "string" }
  }
}
```

### 3. Update the Bicep module

In `main.bicep`, follow the established pattern:

```bicep
// 1. Load the new snippet template
var snippetMyNewPolicy = loadTextContent('snippets/my-new-policy.xml')

// 2. Read configuration from JSON
var myNewPolicyEnabled = policiesConfig.?myNewPolicy.?enabled ?? false
var myValue = policiesConfig.?myNewPolicy.?myValue ?? 'default'

// 3. Build the section with value substitution
var myNewPolicyXml = myNewPolicyEnabled
  ? replace(snippetMyNewPolicy, '{{MY_VALUE}}', myValue)
  : ''

// 4. Add to the appropriate sections array (inbound/outbound/on-error)
var inboundSections = flatten([
  // ... existing sections ...
  myNewPolicyEnabled ? [myNewPolicyXml] : []
])
```

### Design Principles

| Principle | Description |
|-----------|-------------|
| **Snippets are self-contained** | Each XML snippet contains a complete, valid policy block |
| **Placeholders use `{{NAME}}`** | Simple, unambiguous marker format for `replace()` |
| **Bicep handles logic** | Conditional inclusion and value substitution at compile time |
| **JSON is the source of truth** | Requester never touches XML or Bicep |
| **Additive extensibility** | New policies = new snippet + new JSON field + Bicep wiring |

---

## Deployment Notes

### Prerequisites

Same as the standard [Citadel Access Contracts prerequisites](../README.md#-prerequisites):
- Citadel-compliant APIM instance with published APIs
- Key Vault (if `keyVault.enabled = true`)
- AI Foundry account and project (if `foundry.enabled = true`)
- Appropriate RBAC permissions

### Deployment Command

```bash
# From the citadel-access-contracts directory
az deployment sub create \
  --name <deployment-name> \
  --location <region> \
  --template-file base-access-contract-request/main.bicep \
  --parameters <path-to>/main.bicepparam
```

### Inspecting Generated Policy

The deployment outputs include `generatedPolicyXml` for debugging:

```bash
az deployment sub show \
  --name <deployment-name> \
  --query properties.outputs.generatedPolicyXml.value \
  --output tsv
```

### Migrating from Traditional Contracts

Existing `.bicepparam` + `.xml` contracts remain fully supported. The Agent Access Contract Request is an alternative entry point that generates the same artifacts. You can:

1. **Inspect the generated policy**: Use the `generatedPolicyXml` output to see what was produced
2. **Compare with manual policies**: Validate the generated output matches your expectations
3. **Mix approaches**: Use contract requests for standard use cases and manual policies for custom scenarios
