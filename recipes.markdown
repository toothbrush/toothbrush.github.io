---
title: List of Recipes
permalink: /recipes/
layout: default
---

# Recipes

{% assign cats = site.recipes | map: "tags" | uniq | sort %}

Categories:

{%- for cat in cats %}
[{{ cat | capitalize }}](#{{ cat }})
{%- endfor -%}




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
