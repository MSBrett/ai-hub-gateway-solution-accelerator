using 'main.bicep'

// ============================================================================
// Agent Access Contract Request - Bicep Parameters Template
// ============================================================================
// This file loads an Agent Access Contract Request JSON file and passes it
// to the main.bicep module for deployment.
//
// Usage:
//   1. Create your access-contract-request.json (use schema for IntelliSense)
//   2. Update the loadJsonContent path below to point to your JSON file
//   3. Deploy:
//      az deployment sub create \
//        --name <deployment-name> \
//        --location <region> \
//        --template-file base-access-contract-request/main.bicep \
//        --parameters main.bicepparam
// ============================================================================

param contractRequest = loadJsonContent('access-contract-request.json')
