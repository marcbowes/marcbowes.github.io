---
layout: post
title: Requires in your Ruby classes
---

I write classes like this:

{% highlight ruby %}
class Foo
  require "base64"
  # codez
end
{% endhighlight %}

The important bit I want to bring your attention to is that I put the
`require` statement inside the class. Some people don't care, some
people are opposed because its not Their Way and some people ask me
why.

Its very simple really. It's a form of encapsulation. Lets widen the
scope of this class a bit. What if I'm developing this for the first
time? Maybe I have the test in the same file:

{% highlight ruby %}
class Foo
  require "base64"
  # codez
end

require "rspec"

describe Foo do
end
{% endhighlight %}

When I later tease this file apart into `lib/foo.rb` and
`spec/lib/foo_spec.rb` my pattern makes it really hard for me to
forget to move the require statement along with the class. It also
makes it really obvious that I don't need to move the rspec require
with the describe block (if you squint, that's a class too).

The only time I don't do this is when I need a symbol to be defined to
actually create the class (i.e. inheritance):

{% highlight ruby %}
require "bar"

class Foo < Bar
  # codez
end
{% endhighlight %}

This is completely unavoidable if you want the property that every
file in your project should be individually requireable. For example,
if you want people to be able to `require 'some_project/foo'`
directly, you cannot rely on code in `lib/some_project.rb` to require
bar on behalf of it.

I also try to be very explicit about my dependencies. This means I
always require fileutils inside a Rails application, even though I
known that it's already being required by the framework. I do this
because it means that if I extract this code out into gem later on, I
won't have to go and retrofit it.

That brings me to Rails apps in general. If you're writing code that
is specific to your application (tightly coupled, makes no sense
outside the application) then put it in the `app/` folder and do not
require anything that Rails provides. If the code is not specific to
your application (for example, some code to handle authentication via
LDAP) then put it in `lib/` and only require Railsish libraries if you
think it makes sense outside a Rails application.

For example, consider these two concerns:

{% highlight ruby %}
module ProvidesBacon
  extend ActiveSupport::Concern
  
  included do
    helper_method :bacon
  end

  def bacon
    # codez
  end
end
{% highlight ruby %}

I do not think it makes sense to type `require 'active_support/concern'`
before the `extend`. The reason for this is that we're using
`helper_method` which is a strong indication this is intended to be
used by a Controller and therefore ActiveSupport will already be
available.

If, however, you were writing something for use by a controller but it
wasn't actually required to be used by a controller, then I think you
should be explicit about what it does require so that if you ever
decide to extract it (or even just test it in another suite for
speed reasons) your life will be so much easier.

Finally, be cautious about dependencies that are not symbols. For
example, if you're using `#blank?` in your concern, then you've likely
introduced an ActiveSupport dependency that isn't made obvious by
syntax highlighting.

I hope this helps anybody who is wondering how to calibrate their
require statements. Obviously doing Java-style imports isn't going to
work well, but nor should you get into the world ActiveSupport was a
few years back when it was really hard to only require certain classes
and not the whole framework.
