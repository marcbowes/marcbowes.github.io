---
layout: post
title: The mysql2 gem and Bundler
---

One of my aLinux servers has a `mysql_config` which reports:

    $ mysql_config --libs
    -rdynamic -L/usr/lib64/mysql -lmysqlclient -lz -lcrypt -lnsl -lm -lssl -lcrypto

This is clearly a lie:

    $ rpm -ql mysql51-devel|grep mysql.h
    /usr/include/mysql51/mysql.h

And thus, I cannot install mysql2 via `bundle install`:

    $ bundle install --deployment --quiet --binstubs --shebang ruby-local-exec
    Unfortunately, a fatal error has occurred. Please report this error to the Bundler issue tracker at https://github.com/carlhuda/bundler/issues so that we can fix it. Thanks!
    /home/gheed/.rbenv/versions/1.9.3-p0/lib/ruby/1.9.1/rubygems/installer.rb:552:in `rescue in block in build_extensions': ERROR: Failed to build gem native extension. (Gem::Installer::ExtensionBuildError)
    
            /home/gheed/.rbenv/versions/1.9.3-p0/bin/ruby extconf.rb 
    checking for rb_thread_blocking_region()... yes
    checking for rb_wait_for_single_fd()... yes
    checking for mysql.h... no
    checking for mysql/mysql.h... no
    -----
    mysql.h is missing.  please check your installation of mysql and try again.
    -----

To fix this, I simply did:

    bundle config build.mysql2 --with-opt-include=/usr/include/mysql51 --with-opt-lib=/usr/lib64/mysql/

This writes out a file called `~/.bundle/config` which Bundler will then use to configure the mysql2 gem.