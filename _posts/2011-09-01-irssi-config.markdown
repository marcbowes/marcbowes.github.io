---
layout: post
title: Simple irssi config to auto-connect to a SSL and password protected server
---

I love XChat. It's awesome. Once you've used the alternating colours
feature it's almost impossible to use any other client. However there
is one thing that has become an annoyance for me: GNU bindings. When
coding in Emacs or fiddling in bash it's just annoying when all the
handy shortcuts suddenly fail you when you tab into respond to a chat.

I have a very simple IRC setup. I run [znc](http://znc.sf.net) which
connects to the [ShadowFire](http://shadowfire.org) network. I use
this network because it's the fastest/stablest/coolest network in
South Africa. Znc buys me a couple of things, but the most important
is the ability to have a persistent connection. This means my chat
history is preserved regardless of the state of my IRC client. If I
reboot my desktop or connect a laptop/cellphone from some arbitrary
location, I can still see recent chat and continue to chat as the same
user. Anything else is insanity.

Znc runs on a server in my home. It listens on an random port using SSL
and connects to ShadowFire using SSL. Znc has a password setup which
is of the form user:password. As a first run, this is how to connect:

{% highlight bash %}
irssi
{% endhighlight %}

Then I type `/nick $USERNAME`, followed by `/server -ssl $IP_OF_ZNC
$PORT_OF_ZNC $USERNAME:$PASSWORD`. At this point you should be
connected. This worked great for me for about 3 weeks, connecting
maybe once per day. This morning I got annoyed having to do the
song-and-dance just to get a connection. What I wanted to be able to
do was: `irssi`. That's it.

Opening `~/.irssi/config` made this fairly obvious. I added the
following:

    # in 'servers'
    {
      address = "$IP_OF_ZNC";
      chatnet = "$SHADOWFIRE_OR_OTHER";
      port = "$PORT_OF_ZNC";
      autoconnect = true;
      use_ssl = "yes";
      password = "$USERNAME:$PASSWORD";
    }
    # ...
    # in 'chatnets'
    $SHADOWFIRE_OR_OTHER = { type = "IRC"; }

Now fire up `irssi` and you should be automatically connected. Some
useful shortcuts are `ALT+letter` to swap to a window (where `letter`
is 1 through 9, then it overflows to q through p), `/wc` to close the
current window. I recommend running irssi in it's own terminal so that
it doesn't conflict with the gnome-terminal tab switching. I also run
it in it's own workspace.
