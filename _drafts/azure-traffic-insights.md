---
title: "#2: Queries in Azure Kusto for insight into Azure API Management Traffic"
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

