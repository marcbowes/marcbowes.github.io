---
layout: post
title: Saying hello to a bunch of people (in Rust)
---

In my [previous post](/2013/12/30/hello-rust.html), I used Rust 0.8 to
do a simple hello world program. Since then,
[0.9 has been released](https://mail.mozilla.org/pipermail/rust-dev/2014-January/007753.html)
which I've updated to. Note that the documentation is still somewhat
behind. Notably, the language support for the `@` pointer has been
removed - so do keep that in mind.

In this installment I want to write a simple, testable program which
prints "hello $name" for each name in a text file. This is what I
landed up with:

{% highlight rust %}
use std::io::buffered::BufferedReader;
use std::io::File;

fn extract_name(line: &amp;str) -> Option<&str> {
    if line.is_empty() {
        None
    } else {
        Some(line)
    }
}

fn main() {
    let path = Path::new("people.txt");
    let mut file = BufferedReader::new(File::open(&path));
    for line in file.lines() {
        match extract_name(line) {
            Some(name) => println!("hello {:s}", name),
            None       => println!("no name found")
        };
    }
}
{% endhighlight %}

Pretty straight-forward, right? I open up a file named `people.txt`,
iterate over each line and either greet the name on that line or print
out a warning saying there was no name on the line. The `lines()`
method returns an iterator which gives slices. A slice is a reference
to the part of the underlying string (i.e. no copy is
involved). Pretty cool.

I could totally have inlined the `is_empty()` check, but one of my
goals is testability. Since this is my second Rust app, I care more
about actually having a seperate function to write a test for than it
being the right extraction (I'll try fix this later!). Here is what I
wrote:

{% highlight rust %}
#[test]
fn extract_name_returns_some_for_non_empty_input() {
    assert!(extract_name(&"name").is_some());
}
{% endhighlight %}

Note that I use `&` before `"name"` because the function wants a
[reference](http://static.rust-lang.org/doc/master/guide-lifetimes.html)
so that I can make it compatible with the slice. This is pretty
awesome because I didn't have to do a heap allocation just to be
compatible with some existing API.

Time to run my test. First I need to build a test harness with `rustc --test hello-people.rs`. The earlier `#[test]` statement is the hook
that tells rust to only build this function if the testing config is
enabled. The `--test` argument tells the compiler to enable test and
to also build the harness to run the tests. However, it barfed:

<pre>
hello-people.rs:5:5: 9:6 error: mismatched types: expected `std::option::Option<&str>` but found `std::option::Option<&str>` (lifetime mismatch)
hello-people.rs:5     if line.is_empty() {
hello-people.rs:6         None
hello-people.rs:7     } else {
hello-people.rs:8         Some(line)
hello-people.rs:9     }
</pre>

That's a pretty weird error. Expected A but found A? In this case I
actually know what is going on because of the warning about
lifetime. Basically, the issue is that my function is returning a
wrapped reference and the compiler has no way of validating that the
[lifetime](http://static.rust-lang.org/doc/master/guide-lifetimes.html)
of the returned value will not result in access to freed memory. Said
another way: by the time somebody unwraps the `Option<&str>`, the
memory backing that reference might not be what I expect.

The way you fix this is by telling the compiler what the lifetime
is. This works similarly to generics, but you use apostrophes:

{% highlight rust %}
fn extract_name<'a>(line: &'a str) -> Option<&'a str> {
{% endhighlight %}

The first time `'a` is used is when I "define" the lifetime. (If you
don't do this, you'll get `use of undeclared lifetime name
&#x60;'a&#x60;`.) This should be familiar to you if you've used
generics. The next two are basically annotations on the lifetimes of
the argument and return time. The important thing is that my function
now explicitly states that the (wrapped) reference I am returning
cannot be used past the point at which the original reference would go
out of scope. Think about that for a moment: Rust has figured out that
the string slice can go out of scope. For example, I might collect all
the extracted names and say hello to them after closing the file. That
wouldn't compile unless I changed my function to return a copy of the
data. Awesome! If you've ever written code that segfaults, this should
make you happy.

Finally, with regard to the weird A-but-A style error, I got told
this by one of the friendly guys on `#rust`:

> it didn't used to tell you there was a lifetime mismatch :)
> the problem with adding lifetimes to the reported types is that more
> likely than not are inferred and implicit.

I think the point is that if they add the lifetimes everywhere, then
all error messages will be really intelligible. I guess this will
improve in the future.

<pre>
> rustc --test hello-people.rs -o test-hello-people && ./test-hello-people
hello-people.rs:17:1: 1:1 warning: code is never used: `main`, #[warn(dead_code)] on by default

running 1 test
test extract_name_returns_some_for_non_empty_input ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured
</pre>

I can kill the warning about main not being used if I add the
attribute `#[cfg(not(test))]` to it. That results in other
side-effects (e.g. the `BufferedReader` not being used) due to the
layout of the code at present. I could fix this by moving my
implementation into a mod.

Now I want to run the code.

<pre>
> rustc hello-people.rs && ./hello-people
task '<main>' failed at 'Unhandled condition: io_error: io::IoError{kind: FileNotFound, desc: "no such file or directory", detail: None}', /private/tmp/rust-X9vK/src/libstd/condition.rs:139
</pre>

That's both expected and unexpected. Why did Rust allow me to run into
a runtime failure that I didn't explicitly handle? I asked this on
`#rust` and got told:

> error handling in IO is an option question

Anyways, I added the file and ran again:

<pre>
> cat > people.txt
Andy
Bob

David
^D
> rustc hello-people.rs && ./hello-people
hello Andy

hello Bob

hello

hello David
</pre>

Now that I did not expect! Clearly the newlines are being included in
the slices that the iterator yields. Testing time!

{% highlight rust %}
#[test]
fn extract_name_returns_none_for_empty_input() {
    assert!(extract_name(&"").is_none());
    assert!(extract_name(&"\n").is_none());
}
{% endhighlight %}

<pre>
running 2 tests
task 'extract_name_returns_none_for_empty_input' failed at 'assertion failed: extract_name(&"\n").is_none()', hello-people.rs:20
test extract_name_returns_none_for_empty_input ... FAILED
</pre>

Gotcha. I fixed this with a call to `trim()` in the function and
everything worked:

<pre>
> rustc --test hello-people.rs -o test-hello-people && ./test-hello-people
hello-people.rs:24:1: 1:1 warning: code is never used: `main`, #[warn(dead_code)] on by default

running 2 tests
test extract_name_returns_none_for_empty_input ... ok
test extract_name_returns_some_for_non_empty_input ... ok

test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured

> rustc hello-people.rs && ./hello-people
hello Andy
hello Bob
no name found
hello David
</pre>
