+++
date = "2018-09-19T11:37:03-06:00"
title = "Hugo, SEO and Minification"
description = "A recent optimization for this website's google seo prompted a pull request to hugo"
categories = "Software"
tags = ["Go", "SEO", "Hugo", "Portfolio"]
+++

It's been a long time since I've had to worry about SEO so I first checked google and came across keithp's blog post about [hugo seo](https://keithpblog.org/post/hugo-website-seo/). With a few edits (hugo moves fast) I was able to use his partial and it worked well enough to get my descriptions updated on the google search index.

In early August Hugo released version `0.47` which added a handy `--minify` cli flag that minifies the final rendered output. It worked really well and nearly my entire site was stripped down to just a few (very) long lines -- except for the SEO template.

I solved this problem by reworking the seo partial to create a `Map` and output it as `json`.

```
{{- $title := .Site.Title }}
{{- if not .IsHome }}
  {{- $title = .Title }}
{{- end }}

{{- $author := dict "@type" "Person" "name" .Site.Params.Author }}

{{- $logo := dict "@type" "ImageObject" "url" .Site.Params.PublisherLogo "width" 60 "height" 60 }}
{{- $publisher := dict "@type" "Organization" "name" .Site.Params.Publisher "logo" $logo }}

{{- with or (index (.Resources.Match "thumb.*") 0) (index (.Resources.ByType "image") 0) }}
  {{- $image := .Permalink }}
{{- end }}

{{- $keywords := slice "Blog" }}
{{- if isset .Params "tags" }}
  {{- $keywords = union .Params.tags $keywords }}
{{- end }}

{{- $scratch := newScratch }}
{{- $scratch.SetInMap "seo" "@context" "http://schema.org" }}
{{- $scratch.SetInMap "seo" "@type"    "BlogPosting" }}
{{- $scratch.SetInMap "seo" "mainEntityOfPage" (dict "@type" "WebPage" "@id" .Site.BaseURL) }}
{{- $scratch.SetInMap "seo" "articleSection"   .Section }}

{{- $scratch.SetInMap "seo" "name"     $title }}
{{- $scratch.SetInMap "seo" "headline" $title }}

{{- $scratch.SetInMap "seo" "description" (.Description | default .Site.Params.Description) }}
{{- $scratch.SetInMap "seo" "inLanguage"  .Site.LanguageCode }}

{{- $scratch.SetInMap "seo" "author"  $author }}
{{- $scratch.SetInMap "seo" "creator" $author }}
{{- $scratch.SetInMap "seo" "accountablePerson" $author }}
{{- $scratch.SetInMap "seo" "copyrightHolder"   $author }}

{{- $scratch.SetInMap "seo" "datePublished" .Date }}
{{- $scratch.SetInMap "seo" "dateModified"  .Date }}
{{- $scratch.SetInMap "seo" "copyrightYear" (.Date.Format "2006") }}

{{- $scratch.SetInMap "seo" "publisher" $publisher }}

{{- with or (index (.Resources.Match "thumb.*") 0) (index (.Resources.ByType "image") 0) }}
  {{- $scratch.SetInMap "seo" "image" .Permalink }}
{{- end }}

{{- $scratch.SetInMap "seo" "url" .Permalink }}

{{- $scratch.SetInMap "seo" "wordCount" .WordCount }}
{{- $scratch.SetInMap "seo" "keywords"  $keywords }}

<script type="application/ld+json">{{ $scratch.Get "seo" | jsonify }}</script>
```

Which is a reasonable solution but in my [post](https://discourse.gohugo.io/t/minify-the-output-of-a-partial/14070/10) on hugo discourse, [@bep](https://github.com/bep) directed me toward [this regex](https://github.com/gohugoio/hugo/blob/37d6463479952f7dfba59d899eed38b41e223283/minifiers/minifiers.go#L76) that permits js sub-tags to be minified. This gave me the idea to alter this to allow `ld+json` tags to be minified as `json`.

I was able to make [a pull-request](https://github.com/gohugoio/hugo/pull/5178) into the Hugo repository: Make JSON minification more generic. Along the way I noticed that the `js` minifier regex was woefully untested so I revamped the `minifiers_test.go` to better test minification of different main and sub-types.
