# 🏰 Citadel Governance Hub

<div align="center">
    <img src="./assets/citadel-logo-v2.PNG" alt="Citadel Logo" width="120" style="margin-bottom: 10px;">
    <br>
    <strong>Enterprise AI Landing Zone</strong>
    <br>
    <em>A comprehensive solution accelerator for governing, observing, and accelerating AI deployments at scale with unified security, compliance, and intelligent orchestration.</em>
</div>

---

## 🎯 The AI Governance Imperative

As AI systems become more powerful and integrated into everyday life, **governance is no longer a "nice-to-have"; it's a must**. Whether you're aligning to emerging regulations like the EU AI Act, meeting internal standards for risk and safety, or ensuring your AI systems are meeting your enterprise's business goals with scale and efficiency, the ability to govern AI responsibly at speed is a game-changer.

Yet, **governance and developer velocity often feel fundamentally misaligned**. Organizations face critical bottlenecks:

- **Manual Risk Assessments**: Frequently time-consuming and lacking standardization
- **Scattered Evaluation Tools**: Fragmented across different teams and systems
- **Unclear Governance Requirements**: Ambiguous policies that are difficult to operationalize
- **Implementation Gaps**: Policies rarely map cleanly to real-world technical implementation

**The result?** Bottlenecks and delays that frustrate both governance teams and developers, slowing AI adoption and increasing organizational risk.

**AI Citadel Governance Hub turns these challenges into platform strengths** — governed access, transparent consumption, defensible guardrails, and a shared catalog of reusable AI capabilities.

