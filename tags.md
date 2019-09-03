---
layout: page
title: Tags
---

{% comment %}
Source: https://stackoverflow.com/a/44696931
{% endcomment %}

{% capture counts_with_tags_string %}{% for tag in site.tags %}{{ tag[1] | size | prepend:"000000" | slice:-6,6 }}:{{ tag[0] }}{% unless forloop.last %},{% endunless %}{% endfor %}{% endcapture %}
{% assign counts_with_tags = counts_with_tags_string | split:"," | sort | reverse %}

{% for count_with_tag in counts_with_tags %}
  {% assign tag = count_with_tag | split:":" | last %}
  {% assign count = site.tags[tag] | size %}
  <h2 id="{{ tag | slugify }}">{{ tag }} ({{ count }} posts)</h2>
  <ul>
  {% for post in site.tags[tag] %}
    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
  </ul>
{% endfor %}
