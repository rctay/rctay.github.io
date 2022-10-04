---
title: "#2: Analyzing Azure API Management-gated Azure Function traffic using Kusto"
tags: react
licence: Copyright © 2022 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

<ul>
{% for entry in site.data.fifteen_days %}
  <li>
    {% if page.title != entry.name %}
    <a href="{{ entry.url }}">
      {{ entry.name }}
    </a>
    {% else %}
    {{ entry.name }}
    {% endif %}
  </li>
{% endfor %}
</ul>

Our initial architecture was for requests going direct to Azure Function App. However, we decided to transit to an architecture having requests going through Azure API Management (or APIM, for short) before reaching the Azure Function — that is, having Azure APIM act as an API gateway to the Azure Function. This would allow rate limiting and quote enforcement — functionality that Azure API Management offers out-of-the-box — without any change, code or otherwise, in our Azure Function.

To make this transition, we rolled-out an update to client-side code, so that requests went through Azure APIM, but there were still "stragglers" that still hit the Azure Function. We wanted a picture of our traffic to our Azure Function - what proportion was still directly hitting the Azure Function, and what proportion was now going through Azure APIM?

## Application Insights/Azure Monitor Logs

To do so, we turned to Application Insights Logs. Application Insights is an extension of Azure Monitor, and the documentation for Azure Monitor Logs is pertinent to Application Insights Logs too.



opens up several sample queries

looks very much like LINQ from C#.

some "variables" - tables, to be precise -


- [availabilityResults](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/availabilityResults)
- [browserTimings](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/browserTimings)
- [customEvents](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/customEvents)
- [customMetrics](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/customMetrics)
- [dependencies](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/dependencies)
- [exceptions](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/exceptions)
- [pageViews](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/pageViews)
- [performanceCounters](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/performanceCounters)
- [requests](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/requests)
- [traces](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/traces)

```kusto
let ApiInvocations =
    requests
    | where name != 'notifications';
let AzureFunctionApiInvocations =
    ApiInvocations
    | where sdkVersion startswith "azurefunctions";
AzureFunctionApiInvocations
| extend source = iff(operation_Id == operation_ParentId, 'AzureFunction', 'AzureAPIM')
| summarize count() by source, bin(timestamp, 1d)
```



Application Insights

Say you have a Azure Function App taking in traffic directly, and also taking traffic from an Azure API Management gateway.
