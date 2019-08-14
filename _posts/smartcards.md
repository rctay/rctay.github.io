---
title: smartcards
date: 2019-02-03 18:52:41 +0800
tags: security
licence: Copyright © 2019 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

# setup
```console
brew install gpg pinentry-mac
echo pinentry-program /usr/local/bin/pinentry-mac >> ~/.gnupg/gpg-agent.conf
```

# usage
```console
# first run
$ eval $(gpg-agent --daemon --enable-ssh-support)
# subsequent run
$ unset GPG_AGENT_INFO SSH_AGENT_PID SSH_AUTH_SOCK
$ export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh
# check
$ ssh-add -l
# if wonky,
$ gpgconf --kill gpg-agent
# ...then run instructions in 'first run'
```

Adapted from: <https://www.bootc.net/archives/2013/06/09/my-perfect-gnupg-ssh-agent-setup/>
