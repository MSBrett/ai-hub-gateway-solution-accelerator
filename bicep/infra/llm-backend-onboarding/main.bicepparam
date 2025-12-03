using 'main.bicep'

// ============================================================================
// LLM Backend Onboarding - Parameter File
// ============================================================================
// This parameter file configures LLM backends for an existing APIM instance.
// It creates backend resources, backend pools, and policy fragments for
// dynamic model-based routing.
//
// REQUIRED PARAMETERS: apim, apimManagedIdentity, llmBackendConfig
// OPTIONAL PARAMETERS: configureCircuitBreaker, deployUniversalLlmApi, universalLlmApiPath, tags
// ============================================================================

// ============================================================================
// REQUIRED: API Management (APIM) Configuration
// ============================================================================
// Specifies the target APIM instance where LLM backends will be onboarded.
// This APIM instance should already exist and have the necessary networking
// and security configurations in place.
//
// Properties:
// - subscriptionId: Azure subscription ID where APIM is deployed
// - resourceGroupName: Resource group containing the APIM instance
// - name: Name of the APIM service instance
// ============================================================================
param apim = {
  subscriptionId: '00000000-0000-0000-0000-000000000000' // Replace with your subscription ID
  resourceGroupName: 'rg-citadel-governance-hub'         // Replace with your APIM resource group
  name: 'apim-citadel-governance-hub'                    // Replace with your APIM name
}

// ============================================================================
// REQUIRED: APIM Managed Identity Configuration
// ============================================================================
// Specifies the user-assigned managed identity used by APIM for backend
// authentication. This identity must have the appropriate RBAC roles:
// - Cognitive Services OpenAI User (for Azure OpenAI backends)
// - Cognitive Services User (for AI Foundry backends)
//
// Properties:
// - subscriptionId: Azure subscription ID where the identity is deployed
// - resourceGroupName: Resource group containing the managed identity
// - name: Name of the user-assigned managed identity
// ============================================================================
param apimManagedIdentity = {
  subscriptionId: '00000000-0000-0000-0000-000000000000' // Replace with your subscription ID
  resourceGroupName: 'rg-citadel-governance-hub'         // Replace with your identity resource group
  name: 'id-apim-citadel'                                // Replace with your managed identity name
}

// ============================================================================
// REQUIRED: LLM Backend Configuration Array
// ============================================================================
// Defines all LLM backends that APIM will route requests to. Each backend
// object should have:
//
// Required Properties:
// - backendId: Unique identifier (used in APIM backend resource name)
// - backendType: 'ai-foundry' | 'azure-openai' | 'external'
// - endpoint: Base URL of the LLM service
// - authScheme: 'managedIdentity' | 'apiKey' | 'token'
// - supportedModels: Array of model names (e.g., ['gpt-4o', 'gpt-4o-mini'])
//
// Optional Properties:
// - priority: 1-5, default 1 (lower = higher priority for load balancing)
// - weight: 1-1000, default 100 (higher = more traffic share)
//
// Example configurations for different scenarios are shown below.
// ============================================================================
param llmBackendConfig = [
  // ----------------------------------
  // AI Foundry Backend - Primary
  // ----------------------------------
  // This backend connects to an Azure AI Foundry project endpoint
  // Models deployed in AI Foundry use the OpenAI-compatible inference API
  {
    backendId: 'aif-citadel-primary'
    backendType: 'ai-foundry'
    endpoint: 'https://aif-RESOURCE_TOKEN-0.services.ai.azure.com/models' // Replace with your AI Foundry endpoint
    authScheme: 'managedIdentity'
    supportedModels: [
      'gpt-4o'
      'gpt-4o-mini'
      'DeepSeek-R1'
      'Phi-4'
    ]
    priority: 1
    weight: 100
  }
  
  // ----------------------------------
  // AI Foundry Backend - Secondary (Different Region)
  // ----------------------------------
  // For load balancing and failover, add backends in different regions
  // Models shared with primary backend will be load balanced
  {
    backendId: 'aif-citadel-secondary'
    backendType: 'ai-foundry'
    endpoint: 'https://aif-RESOURCE_TOKEN-1.services.ai.azure.com/models' // Replace with your secondary AI Foundry endpoint
    authScheme: 'managedIdentity'
    supportedModels: [
      'gpt-5'
      'DeepSeek-R1'
    ]
    priority: 2
    weight: 50
  }

  // ----------------------------------
  // Azure OpenAI Backend (Optional)
  // ----------------------------------
  // Uncomment to add Azure OpenAI Service endpoints
  // {
  //   backendId: 'aoai-eastus-gpt4'
  //   backendType: 'azure-openai'
  //   endpoint: 'https://YOUR-AOAI-RESOURCE.openai.azure.com/openai'
  //   authScheme: 'managedIdentity'
  //   supportedModels: [
  //     'gpt-4'
  //     'gpt-35-turbo'
  //     'text-embedding-ada-002'
  //   ]
  //   priority: 1
  //   weight: 100
  // }
]

// ============================================================================
// OPTIONAL: Circuit Breaker Configuration
// ============================================================================
// Enable circuit breaker for backend resilience. When enabled, APIM will
// temporarily stop routing to backends that are experiencing failures.
//
// Recommended: true for production environments
// ============================================================================
param configureCircuitBreaker = true

// ============================================================================
// OPTIONAL: Deploy Universal LLM API
// ============================================================================
// Set to true to deploy the Universal LLM API endpoints (/llm/openai and /llm/models)
// Set to false if the API already exists and you only want to update backends
// ============================================================================
param deployUniversalLlmApi = false

// ============================================================================
// OPTIONAL: Universal LLM API Path
// ============================================================================
// The base path for the target LLM API in APIM (universal llm or legacy Azure OpenAI)
// The final endpoints will be:
// - {gateway-url}/{apiPath}/openai/... (OpenAI-compatible endpoint)
// - {gateway-url}/{apiPath}/models/... (Models inference endpoint)
// ============================================================================
param universalLlmApiPath = 'models'
