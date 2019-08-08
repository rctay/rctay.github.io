---
title: REST API conventions
date: 2019-01-24 09:41:23 +0800
tags: architecture
licence: Copyright © 2019 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

# When updating an existing resource, should we use POST or PUT?

PUT. Source: <https://cloud.google.com/apis/design/standard_methods>

# Should we use `john` as a parameter in the query string eg. `/teams/good-corp/member?id=john`, or part of the url path/route eg. `/teams/good-corp/member/`?

Context: I want to retrieve a resource `member` (named) with the id `john` that is nested under the resource `team` (named) with the id `good-corp`.

# Should we use `id` as a parameter in the query string eg. `/blabla?team=id`, or part of the url path/route eg. `/teams/id`?

Context: I want to retrieve a certain resource `team` (named) with the id `id`.

The latter. Source: <https://cloud.google.com/apis/design/resources#examples>
