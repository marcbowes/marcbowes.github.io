---
layout: post
title: Be explicit before destructive
---

It is often desirable to write conscise, idiomatic code. Put another
way, many software developers frown on verbose, unidiomatic code.

Code is a form of expression, so its natural to seek beauty through
code. Practically, it's also pretty useful if you can get a team to
agree on a suite of 'beautiful idioms' - there is a lot to be said
about having a codebase that is consistent and conscise.

Many useful applications land up mutating state at some point. The
code path or descision to make that mutation is just code. So it
should follow the same idioms, right?

Here is a useful idiom from the Ruby programming language:

{% highlight ruby %}
# movie = { ..., "is_overdue" => true }

if movie["is_overdue"]
  do_something()
end
{% endhighlight %}

This works because the body of the `if` statement will execute if the
expression is "truthy". In Ruby, pretty much everything is truthy
(except `nil`, `false`). The above idiom is a _finesse_. There are
otherwise to keep this concise, but if we wanted to be _explicit_,
we'd write:

{% highlight ruby %}
if movie.has_key? "is_overdue" && movie["is_overdue"] == true
  do_something()
end
{% endhighlight %}

> In Ruby, `nil == true # => false`, so we could have elided the
> `has_key?` check. This is just another type of finesse and comes
> with the same risks I'm about to warn you of.

Most programmers I interact with think this idiom is a good one. I
think this too. The idiom is quick to stamp out, is fairly robust,
easy to unit test and easy to maintain.

So what is the catch? *It depends on what you're about to do:*

{% highlight ruby %}
if movie["is_overdue"]
  email_customer()
end
{% endhighlight %}

That's probably fine.

{% highlight ruby %}
if movie["is_overdue"]
  charge_customer()
end
{% endhighlight %}

That's probably not fine.

My primary concern with this sort of code is that it is about to take
a pretty dangerous action with very little safety. In my experience,
this sort of code is a bug waiting to happen.

What happens if we change the input slightly to use strings to
represent the overdueness of the movie:

{% highlight ruby %}
movie = { ..., "is_overdue" => "false" }
{% endhighlight %}

You've just charged your customer twice. The additional charge is
probably more than it would have cost you to type a few more
characters in the first place.

Worst, your unit tests probably would not have caught this because
your test data may not have reflected the change in input.

That's a school boy error though, surely? Why would you change your
input without checking the consequences and/or updating your tests?
Firstly, school boy errors do in fact happen. Or:

* You're getting your data from a database or file where the schema
  changes or the library you're using changes such that you get a
  string instead of boolean back.
* You're getting your data from a service (even internal) that
  introduced a regression in their API. This can be subtle,
  e.g. changing their marshalling layer.
* Some other part of your application is mutating the data in-place.
* Somebody introduced a layer between you and your data, e.g. a cache.
* etc.

The interesting (read: scary) thing about these possible changes is
that you can break even without going through a deployment where you
have a point to check the correctness of any changes. This means it
can be hard to know that something really bad has started happening,
or why it's happening.

A much better way of handling this case is to be much more explicit
about your data. For example, I would recommend the following cheap
change:

{% highlight ruby %}
if true == movie["is_overdue"]
{% endhighlight %}

The above expression can only be `true` or `false` and, unless
somebody has overridden `TrueClass.==`, you can be sure of all the
ways you could possibly charge your customer.

I would recommend taking the above a step further to protect against
this bug for future maintainers of your project who may not be in a
pedantic mood in 3 years time when they have to make some changes in
this part of the code. That is: document and test.

{% highlight ruby %}
if should_charge_customer? movie
 charge_customer()
end

# Callers of this method might be interested in charging customers. We
# should only do this exactly if the value behind `is_overdue` is set
# to `true`. Any other value, including the string `"true"` should not
# return `true`.
def should_charge_customer? movie
  true == movie["is_overdue"]
end

# test.rb

def test_should_charge_customer_false_for_nil
  assert_false should_charge_customer?({})
end

# etc
{% endhighlight %}

I would also recommend strongly considering moving away from a `Hash`
and add an actual model. The same advice would apply to the model:
only return true in exactly the only way(s) you think it should be
true. Don't rely on finesse, be explicit, document and test.

Another example of this sort of bug is some command line tool that has
a `--pretend` mode flag. This sort of tool is pretty common when
writing "safe" wrappers to do maintenance such as data migrations or
pruning.

{% highlight ruby %}
options.on "--pretend" do |v|
  @pretend_mode = true
end

# ...

unless @pretend_mode
  all_your_data_is_mine()
end
{% endhighlight %}

The above is an extremely good way to get me to freak out. Often, the
`pretend` flag is added as an after-thought; the authors have to
maintain some sort of compatibility with previous versions of the
tool. This would rule out a safer alternative such as
`--actually-do-it` which is more explicit. But even so, let's look at
what can go wrong:

* The user could have invoked with `--preted`. If your application
  doesn't choke on unknown args, you may do the wrong thing.
* The author could have typo'd `@preted_mode = true` such that the
  correct invokation still didn't set pretend mode correctly.
* The author could have typo'd `if @preted_mode` such that the
  correcet invokation and correct option handling still didn't stop us
  taking our destructive action.
* There could be another place in the code where a destructive action
  isn't wrapped in a check.
* Anybody could do any/all of the above on any future version of the
  tool.

A significantly better way of handling this issue could be:

{% highlight ruby %}
class Options < Struct.new :pretend_mode

  # I chose a scary method and hid the passive `pretend?` method so
  # that it is really clear what the caller is option into.
  def destructive
    yield unless pretend?
  end

  protected

  # `true` on the left-hand-side so that the `.==` call goes to a
  #  class who's behavior you can reason about.
  def pretend?
    true == pretend_mode
  end
end

def initialize
  @options = Options.new false
end

options.on "--pretend" do |v|
  @options.pretend_mode = true
end

# ...

options.destructive do
  all_your_data_is_mine()
end
{% endhighlight %}

This is better because many of the typo cases will now result in
`NoMethodError` and runtime failure instead of data loss. Assuming
you've also fixed the 'unknown args' issue, the only outstanding
problem is ensuring all destructive actions are protected. There are a
couple of ways of doing this. If you're prepared to do some
refactoring, I think this a pragmatic solution is to hide dependencies
so that they are only accessible behind destructive-checking barriers:

{% highlight ruby %}
def database
  destructive do
    @actual_db_conn
  end
end

database.truncate # fails if you're in --pretend mode
{% endhighlight %}

The above snippet is simplified for demonstrative purposes. If you
used that and didn't protect the call the `#truncate` behind it's own
descructive-check, you'd land up calling `@actual_db_conn` on
`NilClass` and your application would blow up. Again: this is better
than data loss.

To take this a step further, you could return a fake DB object:

{% highlight ruby %}
class FakeDb
  def method_missing name, *args
    $logger.warn "Attempt to improperly call database.#{name}(#{args.inspect})"
  end
end
{% endhighlight %}

Now you've replaced data loss with something you can alarm on.

> If you have a tool like the above example, consider changing the
> actual implementation of `truncate` to rather *move or tombstone*
> data rather than immediately delete it. At some point, you'll delete
> it (at least, from the original store), at which point you should
> follow my advice and be pedantic.

I'm a big fan of concise, beautiful, idiomatic code. Or even ugly,
verbose, unidiomatic code that is at least consistent with the code
around it. Whatever your preference, I would strongly encourage you to
take a zero tolerance stance when it comes to taking destructive
actions such as deleting data, mutating data or charging
customers. Code that does this should never accidentally trigger. It
should be explicitly, unambiguously told it should do so.
