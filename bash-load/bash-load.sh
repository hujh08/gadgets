#!/bin/bash

### BEGIN BASH LOAD
function cat-script() {
    local mark_bgn mark_end

    # begin/end mark
    mark_bgn='### BEGIN BASH LOAD'
    mark_end='### END BASH LOAD'

    sed -n "/^${mark_bgn}$/,/^${mark_end}$/p" "$1"
}

function load() {
    local func="$1"
    local fname=${func}.sh
    echo "load $func"
    eval "$(cat $fname)"
    echo "load finished"
    echo
}
### END BASH LOAD

# self echo
cat-script "$0"
