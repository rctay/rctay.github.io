---
title: REST updating a resource
date: 2019-01-26 11:48:00 +0800
tags: architecture
licence: Copyright © 2019 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

# Approaches

- Expose a field, `filter`. Source: <https://cloud.google.com/apis/design/standard_methods#list>

  Real-word example: <https://cloud.google.com/spanner/docs/reference/rest/v1/projects.instances/list>

- RFC 7396, the JSON Merge Patch format

  <https://williamdurand.fr/2014/02/14/please-do-not-patch-like-an-idiot/>
