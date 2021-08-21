---
title: List of Recipes
permalink: /recipes/
layout: default
---

{% assign cats = site.recipes | map: "tags" | uniq | sort %}
{% comment %}
omigod, this was kinda hard
https://stackoverflow.com/questions/22763180/assign-an-array-literal-to-a-variable-in-liquid-template
{% endcomment %}

{% capture cat_links %}
{%- for cat in cats %}
[{{ cat | capitalize }}](#{{ cat }})
{%- endfor -%}
{% endcapture %}
{% assign cat_links = cat_links | strip | newline_to_br | strip_newlines | split: "<br />" %}

# Recipes

Categories: {{ cat_links | join: ", " }}

{% for cat in cats %}

## {{ cat | capitalize }}

{% assign cat_recipes = site.recipes | sort: "title" | where_exp: "recipe", "recipe.tags contains cat" %}

<ul>
{% for recipe in cat_recipes %}
  <li>
    <a href="{{ recipe.url | relative_url }}">{{ recipe.title | escape }}</a>. {{ recipe.tags }}
  </li>
{% endfor %}
</ul>

{%- endfor -%}
