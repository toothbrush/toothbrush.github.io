#!/usr/bin/env bash
set -eu -o pipefail

_title_case() {
    printf "%s" "$1" | sed 's/.*/\L&/; s/[a-z]*/\u&/g'
}

_get_field() {
    local field=$1
    local filename=$2
    grep -E "^${field}:" "${filename}" | head -n 5 | sed "s/^${field}: //"
}
