#!/usr/bin/env bash

# This script will take a recipe filename and return the date,
# formatted in a nicer way.
set -eu -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=lib/shared.sh
source "${SCRIPT_DIR}/shared.sh"

if [[ -z "$1" ]]; then
    echo "Please specify a recipe to format the date." >&2
    exit 3
fi

recipe="$1"
date=$(_get_field date "${recipe}")

date --date="${date}" "+%d/%b/%Y"
