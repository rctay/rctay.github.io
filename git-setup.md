---
title: Git setup
date: 2019-01-27 10:33:40 +0800
tags: git
licence: Copyright © 2019 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

# log formats

Choose one from below and set them with `git config --global format.pretty "..."`.

- `%C(bold blue)%h%C(reset) - %C(bold green)%ar%C(reset) %C(white)%s%C(reset) %C(dim white)- %an, %cn%C(reset)%C(bold yellow)%d%C(reset)`

  Source: <https://stackoverflow.com/a/9074343>

  Modified to show committer name

  - Since git 2.21.0, git supports a `human` pretty format for dates[^git-2.21.0-rel], so use `%ad` in place of `%ar`:

    `%C(bold blue)%h%C(reset) - %C(bold green)%ad%C(reset) %C(white)%s%C(reset) %C(dim white)- %an, %cn%C(reset)%C(bold yellow)%d%C(reset)`

    `%ad` respects a date format you pass in by `--date` - or the `log.date` format, so we set it:

    ```console
    $ git config --global log.date=auto:human
    ```

    More about `auto:` in the [release notes][git-2.21.0].


- `%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an, %cn>%Creset`

  Source: glol from oh-my-zsh

  Modified to show committer name

[^git-2.21.0-rel]: [Git 2.21.0 release notes][git-2.21.0-rel]
[git-2.21.0-rel]: https://github.com/git/git/blob/master/Documentation/RelNotes/2.21.0.txt#L78 "Git 2.21.0 release notes"
