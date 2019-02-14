+++
date = "2019-01-20T10:36:53-07:00"
title = "Threaded comments for Hugo with Staticman v3"
description = "A quick tutorial to add threaded Staticman comments to your hugo theme"
categories = "Software"
tags = ["Go", "Web Development", "Hugo", "Staticman", "Portfolio"]
+++

Adding comments to your Hugo site is simple and free thanks to [Staticman](https://staticman.net/). For simple comments there is a pretty detailed [guide](https://gohugohq.com/howto/staticman-hugo-comment-system/) and a [sample project](https://github.com/eduardoboucas/hugo-plus-staticman). For [threaded comments](https://networkhobo.com/2017/12/30/hugo-staticman-nested-replies-and-e-mail-notifications/#comment-form), Dan has a wonderful guide that I used pretty heavily.

Here I'm going to give a quick outline on how to add Staticman to your hugo project and implement threaded comments.

## Steps

- [Add Staticman to your repository](#add-staticman-to-your-repository)
- [Create Staticman configuration](#create-staticman-configuration)
- [Add Staticman configuration to site config](#add-staticman-config-to-site-config)
- [Create a comments form](#create-a-comments-form-partial)
- [Create some javascript to allow threaded or nested replies](#nested-reply-javascript)
- [Create a comments display partial](#create-a-comments-display-partial)
- [Create some comments manually for testing the display](#manually-creating-comments-for-testing)

## Add Staticman to your repository

Install the Staticman v3 app for your repository [here](https://github.com/apps/staticman-net).

## Create Staticman configuration

```yaml
# Name of the property. You can have multiple properties with completely
# different config blocks for different sections of your site.
# For example, you can have one property to handle comment submission and
# another one to handle posts.
comments:
  # (*) REQUIRED
  #
  # Names of the fields the form is allowed to submit. If a field that is
  # not here is part of the request, an error will be thrown.
  allowedFields: ["name", "email", "body", "reply_to"]

  # When allowedOrigins is defined, only requests sent from one of the domains
  # listed will be accepted.
  allowedOrigins: ["example.com"] # TODO: Add your domains

  # (*) REQUIRED
  #
  # Name of the branch being used. Must match the one sent in the URL of the
  # request.
  branch: "master"

  # Text to use as the commit message or pull request title. Accepts placeholders.
  commitMessage: "Add new comment in {options.section}/{options.slug}"

  # List of fields to be populated automatically by Staticman and included in
  # the data file. Keys are the name of the field. The value can be an object
  # with a `type` property, which configures the generated field, or any value
  # to be used directly (e.g. a string, number or array)
  generatedFields:
    date:
      type: date

  # The format of the generated data files. Accepted values are "json", "yaml"
  # or "frontmatter"
  format: "yaml"

  # Whether entries need to be appproved before they are published to the main
  # branch. If set to `true`, a pull request will be created for your approval.
  # Otherwise, entries will be published to the main branch automatically.
  moderation: true

  # Name of the site. Used in notification emails.
  name: "example.com" # TODO: Change this to match your site

  # (*) REQUIRED
  #
  # Destination path (directory) for the data files. Accepts placeholders.
  path: "data/comments/{options.section}/{options.slug}"

  # (*) REQUIRED
  #
  # Destination path (filename) for the data files. Accepts placeholders.
  filename: "comment-{@timestamp}"

  # Names of required files. If any of these isn't in the request or is empty,
  # an error will be thrown.
  requiredFields: ["name", "body"]

  # Notification settings. When enabled, users can choose to receive notifications
  # via email when someone adds a reply or a new comment. This requires an account
  # with Mailgun, which you can get for free at http://mailgun.com.
  #notifications:
    # Enable notifications
    #enabled: true

    # (!) ENCRYPTED
    #
    # Mailgun API key
    #apiKey: "1q2w3e4r"

    # (!) ENCRYPTED
    #
    # Mailgun domain (encrypted)
    #domain: "4r3e2w1q"

  # List of transformations to apply to any of the fields supplied. Keys are
  # the name of the field and values are possible transformation types.
  transforms:
    email: md5

  #reCaptcha:
    #enabled: true

    # reCaptcha site key
    #siteKey: ""

    # reCaptcha secret
    #secret: ""
```

## Add Staticman config to site config

```toml
[params.staticman]
  username = ""
  repository = ""
  branch = "master"
  notifications = false
```

 Add this if you plan to use reCaptcha
```toml
[params.staticman.recaptcha]
  siteKey = ""
  secret = ""
```

## Create a comments form partial

I created it at `layouts\partials\staticman\form-comments.html` but you'll likely need to tweak this for your theme.

```go-html-template
<div id="comment-submitted" class="dialog">
  <h3>Thank you</h3>
  <p>Your comment has been submitted and will be published once it has been approved.</p>
  {{ if (.Site.Params.githubPullURL) }}
    <p><a href="https://github.com/{{ .Site.Params.staticman.username }}/{{ .Site.Params.staticman.repository }}/pulls">Click here</a> to see the pull request you generated.</p>
  {{ end }}
</div>

<div id="comment-error" class="dialog">
  <h3>OOPS!</h3>
  <p>Your comment has not been submitted. Please <a href="{{ .Permalink }}">go back</a> and try again. Thank You!</p>
  <p>If this error persists, please open an issue by <a href="https://github.com/{{ .Site.Params.staticman.username }}/{{ .Site.Params.staticman.repository }}/issues"> clicking here</a>.</p>
</div>

<div id="comment-form">
  <h1 id="comment-form-header">Say something</h1>
  <form method="POST" action="https://dev.staticman.net/v3/entry/github/{{ .Site.Params.staticman.username }}/{{ .Site.Params.staticman.repository }}/{{ .Site.Params.staticman.branch }}/comments">
    <input type="hidden" name="options[redirect]" value="{{ .Permalink }}#comment-submitted">
    <input type="hidden" name="options[redirectError]" value="{{ .Permalink }}#comment-error">
    <input type="hidden" name="options[slug]" value="{{ .File.ContentBaseName  }}">
    <input type="hidden" name="options[section]" value="{{ .Section }}">
    <input type="hidden" name="options[origin]" value="{{ .Permalink }}">
    <input type="hidden" name="options[parent]" value="{{ .File.ContentBaseName }}">
    <input type="hidden" name="fields[reply_to]" value="">
    <input type="address" name="fields[botpot]" placeholder="botpot (do not fill!)" style="display:none">
    {{ if isset .Site.Params.staticman "recaptcha" }}
    <input type="hidden" name="options[reCaptcha][siteKey]" value="{{ .Site.Params.recaptcha.siteKey }}">
    <input type="hidden" name="options[reCaptcha][secret]" value="{{ .Site.Params.recaptcha.secret }}">
    {{ end }}

    <fieldset>
      <input name="fields[name]" type="text" placeholder="Your name">
    </fieldset>

    <fieldset>
      <input name="fields[email]" type="email" placeholder="Your email address">
    </fieldset>

    <fieldset>
      <textarea name="fields[body]" placeholder="You can use Markdown syntax" rows="10"></textarea>
    </fieldset>

    {{ if .Site.Params.staticman.notifications }}
    <fieldset>
      <div>
        <input type="checkbox" name="options[subscribe]" value="email">
        Send me an email when someone comments on this post.
      </div>
    </fieldset>
    {{ end }}

    <fieldset>
      {{ if isset .Site.Params.staticman "recaptcha" }}
      <div class="g-recaptcha" data-sitekey="{{ .Site.Params.recaptcha.siteKey }}" data-callback="enableBtn"></div>
      {{ end }}

      <input type="submit" value="Submit" id="submit-button" class="right">
      <input type="reset" value="Reset" class="right">
    </fieldset>

  </form>
</div>

{{ if isset .Site.Params.staticman "recaptcha" }}
<script async src='https://www.google.com/recaptcha/api.js' ></script>

<script type="text/javascript">
  document.getElementById("submit-button").disabled = true;
</script>

<script type="text/javascript">
  function enableBtn(){
    document.getElementById("submit-button").disabled = false;
  }
</script>
{{ end }}
```

# Nested reply Javascript

I added this to `static/js/main.js` but again, this will be theme dependant.

```js
function replyTo(parent, name) {
  var e = document.getElementById(parent),
      f = document.getElementById('comment-form'),
      h = document.getElementById('comment-form-header');

  h.innerHTML = 'Reply to ' + name;
  e.parentNode.insertBefore(f, e.nextSibling);
  document.getElementsByName('fields[reply_to]')[0].value=parent;
}
```

# Create a comments display partial

Like the comments form I put this at `layouts\partials\staticman\show-comments.html`.

```go-html-template
{{ if isset $.Site.Data.comments .Section }}
  {{ $comments := index $.Site.Data.comments (.Section) (.File.ContentBaseName) }}

  {{ if $comments }}
    <h1>Comments ({{ len $comments  }})</h1>
  {{ end }}

  {{ $hasComments := 0 }}
  {{ range $comments }}
    {{ $hasComments = add $hasComments 1 }}
    {{ if not .reply_to }}
      {{ $parentId := ._id }}
      {{ $parentName := .name }}
      {{ $hasReplies := 0 }}
      <div class="comment-header">
        <figure class="frame comment-avatar">
          <img src="https://www.gravatar.com/avatar/{{ .email }}?s=70">
        </figure>
        <p class="comment-info"><strong>{{ .name }}</strong><br><small>{{ dateFormat "Monday, Jan 2, 2006" .date }}</small></p>
      </div>

      {{ range $comments }}
        {{ if eq .reply_to $parentId }}
          {{ $hasReplies = add $hasReplies 1 }}
        {{ end }}
      {{ end }}

      <div id="{{ ._id }}" class="comment-thread">
        <blockquote class="comment">
          {{ .body | markdownify }}
        </blockquote>

        {{ if eq $hasReplies 0 }}
          <div class="comment-reply-button">
            <input id="{{ ._id }}" type="button" class="right" value="Reply to {{ .name }}" onclick="replyTo('{{ ._id }}', '{{ .name }}')" />
          </div>
        {{ end }}

        <div style="clear: both;"></div>

        {{ range $comments }}
          {{ if eq .reply_to $parentId }}
              <div class="comment-reply">
                <div class="comment-header">
                  <figure class="frame comment-avatar">
                    <img class="comment-avatar" src="https://www.gravatar.com/avatar/{{ .email }}?s=70">
                  </figure>
                  <p class="comment-info"><strong>{{ .name }}</strong><br><i><small>In reply to {{ $parentName }}</i><br>{{ dateFormat "Monday, Jan 2, 2006" .date }}</small></p>
                </div>
                <blockquote class="comment">
                  {{ .body | markdownify }}
                </blockquote>
              </div>
          {{ end }}
        {{ end }}

        {{ if gt $hasReplies 0 }}
          <div class="comment-reply-button-reply">
            <input type="button" class="right" value="Reply to Thread" onclick="replyTo('{{ ._id }}', '{{ .name }}')" />
          </div>
          <div style="clear: both;"></div>
        {{ end }}
      </div>

    {{ end }}
  {{ end }}
{{ end }}
```

# Manually creating comments for testing

With this setup Staticman will create a files for each comment in `data/comments/{slug}/comment-{@timestamp}`  with the following format:

```yml
_id: 39b6e5fb-ac32-46ca-a88c-f86286a18b77
_parent: threaded-hugo-comments-with-staticman
reply_to: ''
name: Alfred
email: 55502f40dc8b7c769880b10874abc9d0
body: "First comment\n# Hello moto\n\nHeyooo"
date: 2018-02-20T14:11:13.448Z
```

Key        | Description
---------- | ------------
`_id`      | a hash generated by Staticman
`_parent`  | the parent post slug
`reply_to` | blank, or the `_id` of the parent comment
`email`    | md5 hash of the email that was sent along with the comment and hashed by Staticman
`body`     | comment content
`date`     | comment date

Hugo wont actually care about the filenames so you don't need to worry about converting any timestamps, you can just name them something like `test{n}.yml`. You can generate some fake `_id`s with a [guid generator](https://www.guidgenerator.com/online-guid-generator.aspx).