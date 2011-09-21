---
layout: post
title: DRY your 'bundle exec' tears
---

There are a number of ways of skinning this cat, but they all seem to
suck. RVM had this but
[they rolled it back](https://github.com/wayneeseguin/rvm/commit/e8c1b87e1da57ed9d58d15ba3763f2d19e5f8170). There
is a
[Rubygem which provides this](https://github.com/mpapis/rubygems-bundler)
but it's fairly invasive.

Turns out, the bash built-in `alias` is perfect for this. I landed up
knocking up a script in a few seconds which checks if there is a
Gemfile in the current directory. If so, run `bundle exec cmd`, else
just run `cmd`. Real simple. Real neat.

{% highlight bash %}
bundle_commands=( rake spec rspec cucumber cap watchr rails rackup )
 
function run_bundler_cmd () {
    if [ -r ./Gemfile ]; then
        bundle exec $@
    else
        $@
    fi
}
 
for cmd in $bundle_commands
do
    alias $cmd="run_bundler_cmd $cmd"
done
{% endhighlight %}

To use, stick in the bottom of your bash or zsh rc file and resource
it (`source ~/.zshrc`) or open a new terminal.

There is a
[similar post](http://twistedmind.com/bundle-exec-bash-shortcut) about
this, and my paste here is very similar to it (I renamed my variables
intentionally to be similar), except that I include `rake` in the
list, removed the `echo`s and changed the `-e` to `-r` (check
readability).

The reason I like this solution so much is it feels like it's doing
the closest to what I, as a human, do: if I'm using Bundler
(i.e. there is a Gemfile), then I want to run using Bundler.
