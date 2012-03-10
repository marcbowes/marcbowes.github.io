---
layout: post
title: Using rbenv with emacs
---

*tl;dr - If you're using rbenv make sure to add the bin and shims to
your editors $PATH.*

Previously I wrote about [switching to
rbenv](2011/11/23/switching-to-rbenv.html). The gist of the post is
that RVM is a great tool for developers but relies heavily on your
shell. Thus, rbenv may be a better fit for your server environment.

I'm actually using rbenv on my home desktop now and that means it
needs to work with emacs. The most obvious break is flymake-mode which
essentially runs `ruby -c` on your behalf. The problem should be
obvious: the `ruby` I need emacs to run is not on the `$PATH`. So lets
add it:

{% highlight lisp %}
;; Setting rbenv path
(setenv "PATH" (concat (getenv "HOME") "/.rbenv/shims:" (getenv "HOME") "/.rbenv/bin:" (getenv "PATH")))
(setq exec-path (cons (concat (getenv "HOME") "/.rbenv/shims") (cons (concat (getenv "HOME") "/.rbenv/bin") exec-path)))
{% endhighlight %}

You can then use `M-x eval-region` to execute the code. Revert any
open buffers with `C-c r` to rerun hooks. Your trouble should go away!

Note that this fixes a lot of problems, including any gem binaries
that other modes require (e.g. compiling SASS comes to mind).

Happy emacsing!
