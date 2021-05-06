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

echo "Collecting recipe tags list..." >&2
readarray -t tags < <( "${SCRIPT_DIR}/tag_list.sh" )

for tag in "${tags[@]}"; do
    echo "Composing ${tag} section..." >&2
    echo
    echo "## $(_title_case "${tag}")"
    echo
    readarray -t matched < <( "${SCRIPT_DIR}/recipes_for_tag.sh" "${tag}" )

    for recipe in "${matched[@]}"; do
        filename=$(basename "${recipe}")
        title=$(_get_field title "${recipe}")
        url="/recipes/${filename%.md}.html"
        recipe_tags=$(_get_field tags "${recipe}")

        echo "* [${title}](${url}). ${recipe_tags}"
    done | sort
done
