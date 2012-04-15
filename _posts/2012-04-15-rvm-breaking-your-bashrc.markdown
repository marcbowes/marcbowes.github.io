---
layout: post
title: RVM breaking your bashrc?
---

*tl;dr - If you update RVM only to have your shell settings tampered,
 try looking to see if RVM has created a `.bash_login` file that
 didn't exist before.*

Despite me using Rbenv almost exclusively now, there are one or two
machines lying around which still use RVM. On one such machine, I did
a `rvm get head --auto` which fixed some problems I was
having. Shortly afterwards, I opened a new session to said machine,
only to be greeted with a blank prompt. Huh?

Turns out, the RVM update landed up generating a `~/.bash_login`
file. The nasty thing here is that a login shell (i.e. when you `ssh`
in) will try load files in the following order:

* `~/.bash_profile`
* `~/.bash_login`
* `~/.profile`

Fact 1: I don't have a `.bash_profile`. Fact 2: `.profile` is the
thing that loads `.bashrc`. Now, because the `.bash_login` file was
created, it landed up killing the code path that ultimately loaded my
`.bashrc`. Oops.

Removing the file fixed the problem for me.
