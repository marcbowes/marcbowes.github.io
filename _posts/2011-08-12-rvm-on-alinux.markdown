---
layout: post
title: Installing RVM on aLinux
---

Everytime I touch a new server I land up installing RVM. With different distributions come different annoyances. This is the list of things you need to do to get RVM and Ruby 1.9(.3) running on an Amazon Linux AMI. I used amzn-ami-2011.02.1.x86_64-ebs (ami-8e1fece7).

{% highlight bash %}
sudo -s
yum install -y git gcc-c++ autoconf automake make patch
yum install -y bzip2 readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel iconv-devel
bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
gpasswd -a ec2-user rvm
source /etc/profile.d/rvm.sh
yum install -y bison
rvm install 1.9.3-head
{% endhighlight %}

.. and here we go!

{% highlight bash %}
rvm use 1.9.3-head --default
Using /usr/local/rvm/gems/ruby-1.9.3-head
ruby -e exit && echo happy
{% endhighlight %}

I got the following error during the Ruby install:

{% highlight bash %}
Fetching yaml-0.1.4.tar.gz to /usr/local/rvm/archives
/usr/local/rvm/scripts/md5: line 16: command_exists: command not found
/usr/local/rvm/scripts/md5: line 19: command_exists: command not found
{% endhighlight %}

I didn't dig into this far. The script uses `command_exists` to determine whether to run `md5` or `md5sum`. The error is that `command_exists` can't be found. I don't know what provides this and don't really care. If you get this error and are concerned about the md5 of the downloaded archive, then either dig in or just run the checksum yourself. I'm guessing its just a broken script as it differs to the one installed on my localhost and is thus a recent addition.
