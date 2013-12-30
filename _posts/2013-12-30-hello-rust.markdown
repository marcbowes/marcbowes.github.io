---
layout: post
title: Hello rust
---

I'm going to give [Rust](http://www.rust-lang.org/) a chance. It has a
strong focus on boundaries and concurrency and is C compatible. That
pretty much sold me, although the other claims seem nice too :-).

Prior to writing this article, I've done some light reading of the
[rust tutorial](http://doc.rust-lang.org/doc/0.8/tutorial.html) and
the [Rust for Rubyists book](http://www.rustforrubyists.com/).

The reading I've done has strengthened my original gut feel that Rust
would be worthwhile to learn - but I can only read so much before I
feel the need to turn theory into practice. So here goes. A series of
short experiments designed to help me learn and understand Rust.

To get going, I did a `brew install rust` and `M-x package-install RET
rust-mode RET`.

    > which rust
    /usr/local/bin/rust
    
    > rust -v
    rust 0.8
    host: x86_64-apple-darwin
    
    > rust
    
    The rust tool is a convenience for managing rust source code.
    It acts as a shortcut for programs of the rust tool chain.
    
    Usage:	rust <command> [arguments]
    
    The commands are:
    
        build   compile rust source files
        run     build an executable, and run it
        test    build a test executable, and run it
        doc     generate documentation from doc comments
        pkg     download, build, install rust packages
        sketch  run a rust interpreter
        help    show detailed usage of a command
    
    Use "rust help <command>" for more information about a command.

I then opened up a emacs buffer and pasted in the hello world example
from the Rust home page:

{% highlight rust %}
fn main() {
    println("hello?");
}
{% endhighlight %}

Looking at the output of the `rust` command, I simply used `rust run`
and it worked:

    > rust run rust.rs
    warning: no debug symbols in executable (-arch x86_64)
    hello?

Sweet. Some notes:

1. `time` reports about 0.11s - slower than `ruby -e 'puts "hello"'`, which takes 0.06s
2. `warning: no debug symbols in executable (-arch x86_64)` - I should figure this out [1]
3. A `rust~` file was generated which is executable and I can run, under `time` it takes about 0.01s
4. A `rust~.dSYM` folder was generated with a bunch of stuff in that I should probably understand
5. The executable is roughly 12k and is only 800 bytes bigger than a C program using stdio.h and printf

[1] Probably related to [this issue](https://github.com/mozilla/rust/issues/3495).

After removing the tilde file and folder, I explored explicit compiling.

    > rust help build
    The build command is an alias for the rustc program.
    
    .. elided ..

Ok, so basically `rust build` is the same as `rustc`. I can get the
help with `rustc --help`. I notice there is a `--parse-only` option:

    > rustc --parse-only rust.rs
    rust.rs:2:12: 3:1 error: unterminated double quote string
    rust.rs:2     println("hello?);
    rust.rs:3 }
    libc++abi.dylib: terminating with uncaught exception of type unsigned long
    [1]    34949 abort      rustc --parse-only rust.rs

This is pretty similar to `ruby -c`. Combined with `flymake` in Emacs,
I've had a lot of joy. I'm pretty keen to get that working for Rust
too. On to compiling and running:

    > time rustc rust.rs
    warning: no debug symbols in executable (-arch x86_64)
    rustc rust.rs  0.12s user 0.07s system 98% cpu 0.184 total
    
    > time ./rust
    hello?
    ./rust  0.00s user 0.00s system 87% cpu 0.010 total

I thought it a bit odd that the compilation took longer than with the
`rust run` and that the execution was faster. So I ran each a few
times, and it turned out to just be a fluke :-).

Having gotten this working, I wanted to spend a little time investing
in seeing what support Emacs has for Rust, beyond just syntax
highlighting. One of the mistakes I've made in the past is to ignore
this step until later. Having everything in one place (e.g. no alt-tab
to run your tests/compile) really helps (me, at least) with focus.

[The Rust wiki](https://github.com/mozilla/rust/wiki/Doc-Emacs-Support)
talks about installing and configuring `rust-mode`. Joyfully, it
mentions syntax checking using
[flycheck](http://www.emacswiki.org/emacs/Flycheck), which I wasn't
familiar with. It claims to be "flymake done right" - I have no idea
what was wrong with flymake since it always worked well for me :-).

After installing flycheck with `package-install`, I swapped to my
`rust.rs` buffer and enabled the mode with `M-x flycheck-mode`. That
didn't work and I got no feedback on why. +1 for flymake so far. With
`M-x flycheck-select-checker RET rust RET` I got an error saying it
couldn't find the executable. Sounds like a path issue to me (under
OSX, Emacs isn't started via a shell). I fixed this with `M-x
customize-variable RET exec-path RET` and using the UI to add
`/usr/local/bin`. I then got a syntax error in my `rust.rs` buffer but
it wasn't obvious to me how to see what the error was. I don't know
what the real answer is here (I'll have to see what fits), but it
seems like `flycheck-list-errors` is a goodie.

At this point I have an editor with syntax highlighting, that can tell
me about syntax errors and I can compile and run a simple hello world
program. Next time, I think I want to take a look at getting a simple
object oriented program going (with tests).