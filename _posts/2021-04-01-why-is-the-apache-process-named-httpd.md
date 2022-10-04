---
title: Why is the Apache process named httpd?
date: 2021-04-01T12:57:11+08:00
tags: [history, interestings]
licence: Copyright © 2021 Ray. <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Attribution 4.0 International License" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a>
---

As you may have discovered, the process name of the Apache server software isn't eponymous - `ps aux | grep -i [a]pache` won't show you anything[^ps-grep]. It is instead named `httpd`. Why?

[^ps-grep]: This Stackoverflow question illustrates the issue and gives the background to wrapping the first character of the process name you want to `grep` for: <https://stackoverflow.com/a/9375940>

# The 'http' in 'httpd'

Apache, or to be precise, the Apache HTTP Server, is a software that you can use to serve HTTP - so others can access a website that you had built, for example. It was one of the early projects that brought prominence to open-source, having served more than 100 million websites according to [its Wikipedia page][Apache Wikipedia]. It has lent its name to one of the few OSI-approved licenses, the [Apache Software License][List of OSI licenses], and the Apache Software Foundation hosts major open source projects like Hadoop and the Apache Commons Java library.

[Apache Wikipedia]: <https://en.wikipedia.org/wiki/Apache_HTTP_Server>
[List of OSI licenses]: <https://opensource.org/licenses/alphabetical>

Back in the 2000s, the [LAMP stack (Linux, Apache, MySQL, PHP)][LAMP] was all the rage - you could get everything for free and put something together and see it in front of your eyes by running it on your own computer. You could even do \*AMP, ie. run it without Linux, like on Windows, for example.

[LAMP]: https://en.wikipedia.org/wiki/LAMP_(software_bundle)

When it came to putting your site live on the web, there was a plethora of hosting providers that you could choose from that were reasonably priced - about $10/month. These were mostly cPanel-FTP-directory based solutions, where you'd fire up a FTP client, and transfer your HTML files to the directory that was assigned to you - boom, your site is now "live" on the web!

Here's what shared hosting plans looked like, circa 2009:

{% include figure.html name="shared-hosting-plans.jpg" caption="shared hosting plans, circa 2009" %}

Wanted some fancy `Rewrite` or password? No need to bug your not-the-friendliest-server-admins-that-be, just stick your Apache directives in a `.htaccess`! (I have learnt that nowadays this isn't such a good idea, apparently for performance and security reasons, per the Apache manual[^htaccess-manual].) Want some application code to process a form submission? Put it in your `cgi-bin` directory![^cgi-manual]

[^htaccess-manual]: <https://httpd.apache.org/docs/2.4/howto/htaccess.html#when>
[^cgi-manual]: What is CGI? <https://httpd.apache.org/docs/2.4/howto/cgi.html>

At that time, I was hearing about Ruby-on-Rails, and Django (written in Python). You could get them for free, too, but finding a cheap host was a problem - you either needed to get your hosting provider's server admin to edit their Apache config to configure mod_wsgi (fat chance), or go with what was then called "VPS" - a Virtual machine private server - which 1) usually costed more, and 2) was a bare-bones VM, so you'd have to install and configure everything yourself..

Here's what VPS plans looked like, circa 2009: {% include figure.html name="vps-hosting-plans.jpg" caption="VPS hosting plans, circa 2009" %} This provider used Xen hypervisors, cool, you can now install everything you want...but there goes your time, when you could instead be coding a new feature, because I do mean everything, even down to installing `iptables` so your http server can be visited from the web!



So this was a limiting factor to learning and using these frameworks. Then I heard about this host called Webfaction, which provided VPS-level control (like ssh access) at shared-host prices, and had most stuff set up so you didn't have to spend time installing/configuring everything. In fact - this was the motivation for me to learn and use Git, where I would let it figure out which HTML files changed, so that I didn't have to send every single file over FTP - to ensure your host had the latest files to serve "live", it would be the safest to send every single file, but that might be redundant if a file hadn't changed, and you'd have to wait for the progress bar in your FTP client as it negotiated the slow Internet connection.

Then came along AWS EC2/cloud, and as they say, the rest is history (and nginx came out, which is now the go-to for serving static files and everything else in between).

# The 'd' in 'httpd'

We already know, from above, the connection between Apache software and HTTP (it's a HTTP server), so no surprise on the `http` in the name. But what about the `d`?

The `d` suffix indicates this process is a *daemon*, a kind of process that runs in the background, instead of started from a terminal that takes in input/writes output. So we have `sshd`, which is the name of the process of the SSH daemon so you can ssh into your machine. We also have `crond`, which takes care of running cronjobs, which are commands you'd want scheduled, like 8am every Monday. [The Wikipedia page on daemons has more][daemon-wikipedia].

A fun exercise: try daemon-ising an application of your own! You could wrap it in a script and put it in init.d[^initd-example]. Oh wait, we should be using systemd instead of initd now...

[daemon-wikipedia]: https://en.wikipedia.org/wiki/Daemon_(computing)
[^initd-example]: An example of an init.d script: <https://tldp.org/HOWTO/HighQuality-Apps-HOWTO/boot.html#boot.script>

