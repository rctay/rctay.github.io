---
title: "#2: Analyzing Azure API Management-gated Functions traffic using Kusto"
tags:
- Azure
- Azure Functions
- API Management
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

Our initial architecture was for requests going direct to Azure Functions. However, we decided to transit to an architecture having requests going through Azure API Management (or APIM, for short) before reaching Azure Functions — that is, having Azure APIM act as an API gateway to Azure Functions. This would allow rate limiting and quote enforcement — functionality that Azure API Management offers out-of-the-box — without any change, code or otherwise, in our Azure Functions.

To make this transition, we rolled-out an update to client-side code, so that requests went through Azure APIM, but there were still "stragglers" that still hit Azure Functions. We wanted a picture of our traffic to Azure Functions - what proportion was still directly hitting Azure Functions, and what proportion was now going through Azure APIM?

## Application Insights/Azure Monitor Logs

To do so, we turned to Application Insights Logs. Application Insights is an extension of Azure Monitor, and the documentation for Azure Monitor Logs, [which you can find here][azure-logs-overview], is pertinent to Application Insights Logs too. You can access it from the Application Insights dashboard and click Logs under the Monitoring menu. When you start it, a dialog appears that contains example queries.

The queries are in the Kusto query language, which looks very much like LINQ from C#. Teaching the Kusto language is beyond the scope of this article; the Azure documentation has a [good get started page][azure-logs-get-started].

[azure-logs-overview]: https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-query-overview
[azure-logs-get-started]: https://learn.microsoft.com/en-us/azure/azure-monitor/logs/get-started-queries

## Iterating on a query

Looking through the example Kusto queries, we see a couple of "variables" — or tables, to be precise — that we can use in a query; it looks like `requests` is appropriate.

Further looking at the columns, it seems there are a couple of ways we can differentiate a request as coming from Azure APIM or from Azure Functions, such as `sdkVersion` (`apim:0.29.1641.0` vs. `azurefunctions: 3.10.2.0`). Here's a first-pass query:

```reasonml
requests
| summarize count() by sdkVersion, bin(timestamp, 1d)
```

However, the picture rendered in the chart wouldn't be accurate, as there is some "double-counting" among Azure Functionss requests; if we have `y` number of requests going to APIM, then when looking at `x` number of requests going to Azure Functions, potentially APIM would be responsible for some of them.

In other words, we shouldn't be running `summarize` or doing "slicing" among `requests`; we should be instead doing "slicing" within Azure Functions requests.

How do we do so? Looking at the columns, we observe something interesting for Azure Functions requests coming from APIM — they have a `operation_Id`, and a `operation_ParentId` which is different. This makes sense, as the Id in `operation_ParentId` is probably associated with the APIM request.

Here's what we arrived at:

```reasonml
let AzureFunctionApiInvocations =
    requests
    | where sdkVersion startswith "azurefunctions";
AzureFunctionApiInvocations
| extend source = iff(operation_Id == operation_ParentId, 'AzureFunction', 'AzureAPIM')
| summarize count() by source, bin(timestamp, 1d)
```

The 1st `let` allows us to narrow our focus to only Azure Functions requests. We then add a new column `source` via the `extend` keyword to slice the requests up on.

Here's what the traffic looked like initially:

{% include figure.html name="chart1.jpg" width="400" caption="Azure APIM vs Azure Functions traffic initially" %}

As expected, almost 50% of traffic went to APIM after the update got rolled out, but we never trended consistently below 20%. Here's what the traffic looked like in subsequent weeks, after sending out a push notification to further nudge updates:

{% include figure.html name="chart2.jpg" width="400" caption="Azure APIM vs Azure Functions traffic subsequently" %}

With direct traffic to Azure Functions now trending at low single-digits percents, we completed the transition and restricted Azure Functions to only serve requests from Azure APIM, allowing us to enforce rate limits and quota enforcement.

## Conclusion

Logs and the Kusto query language was flexible enough to allow iterating and performing domain-specific analysis, and makes a good addition to an engineer's toolbox.
