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

4. Handed-ness:

   ```console
   # to pick up which /dev/tty. port, try putting your Arduino in flash, then ls -la /dev | grep usbmodem
   $ avrdude -p atmega32u4 -P /dev/tty.usbmodem<port> -c avr109 -U eeprom:w:quantum/split_common/eeprom-lefthand.eep
   $ avrdude -p atmega32u4 -P /dev/tty.usbmodem<port> -c avr109 -U eeprom:w:quantum/split_common/eeprom-righthand.eep
   ```

## 2025 update

Because our qmk repo is reliant on avrdude 7 and has not been updated for 8, we'll run into the below:

```
$ make lets_split/rev2:default:avrdude
QMK Firmware gh60-0.1
WARNING:
 Some git sub-modules are out of date or modified, please consider running:
 make git-submodule
 You can ignore this warning if you are not compiling any ChibiOS keyboards,
 or if you have modified the ChibiOS libraries yourself.

Making lets_split/rev2 with keymap default and target avrdude

avr-gcc (Homebrew AVR GCC 8.5.0_2) 8.5.0
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Size before:
   text	   data	    bss	    dec	    hex	filename
      0	  21006	      0	  21006	   520e	.build/lets_split_rev2_default.hex

Compiling: tmk_core/common/command.c                                                                [OK]
Linking: .build/lets_split_rev2_default.elf                                                         [OK]
Creating load file for flashing: .build/lets_split_rev2_default.hex                                 [OK]
Copying lets_split_rev2_default.hex to qmk_firmware folder                                          [OK]
Checking file size of lets_split_rev2_default.hex                                                   [OK]
 * The firmware size is fine - 21006/28672 (7666 bytes free)
Detecting USB port, reset your controller now.......
Device /dev/tty.usbmodem13301 has appeared; assuming it is the controller.
Waiting for /dev/tty.usbmodem13301 to become writable.
Warning: programmer wiring fails to specify prog_modes = PM_...; [/opt/homebrew/etc/avrdude.conf:354]
Warning: programmer arduino fails to specify prog_modes = PM_...; [/opt/homebrew/etc/avrdude.conf:361]
Warning: programmer xbee fails to specify prog_modes = PM_...; [/opt/homebrew/etc/avrdude.conf:368]
Error: unknown token [/opt/homebrew/etc/avrdude.conf:404]
Warning: programmer avrftdi fails to specify prog_modes = PM_...; [/opt/homebrew/etc/avrdude.conf:404]
Error: syntax error [/opt/homebrew/etc/avrdude.conf:404]
Error: unable to process system wide configuration file /opt/homebrew/etc/avrdude.conf
make[1]: *** [avrdude] Error 1
Make finished with errors
make: *** [lets_split/rev2:default:avrdude] Error 1
```

To fix this,

1. Setup avrdude 7:

   ```console
   $ git clone https://github.com/avrdudes/avrdude
   $ git switch --detach v7.3
   $ ./build.sh
   $ sudo cmake --build build_darwin --target install
   ```

2. Make sure that this `avrdude` is picked up ie. higher in PATH than brew's avrdude:

   ```
   $ which avrdude
   /opt/homebrew/bin/avrdude
   $ export PATH="/usr/local/bin:$PATH"
   $ which avrdude
   /usr/local/bin/avrdude
   ```

3. Flash again, this should work.
