#!/usr/bin/env bash

cat <<FRONT
---
title: List of Recipes
---

# Recipes

FRONT

for recipe in recipes/*.md; do
    filename=$(basename ${recipe})
    title=$(grep -E "^title:" "${recipe}" | sed 's/^title: //')
    url="/recipes/${filename%.md}.html"
    tags="main, vegan"

    echo "* [${title}](${url}). ${tags}"
done | sort
