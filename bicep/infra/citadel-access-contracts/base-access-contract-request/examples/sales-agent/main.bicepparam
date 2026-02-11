using '../../main.bicep'

// ============================================================================
// Sales Assistant - Access Contract Request Example
// ============================================================================
// Demonstrates a minimal contract with:
//   - Model access restricted to gpt-4o and text-embedding-3-large
//   - Subscription-level capacity (1000 TPM, 100K monthly quota)
//   - No content safety, PII handling, usage tracking, or alerts
//
// Deploy:
//   az deployment sub create \
//     --name sales-assistant-dev \
//     --location swedencentral \
//     --template-file base-access-contract-request/main.bicep \
//     --parameters base-access-contract-request/examples/sales-agent/main.bicepparam
// ============================================================================

param contractRequest = loadJsonContent('access-contract-request.json')
