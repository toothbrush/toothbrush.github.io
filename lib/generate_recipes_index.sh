#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=lib/shared.sh
source "${SCRIPT_DIR}/shared.sh"

cat <<FRONT
---
title: List of Recipes
---

# Recipes

FRONT

for recipe in recipes/*.md; do
    filename=$(basename "${recipe}")
    title=$(_get_field title "${recipe}")
    url="/recipes/${filename%.md}.html"
    tags=$(_get_field tags "${recipe}")

    echo "* [${title}](${url}). ${tags}"
done | sort
