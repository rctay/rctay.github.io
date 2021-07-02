---
title: "Blazor: a first look"
date: 2021-06-08 15:31:31 +0800
tags: [".NET Core", "too long; didn't watch notes"]
licence: Copyright © 2021 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

This comes a little late (by one year), but here are some notes and timestamps in case it's useful.

<https://channel9.msdn.com/Events/dotnetConf/Focus-on-Blazor/Welcome-to-Blazor>

- 4:21 - What is Blazor? Lays out the case for Blazor - no need to break out into another JavaScript stack; you can build the entire webapp in the .NET stack
- 5:58 - Two modes:
  - Blazor Server (6:24): "keeps track of any changes that are made to the UI using a sophisticated diffing algorithm" - I get this, in other words like a React, but done on the server-side, cool!
  - Blazor WebAssembly (7:19): "run your components directly in the browser using a WebAssembly-based .NET runtime. In a Blazor WebAssembly app, your components are downloaded as normal .NET assemblies along with the runtime into the browser and executed directly in the browser. As UI events occur, they're handled directly by your components in the browser."
- 16:09 - `@inherits` and `@Body` remind me of "partials"/"blocks" inheritance seen in template engines.
- 35:39 - scaling considerations. "Available memory is the primary bottleneck" 1 vCPU 3.5GM memory can provide <200ms latency and 5000+ active concurrent clients (1 click/sec) 👍🏻
- 40:45 - future of Blazor - "Blazor PWA", "Blazor Hybrid" / "Blazor Native" - Native .NET renders to Electron / WebView, Works offline or online
