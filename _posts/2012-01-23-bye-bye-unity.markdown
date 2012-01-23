---
layout: post
title: Bye bye Unity
---

*tl;dr - If you're using Unity and Banshee you're unnecessarily
shorting your life.*

This weekend I made a significant improvement to my life by getting
rid of Unity. Here is my sad story.

When I was still studying (read: loads of time) I went down the road
that is Gentoo (read: recompile Evolution many times). There were some
things I absolutely loved about it. When things worked, they worked
damn well and my system has never been snappier. The same machine
running Windows (XP at the time) would take minutes to open Firefox,
while under Gentoo it would appear instantly, as if I had just
alt-tabbed to it. Things like `irb` just *appear*. Quite amazing.

On the golden path, things were very golden. However, Gentoo has a
darker side. *The* dark side, really. When things don't work, they
*really* don't work. Once you start pulling on that thread of
dependencies, you typically cannot stop until you've rebuilt your
entire system and its 3 days later. Once you've broken something, you
are almost certainly left without a working X - and that usually means
rebuilding your Kernel and `nvidia-drivers`.

At some point I just got over it and I sacrificed that snappiness for
Ubuntu. What a joy. Things *Just Worked (TM)*. It used to take me
hours to get a working Kernel, never mind actually getting
`nvidia-drivers` working (on the correct version) and configuring
X. And a working X didn't necessarily mean you had a mouse. So you fix
the mouse only to find.. you have no sound, or it's inverted. I didn't
believe Linux 'for human beings' was possible. But it was. The
installation process was quick (and really, really brainless) and
video, sound, mouse and keyboard and Firefox were all available within
an hour. Amazing.

Fast forward a few years to 11.10. I recently reinstalled my desktop
because of a broken hard-drive and the will to move to 64 bit. Oh, the
horror. Despite me having a completely standard video card (nVidia
8800GTX), the install disk gave a black screen and I had to fiddle
with grub to get to installation - only to have my first boot black
screen again. Then it was up to me and recovery mode to install the
drivers by typing at `apt` and then, again, fiddling grub
settings. Not the greatest technical challenge for a ex-Gentoo-er, but
definitely not for human beings.

I've had nothing but pain since. I had dual monitors, but the
experience is really not that great. Unity goes for the full screen
experience, but you cannot drag-and-drop between windows as the
launcher isn't clever enough to foreground the application whose icon
you are caressing. Eventually I decided to drop the second monitor in
favor of watching media in a more comfortable location (i.e. near a
couch). Guess what happened? Ubuntu/X decided (against
`nvidia-settings` will) that I had a mystery screen off to the *left*
- even though my second screen was to the *right*. This meant I could
not use the launcher any more as my mouse would vanish right through
it.

No worries, right? I tricked `nvidia-settings` into regenerating a
`xorg.conf` and rebooted my machine. It failed to
boot. Spectacularly. All I got was a cryptic message about 'checking
battery state' which I had to get to by hitting ESC to clear the boot
logo. I resorted to more `xorg.conf` Gentoo'isms and landed up getting
it working (i.e. booted with the correct config). A few hours later
the launcher crashed and I hit the end of my patience.

With 12.04 around the corner, I think I've given Unity a fair
chance. Up until that point I was prepared to give it a go. I defended
it (somewhat) and said 'just let it grow on you'. But no more. Its
laggy. Not unusably so, but just enough to be noticeable. They have
the drag-n-drop regression. Sometimes the launcher doesn't show,
sometimes it won't go away. File copy dialogs burn 100% CPU sometimes
(if I minimize them, `top` reports a *significant* drop in CPU util by
`compiz`).

My solution was to `apt-get install gnome-shell`, log out and log in
under the GNOME session. The difference is remarkable. Gnome Shell
gets out the way. It facilities instead of dictating. Its fast. There
are beautiful themes available because its built on well understood
technologies like Javascript and CSS. Everything Unity can do (read:
what I used it for), Gnome Shell does better and faster.

My absolute favorite feature so far is the slick application switching
via 'SUPER + initial'. For example, I typically have Chrome, at least
one terminal, Emacs, a file browser, music player and XChat open. When
doing Web development, you typically need to swap between at least
your browser, editor and terminal frequently. I like my window manager
to facilitate this - i.e. I want to go to Chrome, let me do it easily
please. Usually I've used the 'alt-tab flick' which is basically
remembering the 'index' that each application is in. For example, if
I'm in Emacs and want to go to Chrome, I think 'Chrome was the last
window I was in before Emacs - therefore a single alt-tab will
do'. I've been doing this for years and have become very good at it,
but sometimes I get it wrong and it usually results in a few seconds
of confusion. No more! Gnome Shell lets me type 'SUPER + e + RET' and
I'm in Emacs. That is, I press the Windows key, 'e' (for Emacs) and
then Enter. Even if Unity got this right, it would probably still be a
productivity hindrance because the launcher just takes so damn long to
show. Gnome Shell makes it feel like dancing. Slick.

After installing Gnome Shell, I grabbed the `user-theme` extension so
I could install custom themes. I haven't installed a theme for many
years, but there are just so many slick Shell themes out there I
decided to give it a go. I was so happy with the results, I landed up
installing a really slick icon pack too. While doing that, I bumped
into the observation that 'it has a really nice icon for
Clementine'. I found this an odd statement since I've never heard of
it before and I'm fairly familiar with the Gnome world. So I Google'd.

Wow. How did I miss this one?
[Clementine](http://www.clementine-player.org/) is the thing I've been
wanting ever since Amarok's rewrite was announced. If you're in the
dark, Amarok's 1.4 series was the best music player I've ever used. It
was so good, it made you want to play music just to use it. No music
player, ever, could compete with it - and if you disagree, you're
wrong. Until now, that is.

Amarok's rewrite (to the 2.x series) went something along the lines of
'Qt4 is out so let us rewrite everything'. The result is one of the
worst music players I've ever used. Its laggy, doesn't play MP3's by
default, doesn't handle a sizable collection and doesn't even make
browsing a small one easy. Clementine, on the other hand, is what
Amarok 2.x should have been: 'Qt4 is out so lets make Amarok work with
Qt4'.

I used Clementine for about 30s before I was convinced. It handles my
collection. It's fast. Browsing is intuitive. It supports CUE
files. And MP3s. It fetches lyrics. It makes me want to play music
again. I even installed it on Windows (albeit, not too optimistically)
just so I didn't have to be away from it ever. That worked too. Fast.

A couple of days ago my Ubuntu experience was fast heading for the
toilet. I was about to give up. Alt-tabbing itself had become a
pain. Banshee/Rhythmbox all suck. I was strongly considering forking
out for a Mac. My new software choices have restored my faith in the
Linux desktop experience and free software in general. Finally I have
found a setup that is both fast, beautiful and stable. Yay!
