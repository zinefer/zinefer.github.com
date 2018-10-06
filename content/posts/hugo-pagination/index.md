+++
date = 2018-08-19T20:30:46-06:00
title = "Customized Hugo Pagination"
description = ""
categories = "Software"
tags = ["Go", "Web Development", "Hugo", "Portfolio"]
+++

For the past couple weeks I've been working on redoing this website with a static site builder, [Hugo](//gohugo.io). I didn't find a theme that I liked so I've been working on building my own. I am pretty [far along](//github.com/zinefer/hugo-carbon).

Styling inspiration came from [CodyHouse](https://codyhouse.co/demo/pagination/index.html). I also used [Glenn's](https://glennmccomb.com/articles/how-to-build-custom-hugo-pagination/) article about his version of advanced pagination as a resource.

The default hugo pagination just wasn't working for me. There's a bunch of repeated functionality here.

<center>
  {{< image "default.png" />}}
</center>

And the gap insertion leaves a lot to be desired ...

<center>
  {{< image "default-page5.png" />}}
  <br/>
  {{< image "default-page6.png" />}}
</center>

Here's what I like in a pagination system:

- First and last buttons should just be 1 and LAST PAGE
- No duplicated buttons, aside from next/previous for fast clicking
- Don't show unusable buttons
- 1 adjacent link to either side of current page
- Display a gap only if the gap is 2 or larger, otherwise we might as well show the actual number

After a lot of headbanging (This was my first venture into GoHTML) here's what I came up with:

<center>
  {{< image "advanced.png" />}}
  <br/>
  {{< image "advanced-page4.png" />}}
  <br/>
  {{< image "advanced-page5.png" />}}
</center>

Here's the GoHTML template:

```go-html-template
{{ $paginator := .Paginator }}

{{ $adjacent_links := 1 }}

{{ $lower_gap := add $adjacent_links 3 }}

{{ $upper_gap := sub $paginator.TotalPages (add $adjacent_links 2) }}

{{ $lower :=  (sub $paginator.PageNumber $adjacent_links) }}

{{ $upper :=  (add $paginator.PageNumber $adjacent_links) }}

{{ $min_links := (add (mul $adjacent_links 2) 3) }}

{{ if gt $paginator.TotalPages 1 }}
<div class="page-holder">
  <ul class="pagination">

    {{ if $paginator.HasPrev }}
    <li class="page-item prev">
      <a href="{{ $paginator.Prev.URL }}"><i>Prev</i></a>
    </li>
    {{ end }}

    {{ range $paginator.Pagers }}

      {{ if gt $paginator.TotalPages $min_links }}

        {{ $.Scratch.Set "page_number_flag" false }}

        {{ if eq .PageNumber 1 }}
          {{ $.Scratch.Set "page_number_flag" true }}
        {{ end }}

        {{ if eq .PageNumber 2 }}
          {{ if gt $paginator.PageNumber $lower_gap }}
            <li><span>...</span></li>
          {{ else if eq $paginator.PageNumber $lower_gap }}
            {{ $.Scratch.Set "page_number_flag" true }}
          {{ end }}
        {{ end }}

        {{ if and (ge .PageNumber $lower) (le .PageNumber $upper) }}
          {{ $.Scratch.Set "page_number_flag" true }}
        {{ end }}

        {{ if eq .PageNumber (sub $paginator.TotalPages 1) }}
          {{ if lt $paginator.PageNumber $upper_gap }}
            <li><span>...</span></li>
          {{ else if eq $paginator.PageNumber $upper_gap }}
            {{ $.Scratch.Set "page_number_flag" true }}
          {{ end }}
        {{ end }}

        {{ if eq .PageNumber $paginator.TotalPages }}
          {{ $.Scratch.Set "page_number_flag" true }}
        {{ end }}

      {{ else }}

        {{ $.Scratch.Set "page_number_flag" true }}

      {{ end }}

      <!-- Output page numbers. -->
      {{ if eq ($.Scratch.Get "page_number_flag") true }}
        <li class="page-item{{ if eq . $paginator }} active{{ end }}">
          <a href="{{ .URL }}">{{ .PageNumber }}</a>
        </li>
      {{ end }}

    {{ end }}

    {{ if $paginator.HasNext }}
    <li class="page-item next">
      <a href="{{ $paginator.Next.URL }}"><i>Next</i></a>
    </li>
    {{ end }}

  </ul>
</div>
{{ end }}
```
