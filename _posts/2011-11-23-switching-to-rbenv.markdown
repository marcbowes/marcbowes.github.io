---
layout: post
title: Switching to rbenv (for servers)
---

[RVM](http://beginrescueend.com/) is really great for developers. It
allows you to easily chop and change between versions of Ruby/Gems
with ease.

The way RVM works is essentially by fiddling with your shell. For
example, try `env|grep rvm` to see how long it's tendrils are. In my
experience, all of RVM's strengths for developers are also it's
weaknesses when applied to servers.

Almost every piece of software I run has monitoring on it. Even if
it's private use, it will, at the very least, use
[monit](http://mmonit.com/monit/). Suddenly things go from real simple
to real annoying.

Monit runs processes in a 'spartan' environment. In other words, if
the command used for `start` or `stop` doesn't work if you invoke it
under `env -i`, then monit will not be able to run your application.

You can solve this problem really easily by creating a wrapper script
which sets up the necessarily variables and bootstraps RVM. But it
feels like a hack to get a hack working (and make no mistake, RVM's
ease of use is achieved through hacks).

[Rbenv](https://github.com/sstephenson/rbenv) makes this a lot
simpler. All you need to do is modify your script's shebangs to use
`ruby-local-exec` which will fiddle your `$PATH` such that the correct
version of Ruby is used. This even detects `.rbenv-version` files
without you having to `cd` into the project directory (RVM achieves
this by fiddling with the `cd` builtin).

Another issue I have with RVM is that deployment becomes trickier. For
example, most scripts will use `require "rvm/capistrano"` for
so-called seamless integration. However, this can break if:

* the deployer doesn't have RVM but the server requires it
* the deployer and server have non-compatible versions of RVM

The latter case has bitten me quite hard where I had upgraded my
development environment's RVM but one of my servers was now
un-deployable. But I couldn't downgrade my development environment's
version because I had just installed RVM on another server (it gets
the latest version by default) which was not compatible with the
downgraded version. Ugh.

In the rbenv-world, this issue is completely sidestepped. All you have
to do is set up the `$PATH`. You can do this trivially in a
`.bash_profile` or in a Capistrano `deploy.rb`:

{% highlight ruby %}
# rbenv
set :default_environment, {
  "PATH" => "/home/#{user}/.rbenv/shims:/home/#{user}/.rbenv/bin:$PATH",
}
{% endhighlight %}

Making the switch to rbenv is really simple. First, you'll need to
uninstall RVM. You can do this with `rvmsudo rvm implode`. You really
do need the `rvmsudo`, else it will be partially uninstalled and you
may find some weird behavior. After that, just follow the dead-simple
installation instructions for rbenv (which links to
[ruby-build](https://github.com/sstephenson/ruby-build) - highly
recommended).

I plan on writing a follow up post which shows an example setup of a
Rails stack using rbenv, passenger and nginx - all contained in a
single user account. This is a pattern which I find works well for
me. It allows developers to do whatever they want (system Ruby, RVM,
rbenv or something else) while allowing flexibility on the server side
for cases where you may need to change the version of Ruby for
security or performance reasons.
