---
layout: post
title: An annoying XBMC feature
---

Pressing the `\` key puts XBMC into 'windowed' mode. This manifests as
your XBMC shrinking into the top left corner using about 1/2 the
height and 1/3 of the width of your screen. Everything else is
black. Restarting doesn't fix it.

I sat on my keyboard remote yesterday and this happened to
me. Restarting doesn't restore it. It wasn't obvious to me whether
this was a X11 'feature' or an XBMC 'feature' and searching for
various things like 'xbmc quarter screen' or 'xbmc zoomed out' wasn't
helpful. I vaguely recalled having run into this before and that that
`\` key was involved but pressing it didn't help me.

I figured out by using the 'exit' menu of XBMC to get to the login
screen which was fullscreen. That narrowed it down to a XBMC
feature. The [XBMC keyboard
shortcuts](http://wiki.xbmc.org/index.php?title=Keyboard) page was my
next clue: I found that `\` was mapped to window mode. Ahah!

I then used the trackpad on my remote keybaord to move the mouse into
the XBMC window and then hit `\`. Tadaa.

This is a silly post but next time it happens to me hopefully it saves
somebody else 20 minutes.