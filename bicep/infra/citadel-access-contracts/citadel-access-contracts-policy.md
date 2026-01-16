# AI Citadel Access Contracts Policy

This guide to expand on what policies are available out of the box for use with the AI Citadel Access Contracts Bicep package, and how to customize them for each use case being onboarded.

## Available Policies Snippets

The following policy snippets can be applied as needed for the product policy access as part of the `Citadel Access Contracts`:

### Model Access Control Policy

The model access control policy restricts which LLM models a product can access. This is implemented using the `validate-model-access` policy fragment.

**Basic Usage:**

```xml
<inbound>
    <!-- Extract and validate model parameter from request -->
    <include-fragment fragment-id="set-llm-requested-model" />

    <!-- Setting allowed models variable (comma-separated list) -->
    <set-variable name="allowedModels" value="gpt-4o,deepseek-r1" />
    
    <!-- Validate model access based on allowedModels -->
    <include-fragment fragment-id="validate-model-access" />
</inbound>
```

**How It Works:**

1. The `set-llm-requested-model` fragment extracts the model from the request:
   - From request body `{"model": "gpt-4o", ...}` for Universal LLM API
   - From URL path `/deployments/{deployment-id}/...` for Azure OpenAI API
   - Returns `"non-llm-request"` for GET operations (like listing available models)

2. The `validate-model-access` fragment validates the requested model:
   - **Non-LLM requests** (GET operations): Usually reference meta data endpoints that discover allowed models
   - **Empty `allowedModels`**: All models are allowed
   - **Model not in list**: Returns 401 Unauthorized with structured JSON error

**Error Response Format:**

When access is denied, the policy returns a structured JSON error:

```json
{
    "error": {
        "message": "Access to model 'gpt-4' is not allowed for this product.",
        "type": "access_error",
        "code": "unauthorized_model_access",
        "allowed_models": "gpt-4o,deepseek-r1"
    }
}
```

**Configuration Options:**

| Variable | Description | Example |
|----------|-------------|---------|
| `allowedModels` | Comma-separated list of allowed model names | `"gpt-4o,deepseek-r1,Phi-4"` |

>**NOTE:** Non-LLM requests (such as GET operations for listing available models) are automatically allowed and do not require model validation. This ensures auxiliary endpoints function without needing a model parameter.
### Model Capacity Management Policy

The below policy snippet, enforces a token limit per subscription but for all models being access via this product.

```xml
<inbound>
    <!-- Capacity management - Subscription Level: allow only assigned tpm for each HR use case subscription -->
    <llm-token-limit counter-key="@(context.Subscription.Id)" 
        tokens-per-minute="300" 
        estimate-prompt-tokens="false" 
        tokens-consumed-header-name="consumed-tokens" 
        remaining-tokens-header-name="remaining-tokens" 
        token-quota="100000" 
        token-quota-period="Monthly" 
        retry-after-header-name="retry-after" />
</inbound>
```

To further control capacity management per model per subscription, you can extend the above policy snippet to include model specific token limits by leveraging the `requestedModel` variable set via the `set-llm-requested-model` fragment.

```xml
<!-- Inboud Section of the Product Policy -->
<!-- Extract and validate model parameter from request and save it to requestedModel -->
<include-fragment fragment-id="set-llm-requested-model" />

<!-- Capacity management - Subscription + Model Level: allow only assigned tpm for each model per subscription -->
<choose>
    <when condition="@((string)context.Variables["requestedModel"] == "gpt-4o")">
        <llm-token-limit 
            counter-key="@(context.Subscription.Id + "-" + context.Variables["requestedModel"])" 
            tokens-per-minute="10000" 
            estimate-prompt-tokens="false" 
            tokens-consumed-header-name="consumed-tokens" 
            remaining-tokens-header-name="remaining-tokens" 
            token-quota="100000"
            token-quota-period="Monthly"
            retry-after-header-name="retry-after" />
    </when>
    <when condition="@((string)context.Variables["requestedModel"] == "DeepSeek-R1")">
        <llm-token-limit 
            counter-key="@(context.Subscription.Id + "-" + context.Variables["requestedModel"])" 
            tokens-per-minute="2000" 
            estimate-prompt-tokens="false" 
            tokens-consumed-header-name="consumed-tokens" 
            remaining-tokens-header-name="remaining-tokens" 
            token-quota="10000"
            token-quota-period="Weekly"
            retry-after-header-name="retry-after" />
    </when>
    <otherwise>
        <!-- Default model token limit for other models -->
        <llm-token-limit 
            counter-key="@(context.Subscription.Id + "-default")" 
            tokens-per-minute="1000" 
            estimate-prompt-tokens="false" 
            tokens-consumed-header-name="consumed-tokens" 
            remaining-tokens-header-name="remaining-tokens" 
            token-quota="5000"
            token-quota-period="Monthly"
            retry-after-header-name="retry-after" />
    </otherwise>
</choose>
```

### LLM Usage Customization Policy

