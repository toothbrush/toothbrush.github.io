#!/usr/bin/env bash

_get_field() {
    local field=$1
    local filename=$2
    grep -E "^${field}:" "${filename}" | head -n 5 | sed "s/^${field}: //"
}

cat <<FRONT
---
title: List of Recipes
---

# Recipes

FRONT

for recipe in recipes/*.md; do
    filename=$(basename ${recipe})
    title=$(_get_field title "${recipe}")
    url="/recipes/${filename%.md}.html"
    tags=$(_get_field tags "${recipe}")

    echo "* [${title}](${url}). ${tags}"
done | sort
