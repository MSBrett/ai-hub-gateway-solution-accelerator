# Microsoft Foundry Integration

Microsoft Foundry is a comprehensive AI and agentic development platform that enables organizations to build, deploy, and manage AI-powered applications and agents at scale. 

Following a hub-spoke governance model, this integration allows you to seamlessly connect various line-of-business agentic applications built on top of Microsoft Foundry to the centralized governance hub, enabling secure AI capabilities within your applications.

## Overview

This integration enables organizations to:

- Maintain control over their model endpoints. Keep your model endpoints secure behind your existing governance hub.
- Build agents that leverage models without exposing them publicly.
- Apply your organization's compliance and governance requirements to AI model access.

## Prerequisites
- Existing deployment of Citadel Governance Hub gateway (APIM)
- Existing deployment of Microsoft Foundry that target specific use-case or provisioned to be used by an assigned business unit.
    - It is recommended to have a dedicated Foundry project for each line-of-business application or use-case that requires AI capabilities.
    - It is recommended to have an Azure Key Vault linked to Foundry project to securely store any secrets or credentials needed for accessing the governance hub.
- Citadel Access Contract provisioned to allow access from Foundry to the Governance Hub.
- Appropriate networking setup in place that allows Foundry to reach the Governance Hub gateway (private connectivity is the default recommendation).
- Appropriate permissions on both governance hub AI Gateway and target Foundry resource/project.

## Deployment

Basically deployment is a about creating a new API Management connection in target Foundry resource/project that points to the Citadel Governance Hub gateway endpoint and leverages the Citadel Access Contract keys and endpoints.

### Deployment with Key Vault

This deployment assumes that Citadel Access Contract is already provisioned with target Key Vault already have contract secrets (llm-endpoint and llm-key) provisioned.

### Deployment with direct access to Citadel's AI Gateway

This deployment assumes that Citadel Access Contract is already provisioned and you have the Citadel's APIM direct access details (name, resource group, subscription, target api-id, APIM product subscription id,... etc.) to be provided during deployment.

### Deployment without Key Vault

This deployment assumes that Citadel Access Contract is already provisioned but without Key Vault integration. In this case, the LLM endpoint and key values need to be provided directly during deployment.

## Post-deployment validation

