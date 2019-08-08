---
tags: git
licence: Copyright © 2019 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

# log formats

Choose one from below and set them with `git config --global format.pretty "..."`.

- `%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an, %cn%C(reset)%C(bold yellow)%d%C(reset)`

  Source: <https://stackoverflow.com/a/9074343>

  Modified to show committer name

- `%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an, %cn>%Creset`

  Source: glol from oh-my-zsh

  Modified to show committer name
