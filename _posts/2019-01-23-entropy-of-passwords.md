---
title: Entropy of passwords
date: 2019-01-23 10:36:32 +0800
tags: security
licence: Copyright © 2019 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

# Term: number of entropy bits of a password

- a concept from information theory
- a password with 5 bits of strength == 5 bits chosen randomly via coin tosses
  - would need 2^5 number attempts to exhaust all possibilities
  - on average, an attacker will have to try half of all possibilities

Source: <https://en.wikipedia.org/wiki/Password_strength>

# Question: what is the recommended number of entropy bits?

- [RFC 4086 "Randomness Requirements for Security"](https://tools.ietf.org/html/rfc4086)

- Depends on threat model
  - 29 bits: only online attacks
  - 96 bits: important cryptographic keys
