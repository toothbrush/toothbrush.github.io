---
title: List of Recipes
permalink: /recipes/
layout: default
---

# Recipes

{% assign grouped_recipes = site.recipes | sort: "title" | group_by: "tags" %}

{%- for group in grouped_recipes -%}

## {{ group.name }}

<ul>
    {% for recipe in group.items %}
  <li>
    <a href="{{ recipe.url | relative_url }}">{{ recipe.title | escape }}</a>. {{ recipe.tags }}
  </li>
    {% endfor %}
</ul>

{%- endfor -%}
