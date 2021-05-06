#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=lib/shared.sh
source "${SCRIPT_DIR}/shared.sh"

tags=()
for recipe in recipes/*.md; do
    tag_field=$(_get_field tags "${recipe}")

    # Split by commas
    IFS=',' read -ra temp_tags <<< "${tag_field}"
    for tag in "${temp_tags[@]}"; do
        # Use awk to trim leading and trailing whitespace
        trimmed_tag=$(echo "$tag" | awk '{gsub(/^ +| +$/,"")} {print $0}')
        tags+=( "${trimmed_tag}" )
    done
done

# https://stackoverflow.com/questions/28512665/how-to-sort-and-get-unique-values-from-an-array-in-bash

printf "%s\n" "${tags[@]}" | sort -u
