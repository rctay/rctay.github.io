---
title: keyboards
date: 2020-07-11 15:23:06 +0800
tags: keyboards
licence: Copyright © 2020 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

# Flashing Dactyl firmware on Mac

1. Install qmk.

   ```console
   ○ → brew install qmk/qmk/qmk
   ```

2. If `avr-gcc` was installed key-only, set it on PATH.

   ```console
   ○ → export PATH="/usr/local/opt/avr-gcc@8/bin:$PATH"
   ```

3. Flash it.

   ```console
   ○ → make lets_split/rev2:default:avrdude 
   ```
