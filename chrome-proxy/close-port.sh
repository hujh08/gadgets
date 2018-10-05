#!/bin/bash

name=`basename ${0%.sh}`

# echo "routine name: $name"

function USAGE() {
    echo "USAGE: $name port"
    echo "close a local port"
    echo
    echo "OPTION:"
    echo "  -h, --help          help"
    echo "  -m, --maxloop       maxloop to kill routines"
}

# default set
maxloop=100    # kill a routine listening the port per loop

# parse options
ARGS=`getopt -o hm: --long help,maxloop: -n $0 -- "$@"`
if [ $? != 0 ]; then USAGE; exit -1; fi

eval set -- "$ARGS"
while :
do
    opt="$1"
    case "$1" in
        -h|--help) USAGE; exit;;
        -m|--maxloop) maxloop=$2; shift 2;;
        --) shift; break;;
    esac
done

port=$1
if [ x"$port" == x ]; then
    echo "must specify local port" >&2
    USAGE >&2
    exit 1
fi

n=0
while sudo lsof -i:"$port" &>/dev/null
do
    if((n==maxloop)); then
        echo "Error: maxloop $maxloop reached, close port $port failed" >&2
        exit 1
    fi
    echo "port $port open"

    name_pid=(`lsof -i:$port | awk 'NR==2{print $1, $2}'`)

    name=${name_pid[0]}
    pid=${name_pid[1]}

    echo "to kill $name, pid $pid"
    kill -9 $pid
    ((n++))
done

echo "port $port closed"