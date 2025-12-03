/*
 * @module llm-policy-fragments
 * @description Generates APIM policy fragments with backend pool configurations
 * 
 * This module creates policy fragments that contain the dynamically generated
 * backend pool configurations based on the LLM backend setup. These fragments
 * are used by the Universal LLM API policy to route requests appropriately.
 */

// ------------------
//    PARAMETERS
// ------------------

@description('Name of the API Management service')
param apimServiceName string

@description('Policy fragment configuration from backend pools module')
param policyFragmentConfig object

@description('User-assigned managed identity client ID for authentication')
param managedIdentityClientId string

// ------------------
//    VARIABLES
// ------------------

// Combine backend pools and direct backends for unified routing
var allPools = union(policyFragmentConfig.backendPools, policyFragmentConfig.directBackends)

// Generate C# code for each backend pool with unique variable names
var backendPoolsArray = [for (pool, index) in allPools: replace(replace(replace(replace('// Pool: POOLNAME (Type: POOLTYPE)\nvar pool_INDEX = new JObject()\n{\n    { "poolName", "POOLNAME" },\n    { "poolType", "POOLTYPE" },\n    { "supportedModels", new JArray(MODELS) }\n};\nbackendPools.Add(pool_INDEX);', 'POOLNAME', pool.poolName), 'POOLTYPE', pool.poolType), 'INDEX', string(index)), 'MODELS', join(map(pool.supportedModels, (model) => '"${model}"'), ', '))]

var backendPoolsCode = join(backendPoolsArray, '\n')

// Load policy fragment templates
var setBackendPoolsFragmentTemplate = loadTextContent('./policies/frag-set-backend-pools.xml')
var setBackendAuthorizationFragmentXml = loadTextContent('./policies/frag-set-backend-authorization.xml')
var setTargetBackendPoolFragmentXml = loadTextContent('./policies/frag-set-target-backend-pool.xml')
var setLlmRequestedModelFragmentXml = loadTextContent('./policies/frag-set-llm-requested-model.xml')
var setLlmUsageFragmentXml = loadTextContent('./policies/frag-set-llm-usage.xml')

// Inject generated backend pools code into template
var updatedSetBackendPoolsFragmentXml = replace(setBackendPoolsFragmentTemplate, '//{backendPoolsCode}', backendPoolsCode)

// ------------------
//    RESOURCES
// ------------------

resource apimService 'Microsoft.ApiManagement/service@2024-06-01-preview' existing = {
  name: apimServiceName
}

// Named value for managed identity client ID
resource uamiClientIdNamedValue 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  name: 'uami-client-id'
  parent: apimService
  properties: {
    displayName: 'uami-client-id'
    value: managedIdentityClientId
    secret: false
  }
}

// Policy Fragment: Set Backend Pools
resource setBackendPoolsFragment 'Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview' = {
  name: 'set-backend-pools'
  parent: apimService
  properties: {
    description: 'Dynamically generated backend pool configurations for LLM routing'
    format: 'rawxml'
    value: updatedSetBackendPoolsFragmentXml
  }
}

// Policy Fragment: Set Backend Authorization
resource setBackendAuthorizationFragment 'Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview' = {
  name: 'set-backend-authorization'
  parent: apimService
  properties: {
    description: 'Authentication and routing configuration for different LLM backend types'
    format: 'rawxml'
    value: setBackendAuthorizationFragmentXml
  }
}

// Policy Fragment: Set Target Backend Pool
resource setTargetBackendPoolFragment 'Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview' = {
  name: 'set-target-backend-pool'
  parent: apimService
  properties: {
    description: 'Determines the target backend pool for LLM requests'
    format: 'rawxml'
    value: setTargetBackendPoolFragmentXml
  }
}

// Policy Fragment: Set LLM Requested Model
resource setLlmRequestedModelFragment 'Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview' = {
  name: 'set-llm-requested-model'
  parent: apimService
  properties: {
    description: 'Extracts the requested model from deployment-id (Azure OpenAI) or request body (Inference)'
    format: 'rawxml'
    value: setLlmRequestedModelFragmentXml
  }
}

// Policy Fragment: Set LLM Usage
resource setLlmUsageFragment 'Microsoft.ApiManagement/service/policyFragments@2024-06-01-preview' = {
  name: 'set-llm-usage'
  parent: apimService
  properties: {
    description: 'Collects usage metrics for LLM requests'
    format: 'rawxml'
    value: setLlmUsageFragmentXml
  }
}

// ------------------
//    OUTPUTS
// ------------------

@description('Name of the set-backend-pools fragment')
output setBackendPoolsFragmentName string = setBackendPoolsFragment.name

@description('Name of the set-backend-authorization fragment')
output setBackendAuthorizationFragmentName string = setBackendAuthorizationFragment.name

@description('Name of the set-target-backend-pool fragment')
output setTargetBackendPoolFragmentName string = setTargetBackendPoolFragment.name

@description('Generated backend pools configuration code')
output backendPoolsCode string = backendPoolsCode
