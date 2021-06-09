#!/usr/bin/env bash
set -eu -o pipefail

if ((BASH_VERSINFO[0] < 5))
then
  echo "Sorry, you need at least bash-5.0 to run this script." >&2
  exit 1
fi

_title_case() {
    printf "%s" "$1" | sed 's/.*/\L&/; s/[a-z]*/\u&/g'
}

_get_field() {
    local field=$1
    local filename=$2
    grep -E "^${field}:" "${filename}" | head -n 5 | sed "s/^${field}: //"
}
