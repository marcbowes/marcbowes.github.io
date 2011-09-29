---
layout: post
title: Do not use nested timeouts in Ruby
---

I've been meaning to post this for a while, so here goes:

*TL;DR* Avoid nested use of Ruby's `Timeout.timeout {}`.

Let's take a look at an example of why this is broken. Consider this:

{% highlight ruby %}
def make_request
  Timeout.timeout(3) do
    really_make_the_request()
  end
rescue Timeout::Error => e
  # :-(
end
{% endhighlight %}

This is, unfortunately broken for the case where
`really_make_the_request` itself can raise a timeout. Even if that
timeout is much larger. For example, if the request is made using
`Net::HTTP`, it has a default read timeout of 60s. This is how timeout
works:

{% highlight ruby %}
# From lib/timeout.rb

def timeout(sec, exception=Error)
  return yield if sec == nil or sec.zero?
  raise ThreadError, "timeout within critical session" if Thread.critical
  begin
    x = Thread.current
    y = Thread.start {
      sleep sec
      x.raise exception, "execution expired" if x.alive?
    }
    yield sec
    #    return true
  ensure
    y.kill if y and y.alive?
  end
end
{% endhighlight %}

Its dead simple: fire up a new thread which will sleep then wake up and
raise an error in original thread. An `ensure` block kills the
would-be-murderer. In the case where the block executes fast enough,
the would-be-murderer is killed before it can raise an exception.

Now, as to why the example code is broken. We have three threads
running. The first is the main thread, M. The next is the
will-murder-after-60s thread, T60. And finally, the
will-murder-after-3s thread, T3. Under normal circumstances, we expect
T3 to wake up first and raise an error in M. This causes T60 to be
killed. However, under load the following can happen:

* T3 and T60 both go to sleep
* M starts executing
* T3 oversleeps because it doesn't get scheduled back in in time
* If T3 oversleeps to the point where T60 also wants to wake up, all
  bets are off
* If T60 is scheduled in now, it will raise an error in M
* M will now leave the outer `timeout` block and progress to it's
  `rescue` clause. Because of the `rescue`, the `ensure` which would
  kill off T3 is not yet run.
* T3 is now scheduled in and raises another `Timeout::Error`.
* Your code now receives a `Timeout::Error` with a stack trace that
  suggests it came from within the `timeout` block and, to all
  appearances, your `rescue` has been ignored.

How to fix this? The best way is to avoid this situation entirely. In
my scenario, the easiest way is to expand out
`really_make_the_request` to the point where you can control the
timeout. For example, explicitly set the `http.read_timeout = 3`. This
can be annoying as a small amount of code (e.g. using helper
functions) gets bloated just because we need control over an instance
variable. When talking about `Net::HTTP`, this is often the case
(e.g. turning off SSL verification), so I often just bite the bullet
and go for the expanded code straight up. It usually pays off.

The other option is to rescue from `Timeout::Error` again. Ideally in
this case, you could have two different classes of error. For example,
in the outer block use `Timeout.timeout(3, MyTimeoutError)`. In the
`rescue` for that, you would having another `begin..rescue` clause
which would trap the edge case of a `Timeout::Error` being raised
under weird scheduling conditions. However, its way better to just
avoid this entirely!
