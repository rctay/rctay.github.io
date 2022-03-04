---
title: Reset terminal window title after
date: 2022-03-04 16:02:53 +08:00
tags:
 - MacOS
licence: Copyright © 2022 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

Problem: How to reset the terminal window title?

Situation: When using ssh, the terminal window title changes to user@hostname-of-box. But after quitting the ssh session, the title still remains the same.

Solution: Use this escape sequence:

```console
echo -ne "\033]0;\007"
```

[^200-GB-min]: <https://en.wikipedia.org/wiki/ANSI_escape_code#OSC_(Operating_System_Command)_sequences>