For comprehensive guidance on the approach to AI governance, check out [Foundry Citadel Platform](https://aka.ms/foundry-citadel).

---

## 🚀 What is AI Citadel Governance Hub?

Citadel Governance Hub is an **enterprise-grade AI landing zone** that establishes a centralized, governable, and observable control plane for all AI service consumption across multiple teams, use cases, and environments. 

Instead of fragmented, unmonitored, master-key model access, Citadel Governance Hub provides a **unified AI gateway pattern** built on Azure API Management (APIM), adding:
- ✅ Intelligent routing and load balancing
- ✅ Security enforcement and compliance guardrails  
- ✅ Usage analytics and cost attribution
- ✅ AI registry for agents, tools, and services
- ✅ Automated onboarding and governance workflows

This elevates AI consumption from **ad-hoc experimentation to scalable, auditable, and cost-attributable platform capability**.

---

## 🏛️ Three Pillars of AI Citadel

AI Citadel Governance Hub is built on three foundational pillars that address enterprise AI adoption challenges end-to-end:

### 1️⃣ **Governance & Security Pillar** – Trustworthy AI Operations at Scale

**🔐 Why Governance Matters:** Without centralized AI governance, organizations face unpredictable costs, reliability issues, security risks, developer friction, and compliance nightmares. AI Citadel fixes this by building guardrails into every AI call.

**Key Capabilities:**

| Capability | Description |
|------------|-------------|
| **🚪 Unified AI Gateway** | Central entry point (APIM) for all AI requests with consistent policy enforcement |
| **🗝️ Managed Credentials** | Gateway-keys pattern replaces master API keys with scoped, revocable tokens and support for JWT tokens |
| **🛡️ Policy Enforcement** | Granular access control, rate/token limiting, token quotas, and traffic mediation |
| **🌐 Multi-Cloud Support** | Govern Azure OpenAI, open-source models, third-party models under one umbrella |
| **🛡️ AI Content Safety** | Built-in Azure AI Content Safety with prompt shields, harmful content detection, and protected content checks |
| **📊 Cost Governance** | Centralized logging, usage tracking, and cost attribution by team/application |
| **📘 AI Registry** | Unified catalog for LLMs, AI tools (through Model Context Protocol (MCP)), and agents |
| **🔒 Data Security** | Built-in support for PII detection in addition to Microsoft Purview integration for sensitivity labels and data governance |

---

### 2️⃣ **Observability & Compliance Pillar** – End-to-End Monitoring, Evaluation & Trust

**📊 Full Visibility = Trust & Confidence:** AI Citadel provides holistic observability through a dual-layer approach ensuring teams can debug issues, assure quality, and govern compliance in real-time.

#### 🏗️ **Platform-Level Observability**
As part of AI Citadel Governance Hub, a centralized monitoring without requiring agent code changes provides:

| Feature | Description |
|---------|-------------|
| **📊 Central Application Performance Monitoring** | Azure Monitor and Application Insights for infrastructure metrics and system health |
| **📈 Usage Tracking** | Token consumption, request volumes, cost allocation by team/use case/agent |
| **🔍 Centralized AI Evaluation** | Automated quality evaluations (groundedness, relevance, coherence, safety) without code changes |
| **🚨 Enterprise Alerts** | Configurable alerts with automated remediation and compliance reporting |

Platform observability is enabled out-of-the-box for all AI workloads routing through the AI Citadel Governance Hub.

---

### 3️⃣ **AI Development Velocity Pillar** – Accelerating Innovation with Templates & Tools

**🚀 Build Fast, Build Right:** AI Citadel Governance Hub support integrating existing agents and tools in addition to support integrating new agents which enable teams to experiment and innovate quickly without sacrificing governance or quality.

AI Citadel Governance Hub provides automatable agent onboarding configurations through **Citadel Access & Publish Contracts** along with reusable blueprints and templates for common AI patterns.

**Key Capabilities:**

| Capability | Description |
|------------|-------------|
| **🚀 Citadel Access Contract** | Govern the required access to LLMs and centrally managed tools and agents |
| **🤖 Citadel Publish Contract** | Provide the ability to publish agents and tools on AI Citadel Governance Hub |
| **📘 Citadel AI Registry** | Central catalog for discovering, managing, and reusing AI assets across the enterprise |
| **🔄 DevOps Integration** | Automate and source control both access and publish AI Citadel Contracts |

---

## 🎯 Key Use Cases

Citadel Governance Hub enables secure, scalable AI deployment across diverse enterprise scenarios:

### 💼 **Enterprise AI Governance**
- Centralized access control for all AI services across departments
- Cost attribution and chargeback to business units
- Compliance reporting and audit trails
- Shadow AI prevention and policy enforcement

### 🤖 **Multi-Agent Systems**
- Discover and reuse agents through the AI Registry
- Govern agent-to-agent communication
- Monitor multi-agent workflows end-to-end
- Enforce safety guardrails across agent interactions

### 🌐 **Multi-Cloud AI Strategy**
- Unified governance across Azure OpenAI, AWS Bedrock, and open-source models
- Consistent security policies regardless of backend
- Seamless migration and failover between providers
- Cost optimization through intelligent routing

### 🔒 **Regulated Industries**
- Financial services compliance (SOC 2, PCI DSS)
- Healthcare data protection (HIPAA)
- Government security requirements (FedRAMP)
- PII detection and anonymization

### 📊 **AI Operations at Scale**
- Support thousands of concurrent AI applications
- Near real-time usage monitoring and alerts
- Capacity planning and quota management
- Performance optimization and troubleshooting

---

## 🏗️ Architecture Overview

AI Citadel Governance Hub follows a **hub-spoke architecture** that integrates seamlessly with your existing enterpriseAzure Landing Zone:

![Citadel Governance Hub](./assets/citadel-governance-hub-v1.png)

### Networking approach

Detailed networking approach guidance for Citadel Governance Hub can be found in the [Network Approach Guide](./guides/network-approach.md).

Below is a high-level overview of the two supported deployment approaches:

#### Part of the hub network

In this approach, the Citadel Governance Hub is deployed within the existing hub virtual network (VNet) of your Azure Landing Zone.

This allows for direct communication between the unified AI gateway and connected agentic spokes, leveraging existing security and networking configurations.

#### Part of spoke network

In this approach, the Citadel Governance Hub is deployed within a dedicated spoke VNet that connects to the hub VNet via VNet peering. 

Agentic workloads in other spokes are routed first to the hub network firewall through direct peering, then forwarded to the Citadel Governance Hub gateway network.

This provides an additional layer of isolation for AI workloads while still enabling secure communication with other enterprise resources in the hub.

### 🎯 **Citadel Governance Hub** - Central Control Plane

The central governance layer with unified AI Gateway that all AI workloads route through.

#### Core Components

| Component | Purpose | Enterprise Features |
|-----------|---------|---------------------|
| **🚪 API Management** | Unified AI gateway | LLM governance, AI resiliency, AI registry gateway |
| **📘 API Center** | Universal AI Registry | Discovery of available AI tools, agents and AI services |
| **🔍 Microsoft Foundry** | Control Plane/Models/Observability | Platform LLMs, Control Plane & AI Evaluations |
| **📊 Log Analytics** | Logs, metrics & audits | Scalable enterprise telemetry ingestion and storage |
| **📊 Application Insights** | Platform monitoring | Performance dashboards, automated alerts |
| **📨 Event Hub** | Usage data streaming | Real-time usage streaming, custom logging |
| **🗄️ Cosmos DB** | Usage analytics | Long-term storage of usage, automatic scaling |
| **⚡ Logic App** | Event processing | Workflow-based processing of usage/logs & AI Eval |
| **🔗 Virtual Network** | Private connectivity | BYO-VNET support, private endpoints |

#### Security & Compliance

AI Gateway security & compliance enforcements components:

| Component | Purpose |Enterprise Features |
|---------|---------|---------------------|
| **🔐 Managed Identity** | Zero-credential auth | Secure service-to-service communication |
| **🛡️ Content Safety** | LLM protection | Prompt Shield and Content Safety protections |
| **💳 Language Service** | PII detection | Natural language and RegEx based PII entity detection with anonymization support |
| **🔍 Microsoft Foundry** | Control Plane | Control plane, responsible AI, registration of external agents  |

Supported by subscription wide security services:

| Component | Purpose |Enterprise Features |
|---------|---------|---------------------|
|**Defender for AI**|Threat protection|AI workload security posture management|
|**Purview**|Data governance|Sensitivity labeling, data classification|
|**Entra ID**|Identity & access management|Zero Trust architecture, conditional access|

#### AI Services

Optionally you can deploy one or more generative AI services as part of the Citadel Governance Hub to provide fully functional gateway with LLMs already integrated:

| Component | Purpose | Enterprise Features |
|---------|---------|---------------------|
| **Microsoft Foundry** | LLM model hosting | Access to rich foundational model catalog with variety of deployment options |

#### Optional Components

Pluggable components to enhance AI Citadel Governance capabilities:

| Component | Purpose |
|-----------|---------|
| **Azure Managed Redis** | Semantic caching layer for high-throughput AI workloads |

### 🌐 **Citadel Compliant Agents** - Existing and new agents on-boarding

To govern AI agents through AI Citadel Governance Hub, agents must communicate with AI backends (central LLMs, tools and agents) through the Citadel's unified AI gateway.

#### Existing agents

Guidance to bring existing agents is through updating endpoint and credentials to access central LLMs, tools and agents through the **unified gateway**.

Recommendation is to use Azure Key Vault to store these information due to its sensitivity when the agent is running on Azure.

Leverage **Citadel Access Contracts** to declare the required access to LLMs, tools and agents through the gateway along with precise governance policies.

#### New agents

Building new agents is accelerated through the **Citadel Agent Spoke** landing zone guidance, which provides isolated, secure environments designed specifically for AI agent development and deployment. Each spoke serves a single business unit or major use case, ensuring clear boundaries, simplified management, and integration with the Citadel Governance Hub for centralized governance.

**Deployment Approach:**
- **One spoke per business unit or use case** - Dedicated environments for insurance claims processing, customer support automation, or other agentic scenarios
- **Flexible runtime options** - Choose between Microsoft Foundry Agents (fully managed runtime) or Azure Container Apps (bring-your-own-agent)
- **Pre-configured infrastructure** - Automated deployment via Bicep or Terraform with all networking, security, and monitoring built-in
- **Hub integration** - Seamless connection to Citadel Governance Hub through Citadel Access & Publish Contracts

**Core Infrastructure Components:**

| Component | Purpose |
|-----------|---------|
| **🤖 Microsoft Foundry** | Managed agent runtime with rich SDK, prompt flow orchestration, and native AI Evaluations |
| **📦 Azure Container Apps** | Serverless container hosting for custom-built agents with auto-scaling and simplified deployment |
| **🔍 Azure AI Search** | Vector and hybrid search for RAG patterns and document indexing |
| **🗄️ Azure Cosmos DB** | Distributed NoSQL database for agent state, threads, and multi-agent coordination |
| **💾 Azure Storage** | Blob storage for Logic App, Microsoft Foundry datasets, agent assets, and shared files |
| **🔐 Azure Key Vault** | Secure secrets, keys, and certificates with automated rotation |
| **📊 Application Insights** | Detailed monitoring, diagnostics, and alerts integrated with platform-level observability |
| **🔒 Virtual Network** | Private connectivity with subnets for compute, agents, data, and management |

**Deployment Patterns:**
- **Greenfield (Standalone with New Resources)** - Creates all infrastructure from scratch with new VNet and Log Analytics workspace
- **Brownfield (Standalone with Existing Resources)** - Integrates with existing enterprise landing zones, reusing VNets and centralized monitoring

> **Note:** Citadel Agent Spoke deployment supports the AI development velocity pillar and is designed to work in conjunction with Citadel Governance Hub. Multiple spokes can connect to a single hub for unified governance and observability.

---

## 🔄 AI Citadel Contracts - Connect agents to governance hub

Citadel Governance Hub seamlessly integrates with **Citadel compliant Agents** environments through automated governance alignment:

### 📝 **AI Access Contract**
Declares the governed dependencies an agent needs—LLMs, AI services, tools, and reusable agents—along with precise access policies:
- Model selection and capacity allocation
- Regional preferences and compliance requirements
- Safety and security guardrails
- Usage quotas and cost limits

### 📤 **AI Publish Contract**
Describes the tools and agents a spoke exposes back to the hub:
- Publishing rules and governance gates
- Ownership metadata and documentation
- Security posture and compliance status
- Discovery and cataloging in the AI Registry

**Benefits:**
- ✅ Audit-ready traceability through infrastructure-as-code
- ✅ Faster release cycles with automated approvals
- ✅ Reduced manual effort in governance onboarding
- ✅ Continuous policy compliance verification

> 🔗 **Learn More:** [Citadel Access Contracts Guide](./guides/Citadel-Access-Contracts.md)

---

## 📋 Prerequisites

**Azure Requirements:**
- **Azure CLI** and **Azure Developer CLI** installed and signed in
- A **resource group** in your target subscription  
- **Owner** or **Contributor + User Access Administrator** permissions on the subscription
- All required subscription resource providers registered.

**Development Tools:**
Although it is recommended to have the below tools installed on a local machine or through DevOps agents to conduct the provisioning, you still can leverage Azure Cloud Shell (mounted to storage account) as an alternative which has all the tools pre-installed.
- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [VS Code](https://code.visualstudio.com/Download) (optional)

---

## 🚀 Quick Deploy

Deploy your Citadel Governance Hub in minutes with Azure Developer CLI:

```bash
# Authenticate and setup environment
azd auth login

# in a new folder, initialize the template (i.e. folder name: ai-hub-citadel-dev)
azd init --template Azure-Samples/ai-hub-gateway-solution-accelerator -e ai-hub-citadel-dev --branch citadel-v1

# Deploy Citadel Governance Hub
azd up
```

> 💡 **Tip**: Use Azure Cloud Shell to avoid local setup. Review [main.bicep](./bicep/infra/main.bicep) and [main.bicepparam](./bicep/infra/main.bicepparam) configuration before deployment.

### ✅ Post-Deployment Validation

After successful deployment, validate your Citadel Governance Hub setup using our interactive notebooks.

### 🧪 Validation Notebooks

Use the following interactive Jupyter notebooks to validate and configure your Citadel Governance Hub deployment:

| Notebook | Description |
|----------|-------------|
| [**Citadel Governance Hub Primary Tests**](./validation/citadel-governance-hub-primary-tests.ipynb) | Test governance hub managed models through APIM. Includes Citadel Access Contract creation, API testing, token rate limiting validation, and streaming tests. |
| [**LLM Backend Onboarding Runner**](./validation/llm-backend-onboarding-runner.ipynb) | Onboard existing LLMs (Microsoft Foundry models, Azure OpenAI, and others) into the AI Gateway. Generates source-controllable parameter files for LLM backends configuration. |

> 💡 **Tip**: These notebooks require Python with the `openai`, `requests`, and `matplotlib` among other packages highlighted in [requirements.txt](./validation/requirements.txt). Ensure you have configured your environment variables before running.

---

## 📚 Comprehensive Documentation

Master AI Citadel Governance Hub implementation and operations with our detailed guides:

### 🏗️ **Landing zone deployment**

| Guide | Description |
|-------|-------------|
| [**🆕 Quick Deployment Guide**](./guides/quick-deployment-guide.md) | Fast deployment for non-production environments |
| [**🆕 Full Deployment Guide**](./guides/full-deployment-guide.md) | Comprehensive guide for dev, staging, and production |
| [**🆕 Parameters Deployment Guide**](./guides/parameters-usage-guide.md) | Comprehensive Bicep parameter file usage |
| [**🆕 Network Approach Guide**](./guides/network-approach.md) | Detailed networking approach for Citadel Governance Hub deployment |

### 🔧 **AI Service Integration**

| Guide | Description |
|-------|-------------|
| [**🆕 LLM Backend Onboarding Guide**](./guides/LLM-Backend-Onboarding-Guide.md) | Independent LLM backend routing deployment with load balancing and failover |

### 🔧 **Use-case Onboarding**

| Guide | Description |
|-------|-------------|
| [**🆕 AI Citadel Access Contracts Guide**](./guides/citadel-access-contracts.md) | Guide on integrating new/existing AI apps & agents with AI Citadel Governance Hub |

### 🛡️ **Security & Compliance**

| Guide | Description |
|-------|-------------|
| [**🆕 PII Detection & Masking**](./guides/pii-masking-apim.md) | Automated sensitive data protection |
| [**🆕 Entra ID Authentication**](./guides/entraid-auth-validation.md) | JWT validation and Zero Trust implementation |

### 📊 **Observability & Analytics**

| Guide | Description |
|-------|-------------|
| [Power BI Dashboard](./guides/power-bi-dashboard.md) | Usage analytics and cost allocation dashboards |

### 🏗️ **Architecture & configurations**

| Guide | Description |
|-------|-------------|
| [**🆕 LLM Routing Architecture**](./guides/llm-routing-architecture.md) | Technical dive into LLM model and backend routing logic |

### ⚙️ **Advanced Capabilities**

| Guide | Description |
|-------|-------------|

---

## 🌟 What Makes Citadel Different?

| Traditional Approach | Citadel Governance Hub |
|---------------------|------------------------|
| ❌ Direct API key access per team | ✅ Centralized gateway with managed credentials |
| ❌ Fragmented monitoring per service | ✅ Unified observability across all AI workloads |
| ❌ Manual cost tracking and allocation | ✅ Automated usage tracking and charge-back |
| ❌ Inconsistent security policies | ✅ Enforced guardrails on every AI call |
| ❌ Shadow AI and governance gaps | ✅ Complete visibility and control |
| ❌ Slow onboarding and provisioning | ✅ Automated templates and reusable blueprints |

---

## 🏆 Benefits by Stakeholder

### 👨‍💼 **For CIOs & Business Leaders**
- **Accelerate AI ROI** - Deploy AI solutions 10x faster with pre-built templates
- **Reduce Risk** - Enforce compliance and security policies automatically
- **Control Costs** - Precise cost attribution and quota management
- **Demonstrate Governance** - Audit-ready compliance and transparency

### 👨‍💻 **For Developers & Data Scientists**
- **Focus on Innovation** - Governance handled by the platform
- **Self-Service Access** - Discover and consume AI services through the registry
- **Rich Tooling** - Support for Copilot Studio, Semantic Kernel, LangChain, AutoGen
- **Fast Iteration** - CI/CD integration with automated testing

### 🛡️ **For Security & Compliance Teams**
- **Zero Trust Architecture** - Private endpoints and managed identities throughout
- **Content Safety** - Automatic prompt and response filtering
- **PII Protection** - Detect and redact sensitive data automatically
- **Audit Trails** - Complete logging and trace capabilities

### 📊 **For Operations Teams**
- **Single Pane of Glass** - Unified monitoring across all AI workloads
- **Proactive Alerting** - Detect and remediate issues before impact
- **Performance Insights** - Detailed traces and analytics
- **Capacity Planning** - Usage trends and forecasting

---

## 🗺️ Roadmap & Evolution

Citadel Governance Hub is continuously evolving as part of the **Foundry Citadel Platform** vision:

### ✅ **Current Release**
- Unified AI Gateway with intelligent routing
- Platform observability
- Automated LLM onboarding with model-aware resilient routing
- Universal LLM, Azure OpenAI, Azure OpenAI Realtime, AI Search, Document Intelligence integration
- PII detection and masking
- Content safety enforcements
- Usage analytics and cost management
- Citadel Access Contracts support with automated onboarding
- AI Registry for models and tools
- Authentication support with Gateway keys or with both Gateway keys and JWT tokens

### 🚧 **Coming Soon**
- Microsoft Foundry Control Plane integration
- AI Evaluation pipeline at the gateway level
- Add support for A2A and agents publishing (integration with AI Gateway and AI Registry)
- Add guidance for Citadel Publish Contracts
- Defender & Purview enablement
- JWT only authentication support (without Gateway keys)
- Enhanced platform observability with custom dashboards and alerts (geared towards agents and MCP tools)

### 🔮 **Future Vision**

- Autonomous agent governance and orchestration through DevOps end-to-end approach

---

## 🤝 Contributing

We welcome contributions from the community! Whether it's:
- 🐛 Bug reports and fixes
- 📖 Documentation improvements
- 💡 Feature requests and enhancements

Please see our [Contributing Guide](./CONTRIBUTING.md) for details.

---

## 📞 Support & Community

- **🐛 Issues**: [GitHub Issues](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/issues)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Citadel Governance Hub** - Your organization's fortress in the new world of AI

*Providing protection, structure, and strength as you scale new heights with enterprise AI*

[🚀 Deploy Now](./guides/quick-deployment-guide.md) | [📚 Documentation](#-comprehensive-documentation) | [🤝 Contribute](#-contributing)

</div>