By default, AI Citadel Gateway is configured to collect the following data points for LLM usage tracking:
- Standard Dimensions (currently can't be modified):
  - Region
  - Service ID
  - Service Name
  - Service Type
- Citadel Added Dimensions:
    - Product Name
    - DeploymentName (based on requestedModel variable)
    - Backend ID
    - appId (looks for variable named appId, fall back to subscription ID and then to "Portal-Admin" if not found)
- Custom dimensions:
    - customDimension1 (by default looks for a variable named customDimension1)
    - customDimension2 (by default looks for a variable named customDimension2)

Standard setup is already included in the default policies, but you can customize it further by setting up the following variables in the product policy inbound section:

```xml
<!-- Map appId from x-app-id header with safe defaults -->
<set-variable name="appId" value="@{
    var requestedAppId = context.Request.Headers.GetValueOrDefault("x-app-id", null);
    if (!string.IsNullOrEmpty(requestedAppId))
    {
        return requestedAppId;
    }
    return context.Subscription?.Id ?? "Portal-Admin";
}" />

<!-- Map customDimension1 from x-enduser-id header -->
<set-variable name="customDimension1" value="@(
    context.Request.Headers.GetValueOrDefault("x-sub-agent-id", "general-agent")
)" />

<!-- Map customDimension2 from x-usecase-id header -->
<set-variable name="customDimension2" value="@(
    context.Request.Headers.GetValueOrDefault("x-enduser-id", "anonymous-enduser")
)" />

```

>NOTE: The above policy fragment assumes that the client application is passing `x-app-id`, `x-sub-agent-id` and `x-enduser-id` headers in the request. You can modify the header names as per your requirements or use different approach to set these variables.

### Semantic Cache Policy

TBD

### Configuring Alerts Policy

Collecting throttling events can help in setting up alerts in Application Insights. You can configure the following variables in the product policy outbound section to customize the throttling event details:

```xml
<on-error>
    <base />
    <!-- Raising throttling events (http 429 only) can help in setting up alerts in App Insights -->
    <!-- Set the following variables to customize the throttling event details -->
    <set-variable name="productName" value="@(context.Product?.Name?.ToString() ?? "Portal-Admin")" />
    <set-variable name="deploymentName" value="@((string)context.Variables.GetValueOrDefault<string>("requestedModel", "DefaultModel"))" />
    <set-variable name="appId" value="@((string)context.Variables.GetValueOrDefault<string>("appId", context.Subscription?.Id ?? "Portal-Admin-Sub"))" />
    <include-fragment fragment-id="raise-throttling-events" />
</on-error>
```

Based on this policy, you can configure alerts in Application Insights to monitor for high throttling events and take necessary actions.

>NOTE: Detailed guide on how to setup throttling events handling can be found in [Throttling Events Handling Guide](./throttling-events-handling.md)


### Content Safety Policy

Content safety can be enforced at a gateway level using the built-in content safety policy. You can configure the content safety policy to block or flag content based on your organization's requirements.

```xml
<inbound>
    <!-- Content Safety Policy -->
    <!-- Failure to pass content safety will result in 403 error -->
    <llm-content-safety backend-id="content-safety-backend" shield-prompt="true">
        <!-- 0 is most restrictive and can be set up-to 7 -->
        <categories output-type="EightSeverityLevels">
            <category name="Hate" threshold="3" />
            <category name="Violence" threshold="3" />
        </categories>
    </llm-content-safety>
    <!-- End of Content Safety Policy -->
</inbound>
```

### OAuth JWT Validation Policy

TBD

### PII Detection and Blocking Policy

TBD

### PII Detection/Anonymization/Blocking Policy

AI Citadel Gateway supports PII various processing features using built-in PII handling policy fragments. 

- PII Detection
- PII Anonymization
- PII Blocking
- PII Deanonymization
- PII Logging (used only for testing and debugging purposes)

You can configure the PII handling policy to redact specific types of PII from the request or response.

#### PII Blocking setup

```xml
<inbound>
    <!-- PII Detection and Blocking -->
    <set-variable name="piiBlockingEnabled" value="true" />
    <!-- Variables required by pii-detection fragment -->
    <choose>
        <when condition="@(context.Variables.GetValueOrDefault<string>("piiBlockingEnabled") == "true")">
            
            <!-- Configure PII detection settings -->
            <set-variable name="piiConfidenceThreshold" value="0.75" />
            <set-variable name="piiEntityCategoryExclusions" value="PersonType,CADriversLicenseNumber" />
            <set-variable name="piiDetectionLanguage" value="en" /> <!-- Use 'auto' if context have multiple languages -->

            <!-- Configure regex patterns for custom PII detection -->
            <set-variable name="piiRegexPatterns" value="@{
                var patterns = new JArray {
                    new JObject {
                        ["pattern"] = @"\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b",
                        ["category"] = "CREDIT_CARD"
                    },
                    new JObject {
                        ["pattern"] = @"\b[A-Z]{2}\d{6}[A-Z]\b",
                        ["category"] = "PASSPORT_NUMBER"
                    },
                    new JObject {
                        ["pattern"] = @"\b\d{3}[-]?\d{4}[-]?\d{7}[-]?\d{1}\b",
                        ["category"] = "NATIONAL_ID"
                    }
                };
                return patterns.ToString();
            }" />
            <set-variable name="piiInputContent" value="@(context.Request.Body.As<string>(preserveContent: true))" />
            <!-- Include the PII detection fragment -->
            <include-fragment fragment-id="pii-detection" />
            <!-- Block request if PII is detected -->
            <choose>
                <when condition="@(context.Variables.GetValueOrDefault<bool>("piiDetected", false))">
                    <return-response>
                        <set-status code="400" reason="Bad Request" />
                        <set-header name="Content-Type" exists-action="override">
                            <value>application/json</value>
                        </set-header>
                        <set-body>@{
                            var detectedEntities = context.Variables.GetValueOrDefault<string>("piiDetectedEntities", "");
                            return new JObject(
                                new JProperty("error", new JObject(
                                    new JProperty("code", "PII_DETECTED"),
                                    new JProperty("message", "Request blocked: Personal Identifiable Information (PII) detected in the request."),
                                    new JProperty("detectedCategories", detectedEntities)
                                ))
                            ).ToString();
                        }</set-body>
                    </return-response>
                </when>
            </choose>
        </when>
    </choose>
    <!-- End of PII Detection and Blocking -->
</inbound>
```

#### PII Anonymization/Deanonymization setup

PII is detected and anonymized in the `Inbound` section, and deanonymized in the `Outbound` section.

##### `Inbound` PII Anonymization setup

```xml
<inbound>
    <!-- PII Detection and Anonymization -->
    <set-variable name="piiAnonymizationEnabled" value="true" />
    <!-- Variables required by pii-anonymization fragment -->
    <choose>
        <when condition="@(context.Variables.GetValueOrDefault<string>("piiAnonymizationEnabled") == "true")">
            
            <!-- Configure PII detection settings -->
            <set-variable name="piiConfidenceThreshold" value="0.75" />
            <set-variable name="piiEntityCategoryExclusions" value="PersonType,CADriversLicenseNumber" />
            <set-variable name="piiDetectionLanguage" value="en" /> <!-- Use 'auto' if context have multiple languages -->

            <!-- Configure regex patterns for custom PII detection -->
            <set-variable name="piiRegexPatterns" value="@{
                var patterns = new JArray {
                    new JObject {
                        ["pattern"] = @"\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b",
                        ["category"] = "CREDIT_CARD"
                    },
                    new JObject {
                        ["pattern"] = @"\b[A-Z]{2}\d{6}[A-Z]\b",
                        ["category"] = "PASSPORT_NUMBER"
                    },
                    new JObject {
                        ["pattern"] = @"\b\d{3}[-]?\d{4}[-]?\d{7}[-]?\d{1}\b",
                        ["category"] = "NATIONAL_ID"
                    }
                };
                return patterns.ToString();
            }" />
            <set-variable name="piiInputContent" value="@(context.Request.Body.As<string>(preserveContent: true))" />
            <!-- Include the PII anonymization fragment -->
            <include-fragment fragment-id="pii-anonymization" />
            <!-- Replace the request body with anonymized content -->
            <set-body>@(context.Variables.GetValueOrDefault<string>("piiAnonymizedContent"))</set-body>
        </when>
    </choose>
    <!-- End of PII Detection and Anonymization -->
</inbound>
```

##### `Outbound` PII Deanonymization setup

```xml
<outbound>
    <!-- PII Deanonymization -->
    <set-variable name="responseBodyContent" value="@(context.Response.Body.As<string>(preserveContent: true))" />
    <choose>
        <when condition="@(context.Variables.GetValueOrDefault<string>("piiAnonymizationEnabled") == "true" && 
                        context.Variables.ContainsKey("piiMappings"))">
            <!-- Use stored response body for deanonymization -->
            <set-variable name="piiDeanonymizeContentInput" value="@(context.Variables.GetValueOrDefault<string>("responseBodyContent"))" />
            <include-fragment fragment-id="pii-deanonymization" />
            <!-- Variables required by pii-state-saving fragment -->
            <set-variable name="piiStateSavingEnabled" value="true" />
            <set-variable name="originalRequest" value="@(context.Variables.GetValueOrDefault<string>("piiInputContent"))" />
            <set-variable name="originalResponse" value="@(context.Variables.GetValueOrDefault<string>("responseBodyContent"))" />
            
            <!-- Include the PII state saving fragment to push pii detection results to event hub -->
            <include-fragment fragment-id="pii-state-saving" />
            
            <!-- Replace response with deanonymized content -->
            <set-body>@(context.Variables.GetValueOrDefault<string>("piiDeanonymizedContentOutput"))</set-body>
        </when>
        <otherwise>
            <!-- Pass through original response using stored content -->
            <set-body>@(context.Variables.GetValueOrDefault<string>("responseBodyContent"))</set-body>
        </otherwise>
    </choose>
</outbound>
```

## Examples of Applying Policies

TBD

### HR PII Support Agent Access Contract Policy

TBD

### Retail Shopping Assistant Access Contract Policy

TBD

## Extending default policies

You can extend the out-of-the-box policies by leveraging APIM extensive policy expressions and capabilities.