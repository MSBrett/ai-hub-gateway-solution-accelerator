using '../../main.bicep'

// ============================================================================
// HR Chat Agent - Access Contract Request Example
// ============================================================================
// Demonstrates a complex contract with:
//   - Model-specific capacity (gpt-4o, deepseek-r1, text-embedding-3-large)
//   - Content safety (level 4 with prompt shielding)
//   - PII anonymization/deanonymization with state saving
//   - Usage tracking with 2 custom dimensions
//   - Throttling alerts
//
// Deploy:
//   az deployment sub create \
//     --name hr-chatagent-dev \
//     --location swedencentral \
//     --template-file base-access-contract-request/main.bicep \
//     --parameters base-access-contract-request/examples/hr-agent/main.bicepparam
// ============================================================================

param contractRequest = loadJsonContent('access-contract-request.json')
