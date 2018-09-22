#!/bin/bash

# BEGIN
function load() {
    local func="$1"
    local fname=${func}.sh
    echo "load $func"
    eval "$(cat $fname)"
    echo "load finished"
    echo
}

# END

# self echo
sed -n '/^# BEGIN/,/^# END/p' "$0"