#!/bin/bash


name=`basename ${0%.sh}`

# echo "routine name: $name"

function USAGE() {
    echo "USAGE: $name port remote"
    echo "open a local port bound to a remote server"
    echo
    echo "OPTION:"
    echo "  -h, --help          help"
}

# parse options
ARGS=`getopt -o h --long help -n $0 -- "$@"`
if [ $? != 0 ]; then USAGE; exit -1; fi

eval set -- "$ARGS"
while :
do
    opt="$1"
    case "$1" in
        -h|--help) USAGE; exit;;
        --) shift; break;;
    esac
done

if(($# < 2)); then
    echo "too few arguments" >&2
    USAGE >&2
    exit 1
fi

host=localhost

port="$1"
remote="$2"

echo "local port: $port"
echo "remote server: $remote"

echo
if ! lsof -i:$port &>/dev/null; then
    echo "port $port closed"

    echo "begin to open it"
    # exit
    ssh -fN -D "$host:$port" "$remote" ||
    (echo "error: open port $port failed" >&2; exit 2;)
fi
echo "port $port open"