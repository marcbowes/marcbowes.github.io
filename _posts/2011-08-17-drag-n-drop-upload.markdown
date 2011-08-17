---
layout: post
title: Drag & Drop upload with Rails, Rack Raw Upload & File Uploader
---

The idea behind this post is to show you how to integrate the
following:

* [File Uploader](https://github.com/valums/file-uploader), "Multiple file upload plugin with progress-bar, drag-and-drop": demo
  [here](http://valums.com/files/2010/file-uploader/demo.htm)
* [Rack Raw Upload](https://github.com/newbamboo/rack-raw-upload]), "Rack middleware to handle raw file uploads"
* Rails

I'm going to assume you have a working upload form and show you how to
modify your Rails application to support the new feature. In my case,
I had a very simple form to upload documents and it got tiring when
there were lots to upload. I will assume that your model is called
`article` and that you are saving files by writing to `@article.file`.

You may also be interested in reading
[this post](http://pogodan.com/blog/2011/03/28/rails-html5-drag-drop-multi-file-upload).

## File Uploader

The first think you want to do is grab a copy of `file-uploader`. You
can do this however way you want. In my case, I added a submodule to
my app so that I could sync any future updates over with
ease. Example:

{% highlight bash %}
mkdir -p vendor/misc
git submodule add git://github.com/valums/file-uploader.git vendor/misc/file-uploader
cp vendor/misc/file-uploader/client/fileuploader.js public/javascripts

# Optional
cp vendor/misc/file-uploader/client/fileuploader.css public/stylesheets
cp vendor/misc/file-uploader/client/loading.gif public/images
{% endhighlight %}

At this point you'll want to fiddle with `fileuploader.css` and
correct the link to `loading.gif` (should be
`/images/loading.gif`). Or you can use your own.

## Rack Raw Upload

After adding `gem "rack-raw-upload"` to your `Gemfile` (and `bundle`),
you'll need to add and configure the middleware, like so:

{% highlight ruby %}
require 'rack/raw_upload'
config.middleware.use 'Rack::RawUpload', :paths => ['/articles']
{% endhighlight %}

At this point, restart your application and the middleware will
intercept `POST /articles`, which is what happens when you have a `<%=
form_for(@article) .. %>`, and the article is new.

## Rails

Assuming we have a very simple form which looks something like
(`app/views/articles/new.html.erb`):

{% highlight erb %}
<%= form_for(@article, :html => { :multipart => true }) do |f| %>
  <p><%= f.select :category, Article.categories %></p>
  
  <p><%= f.file_field :file %></p>
  <%= f.submit("Upload") %>
<% end %>
{% endhighlight %}

What we'll do is make this form support both "legacy" and "drag &
drop". The following simple change will do.

{% highlight erb %}
<%= form_for(@article, :html => { :multipart => true }) do |f| %>
  <p><%= f.select :category, Article.categories %></p>
  
  <h3>Legacy uploader</h3>
  <p><%= f.file_field :file %></p>
  <%= f.submit("Upload") %>
  <h3>Or drop files here</h3> 
  <div id="file-uploader"></div>
<% end %>
{% endhighlight %}

Very simple. All we've done is add an empty `div` with id
`file-uploader`, plus added headings so people can continue to use the
"legacy" method. This could be hidden with `noscript` if you so
desire.


Ensure you have a `yield :head` inside the `<head>` of your
layout. Now add the following to `app/views/articles/new.html.erb`:

{% highlight erb %}
<%= content_for :head do %>
  <%= javascript_include_tag "fileuploader" %>
  <%= javascript_include_tag "article_drag_drop" %>
  <%= stylesheet_link_tag "fileuploader" %>
<% end %>
{% endhighlight %}

Now we need to create `javascripts/article_drag_drop`. Note that my
implementation uses jQuery, but this is definitely not required and
`file-uploader` doesn't require it.

{% highlight javascript %}
$(function() {  
  var uploader = new qq.FileUploader({
    debug: false,
    
    /* Do not use the jQuery selector here */
    element: document.getElementById("file-uploader"),
    
    action: $("#new_article").attr("action"),
    
    allowedExtensions: ["txt"],
    
    /*
     * This uploads via browser memory. 1 MB example.
     */
    sizeLimit: 1048576,

    /* Set Article category on submit */
    onSubmit: function(id, fileName) {
      uploader.setParams({
        authenticity_token: $("input[name='authenticity_token']").attr("value"),
        article: {
          category: $("#article_category :selected").text(),
        }
      });
    },
    
  });

});
{% endhighlight %}

There are a couple of things to note here:

* Do not use jQuery to find `file-uploader`. Internally, `innerHTML=`
  is used and this method is not available if the element is returned
  by the jQuery selector. This will manifest as an error calling
  `element.getElementsByTagName` because `div#file-uploader` won't be
  populated with the various HTML bits that `innerHTML=` would have
  set.
  
* I've chosen to use the same `action` as the legacy form would have
  posted to. Feel free to just type "/articles" here.
  
* You can limit the extensions (".txt" here) and sizes. The way this
  upload works is to load things in the browser's memory. Protect your
  users from themselves.
  
* The `onSubmit` callback is used to decorate the request parameters
  at the time of submission.
  
    * In this case I use it to set the `authenticity_token` using the
   value stored in the hidden input in the form. If you don't do this,
   Rails will return a `401`, assuming you're doing any sort of
   authentication. If you're not, I hope you have some other thing
   stopping randoms putting files on your server.
   
    * I also set `category` to the value selected in the form. This will
   be passed through as `params[:article][:category]`, just as with
   the legacy form.
   
    * The `params` option adds the params to the URL. For example,
   `/articles?foo=bar`. Rails will merge the `GET`-like and `POST`
   params into the same hash. Unfortunately, `file-uploader` doesn't
   (at the time of writing) allow you to fiddle with the form it
   generates for the `POST`.

Finally, you'll need to tweak your controller a little bit. In
`app/views/controllers/articles_controller.rb`:

{% highlight ruby %}
  def create
    is_qq = params.has_key?(:qqfile)
    if is_qq
      params[:article][:file] = params.delete(:file)
    end

    # .. elided ..
    
    if @article.save
      if is_qq
        render :json => { "success" => true }
      else
        # as before, likely:
        # redirect_to(articles_path, :notice => "Article was successfully created.")
      end
    else
      if is_qq
        render :json => { "error" => @article.errors }
      else
        # as before, likely:
        # render :action => :new
      end
    end
  end
{% endhighlight %}

This should be fairly obvious. When the `POST` is made, a special
`qqfile` parameter is added to the query string. This parameter
contains the filename. What we want to do is make it behave like
legacy mode. Thus, we move `:file` into `params[:article]` if we're in
'qq-mode'. Similarly, after we create our article, we return some
json. Note that `file-uploader` will `eval` this. If it responds to
`success`, it will think all went well. Else it'll show that the
upload failed. You can enable debug (by setting `debug: true` in the
Javascript) to see the contents of your error. It may be useful to
return `@article.errors.inspect` in the case of an error to make it
easier to read in the console.
