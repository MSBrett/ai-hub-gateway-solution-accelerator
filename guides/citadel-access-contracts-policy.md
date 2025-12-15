# AI Citadel Access Contracts Policy

This guide to expand on what policies are available out of the box for use with the AI Citadel Access Contracts Bicep package, and how to customize them for each use case being onboarded.

## Available Policies Snippets

The following policy snippets can be applied as needed for the product policy access as part of the `Citadel Access Contracts`:

### Model Access Control Policy

```xml
<!-- Inboud Section of the Product Policy -->
<!-- Extract and validate model parameter from request -->
<include-fragment fragment-id="set-llm-requested-model" />
<!-- Restrict access for this product to specific models -->
<choose>
    <when condition="@{
        var allowedModels = new string[] { "gpt-4o", "deepseek-r1" };
        var requestedModel = (context.Variables.GetValueOrDefault<string>("requestedModel") ?? string.Empty).ToLowerInvariant();
        return !allowedModels.Any(m => m.ToLowerInvariant() == requestedModel);
    }">
        <return-response>
            <set-status code="401" reason="Unauthorized model access" />
        </return-response>
    </when>
</choose>
```
### Model Capacity Management Policy

The below policy snippet, enforces a token limit per subscription but for all models being access via this product.

```xml
<!-- Inboud Section of the Product Policy -->

<!-- Capacity management - Subscription Level: allow only assigned tpm for each HR use case subscription -->
<llm-token-limit counter-key="@(context.Subscription.Id)" 
    tokens-per-minute="300" 
    estimate-prompt-tokens="false" 
    tokens-consumed-header-name="consumed-tokens" 
    remaining-tokens-header-name="remaining-tokens" 
    token-quota="100000" 
    token-quota-period="Monthly" 
    retry-after-header-name="retry-after" />

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
<outbound>
    <base />
    <!-- Raising throttling events (http 429 only) can help in setting up alerts in App Insights -->
    <!-- Set the following variables to customize the throttling event details -->
    <set-variable name="productName" value="@(context.Product?.Name?.ToString() ?? "Portal-Admin")" />
    <set-variable name="deploymentName" value="@((string)context.Variables.GetValueOrDefault<string>("requestedModel", "DefaultModel"))" />
    <set-variable name="appId" value="@((string)context.Variables.GetValueOrDefault<string>("appId", context.Subscription?.Id ?? "Portal-Admin-Sub"))" />
    <include-fragment fragment-id="raise-throttling-events" />
</outbound>
```

Based on this policy, you can configure alerts in Application Insights to monitor for high throttling events and take necessary actions.

### Content Safety Policy

Content safety can be enforced at a gateway level using the built-in content safety policy. You can configure the content safety policy to block or flag content based on your organization's requirements.

```xml
<!-- Failure to pass content safety will result in 403 error -->
<llm-content-safety backend-id="content-safety-backend" shield-prompt="true">
    <!-- 0 is most restrictive and can be set up-to 7 -->
    <categories output-type="EightSeverityLevels">
        <category name="Hate" threshold="3" />
        <category name="Violence" threshold="3" />
    </categories>
</llm-content-safety>
```

### OAuth JWT Validation Policy

TBD

### PII Detection and Blocking Policy

TBD

### PII Redaction Policy

AI Citadel Gateway supports PII anonymization/deanonymization using built-in PII redaction policy fragments. You can configure the PII redaction policy to redact specific types of PII from the request or response.

#### `Inbound` PII Anonymization setup

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

#### `Outbound` PII Deanonymization setup

```xml
<outbound>
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