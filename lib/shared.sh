#!/usr/bin/env bash

_get_field() {
    local field=$1
    local filename=$2
    grep -E "^${field}:" "${filename}" | head -n 5 | sed "s/^${field}: //"
}
