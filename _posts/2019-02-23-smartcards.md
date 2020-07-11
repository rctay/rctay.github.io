---
title: smartcards
date: 2019-02-03 18:52:41 +0800
tags: security
licence: Copyright © 2019 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

# Getting started with private keys on smartcards

I found these guides to be useful when I was getting started:

- <https://raymii.org/s/articles/Nitrokey_Start_Getting_started_guide.html>

  Targets the particular hardware I'm using, the Nitrokey Start.

- <https://www.gniibe.org/memo/software/gpg/keygen-25519.html>

  Ed25519 keys are relatively new. The console logs, coupled with the author's comments, made this very useful.

- <https://alexcabal.com/creating-the-perfect-gpg-keypair>

  Covers the lifecycle of keys from generating, backing up, and revoking them (in the worst case scenario!).

- <https://shankarkulumani.com/2019/03/gpg.html>

  Useful usage examples for signing, encrypting, etc.

> Wondering about how long your password/passphrase should be? Read more about it on [entropy of passwords]({% post_url 2019-01-23-entropy-of-passwords %}).
{: class="highlight"}

# Using Smartcards for SSH Authentication

- For the first time on a new computer, first install gpg:

  ```console
  $ gpg --recv-keys C0023FA0
  $ mkdir $(gpgconf --list-dirs homedir)
  ```
  
  See the sections below for additional Mac and Windows steps to run, respectively.

- To start running ssh operations,

  ```console
  # start daemon
  $ gpg --card-edit
  # tell ssh to use gpg as the authentication agent
  $ export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  # check
  $ ssh-add -l
  256 SHA256:11112222aaaabbbb11112222aaaa4EF+qbZw/JZ5OYU cardno:FFFE12345566 (ED25519)
  ```

- If wonky,

  ```console
  $ gpgconf --kill gpg-agent
  $ gpg --card-edit
  ```

## Additional Setup on Mac

- Use pinentry, a nice UI for pin entry. Otherwise the curses[^curses] password entry
  unexpectedly waits for password in some other terminal (namely the one you
  started gpg-agent in...)

  ```console
  # add-on to list of packages to install
  $ brew install ... pinentry-mac
  # receive keys and mkdir...
  $ ...
  # tell gpg to use pinentry-mac
  $ printf "pinentry-program %s\n" "$(which pinentry-mac)" >> $(gpgconf --list-dirs homedir)/gpg-agent.conf
  ```

  [^curses]: <https://en.wikipedia.org/wiki/Curses_(programming_library)>

## Additional Setup on Windows

Assuming you're using PuTTY as your ssh client, we can leverage gpg's support for PuTTY.

- After installing, configure gpg to enable PuTTY support.

  ```console
  # receive keys and mkdir...
  $ ...
  $ echo enable-putty-support > $(gpgconf --list-dirs homedir)/gnupg/gpg-agent.conf
  ```

- Start gpg-agent daemon

  ```console
  $ gpg --card-edit
  ...
  > quit
  ```
- Accept host key in PuTTY

  ```console
  $ plink git@github.com
  ```
- tell git to use plink:

  ```console
  GIT_SSH_COMMAND=plink git clone git@github.com:...
  ```

## Side-by-side with Krypton

Krypton sets up `~/.ssh/config`. We need to tell `git` to use `ssh` without that config file, via `-F`.

```console
GIT_SSH_COMMAND='ssh -F /dev/null' git clone git@github.com:...
```
