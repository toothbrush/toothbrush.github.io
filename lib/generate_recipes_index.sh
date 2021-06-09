#!/usr/bin/env bash
set -eu -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=lib/shared.sh
source "${SCRIPT_DIR}/shared.sh"

cat <<FRONT
---
title: List of Recipes
date: 2021-05-06
---

# Recipes

FRONT

# Wow okay so there's a whole thing about stable sorting.  I wrote
# this on my Linux box and didn't think twice, but on macOS, the
# recipes are sorted differently (even though i'm using `sort` from
# coreutils).
#
# Some references:
# https://unix.stackexchange.com/questions/362728/why-does-gnu-sort-sort-differently-on-my-osx-machine-and-linux-machine
# and https://blog.zhimingwang.org/macos-lc_collate-hunt.
#
# I hoped that a particular LC_COLLATE=.. setting would convince macOS
# to sort the same as Linux (because i prefer the output - İmam
# bayıldı by the "I"), but it appears there is no such luck.  Easiest
# was to implement my own in a real language.
#
# -- paul, 9/Jun/2021

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
    done | ./sort/sort
done
