---
title: Ctrl/Alt/Opt shortcuts in IntelliJ Terminal
date: 2020-04-30 13:09:50 +0800
tags: intellij
licence: Copyright © 2020 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

## Problem

Opt/Alt- shortcut keys show up as symbols in the IntelliJ terminal (eg. <kbd>Opt</kbd>-<kbd>B</kbd> shows up as `∫`) , instead of performing the bash shortcut of moving to the previous word. ([Readline, to be precise](https://tiswww.case.edu/php/chet/readline/readline.html).)

## Solution

(Tested in WebStorm/IDEA)

Put the below somewhere, eg. `~/.bash_profile`. If you use bash-it, you can put it in, say, `.bash_it/custom/intellij-terminal.bash`.

```sh
if [ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]; then
  bind '"ƒ": forward-word' # M-f
  bind '"∫": backward-word' # M-b
  bind '"∂": kill-word' # M-d
  bind '"¥": yank-pop' # M-y
  bind '"≥": yank-last-arg' # M-.
  bind '"—": yank-last-arg' # M-_
  bind '"†": transpose-words' # M-t
  bind '"¨": upcase-word' # M-u
  bind '"¬": downcase-word' # M-l
  bind '"ç": capitalize-word' # M-c
  bind '"®": revert-line' # M-r
  bind '"`": tilde-expand' # M-~
  
  # numeric arguments don't work
  #bind '"¡": digit-argument' # M-1
  #bind '"™": digit-argument' # M-2
  #bind '"£": digit-argument' # M-3
fi
```

## Context

Digging through the IntelliJ configuration didn't reveal anything that could solve this, like how the Mac Terminal app or iTerm has an option (geddit?) to treat Option keys as Esc/Meta keys.

Looking at the environment via `export` revealed a clue (`TERMINAL_EMULATOR="JetBrains-JediTerm"`), and some googling led to the file `/Contents/plugins/terminal/jediterm-bash.in`, which seems to be how IntelliJ initializes the terminal. [You can view the contents online here.](https://github.com/JetBrains/intellij-community/blob/master/plugins/terminal/resources/jediterm-bash.in)

The above is just one approach after examining that init config; other approaches could be to define `JEDITERM_USER_RCFILE` and pointing it to a file with the above `bind` calls.

## Conclusion

Did it work for you? Did you do it differently? [Let me know here](https://github.com/rctay/rctay.github.io/issues), I'd love to hear from you!
