---
layout: post
title: Fixing rake:assets:precompile
---

Use Capistrano to deploy a Rails app you've just upgraded to Rails
3.1? Seeing something like this in `cap deploy`?

{% highlight bash %}
*** [err :: yourapp] undefined method `exitstatus' for nil:NilClass
*** [err :: yourapp] (in /home/www/yoursite/releases/20110909151030/app/assets/stylesheets/application.css)
{% endhighlight %}

The short of it is that you need to install Java. The [YUI
Compressor](http://developer.yahoo.com/yui/compressor)
shells out to Java. On Ubuntu you can [install Java like
this](https://help.ubuntu.com/community/Java):

{% highlight bash %}
sudo add-apt-repository "deb http://archive.canonical.com/ lucid partner"
sudo apt-get update
sudo apt-get install -y sun-java6-jre
{% endhighlight %}

You can stop reading now, or continue if you wish to find out how I
solved this..

Just like in my [previous post on upgrading to Rails
3.1](/2011/09/02/rails-3.1-assets.html), I had the brilliant idea to
'quickly' upgrade another app of mine to take advantage of the new
pipeline. I discovered two things: first my `Flash` notices [were
broken](http://stackoverflow.com/questions/6170063/flash-deletenotice-not-working-in-rails-3-1-rc). This
caused a cascading sequence of Javascript failures because I was
injecting the `flash[:notice]` directly into [Humane
JS](https://github.com/wavded/humane-js).

Once that was out of the way, I found that my assets weren't being
minified in production. Annoyingly, my `cap deploy` broke at some
point with a `undefined method 'exitstatus' for nil:NilClass`. Since
the deploy task for asset precompilation is provided by Capistrano (>=
2.8.0), I had to dig around to see what they were doing. To do this,
use `bundle open capistrano` (I `export BUNDLER_EDITOR=emacsclient`)
and browse to `lib/capistrano/recipes/deploy/assets.rb`. There I saw
that I could customize things. So, I did `set :rake, "rake --trace"`
in my `config/deploy.rb` and reran `cap deploy`. The stack trace
showed me the line that it failed on.

By reading the surrounding code, I saw that it shelled out (using
[POpen4](http://popen4.rubyforge.org/)) to a `java -jar ...`. Simply
typing `java` on the command line of my server showed me that I didn't
have it installed. Turns out I didn't even know that YUI compressor
needed it. And even if I did, I lose track of what is installed where
anyways.

So there you have it. Not only do you need a JS runtime for
minification (via
[therubyracer](https://github.com/cowboyd/therubyracer) in my case),
but you also need a full-blown JRE. Looks like we're half-way to
JRuby.
