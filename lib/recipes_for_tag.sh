#!/usr/bin/env bash

# This script is intended to return a list of recipes which are tagged
# a given way.  It's not amazing, like veg might match vegetarian.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=lib/shared.sh
source "${SCRIPT_DIR}/shared.sh"

if [[ -z "$1" ]]; then
    echo "Please specify a tag to search for." >&2
    exit 3
fi

for recipe in recipes/*.md; do
    tags=$(_get_field tags "${recipe}")

    if [[ "$tags" =~ [^a-z]?"$1"[^a-z]? ]]; then
        echo "${recipe}"
    fi
done
