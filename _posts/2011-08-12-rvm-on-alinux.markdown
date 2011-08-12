---
layout: default
title: Installing RVM on aLinux
---

Everytime I touch a new server I land up installing RVM. With different distributions come different annoyances. This is the list of things you need to do to get RVM and Ruby 1.9(.3) running on an Amazon Linux AMI. I used amzn-ami-2011.02.1.x86_64-ebs (ami-8e1fece7).

{% highlight bash %}
sudo -s
yum install -y git
yum install -y gcc-c++ autoconf automake make patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel
yum install -y bzip2

yum install -y iconv-devel
bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
source /etc/profile.d/rvm.sh
yum install -y bison
rvm install 1.9.3-head
{% endhighlight %}

