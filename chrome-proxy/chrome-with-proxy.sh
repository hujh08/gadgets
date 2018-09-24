#!/bin/bash

name=`basename ${0%.sh}`

# echo "routine name: $name"

function USAGE() {
    echo "USAGE: $name [options] [user@host]"
    echo "OPTION:"
    echo "  -h, --help          help"
    echo "  -P, --port          local port"
    echo "  -t, --proxy-type    proxy type"
    echo "  -p, --only-print    only print configuration"
    echo "  -y, --auto-ssh      auto ssh bind"
    echo "  -o, --log-file      log file"
    echo "  -f, --config-file   config file"
}

function ECHO_CONFIG() {
    # echo "login as $(whoami)"
    echo "proxy scheme: $proxy"
    echo "local port: $port"
    echo "remote server: $remote" 

    echo "auto ssh: $autossh"

    if [ "$logf" ]; then echo "log file: $logf"; fi
    if [ "$conf" ]; then echo "config file: $conf"; fi
}

function READ_CONFIG() {
    # read config file
    local conf="$1"
    while read field val
    do
        case "$field" in
            port) port=$val;;
            proxy-type) proxy=$val;;
            only-print) onlyprint=$val;;
            log-file)  logf=$val;;
            auto-ssh) autossh=$val;;
            remote-server) remote=$val;;
        esac
    done < <(sed '/^#/d;/^$/d' "$conf")
}

function ARG_OVERWRITE() {
    local var="$1"
    local indent="$2"

    eval val_arg=\$${var}_arg
    if [ "$val_arg" ]; then
        echo "${indent}overwrite $var: $val_arg"
        eval $var="\"$val_arg\""
    fi
}

function LOG_FILE_SET() {
    # do some jobs for log-file
    local logf="$1"
    if [ -f "$logf" ]; then
        echo -n "logf: $logf exist. Remove it? yes/[no]: "
        read answer

        if [ -z "$answer" -o "$answer" == no -o "$answer" == n ]; then
            echo "append to existed logf: $logf"
        elif [ "$answer" == yes -o "$answer" == y ]; then
            echo "remove logf $logf"
            rm $logf
            touch $logf
        else
            echo "Error: unexpected input: $answer"
            exit 4
        fi
    fi

    logd="$(dirname "$logf")"
    if [ ! -d "$logd" ]; then
        echo "directory for log: $logd not exist" >&2
        exit 1
    fi

    REDIRECT_OUTERR $logf
    # add time stamp
    echo
    echo '==================================================='
    echo '=========' "$(date --rfc-2822)" '========='
    echo '==================================================='
}

function REDIRECT_OUTERR() {
    # redirect stdout stderr
    local logf="$1"

    exec 5>&1
    exec 6>&2
    exec &>>$logf
}

function RESTORE_OUTERR() {
    # restore stdout stderr
    exec 1>&5
    exec 2>&6

    exec 5>&-
    exec 6>&-
}

function RANDOM_PORT() {
    local minp maxp range rand
    minp="$1"
    maxp="$2"

    range=$((maxp-minp+1))

    rand=$((RANDOM % range))

    echo $((rand+minp))
}

# default setup

# range to generate a random port if not provided
minp=1200
maxp=5000

proxy=socks5
host=localhost
port=''
remote=''

autossh=no   # do not do ssh if local port is closed
onlyprint=no
logf=''
conf=''

# parse options
ARGS=$(getopt -o hP:t:ypo:f: \
              --long help,port:,proxy-type:,auto-ssh,only-print,log-file:,config-file: \
              -n $0 -- "$@")
if [ $? != 0 ]; then USAGE; exit -1; fi

eval set -- "$ARGS"
while :
do
    opt="$1"
    case "$1" in
        -h|--help) USAGE; exit;;
        -p|--only-print) onlyprint=yes; shift;;
        -f|--config-file)  conf=$2; shift 2;;
        -P|--port) port_arg=$2; shift 2;;
        -t|--proxy-type) proxy_arg=$2; shift 2;;
        -o|--log-file)  logf_arg=$2; shift 2;;
        -y|--auto-ssh) autossh_arg=yes; shift;;
        --) shift; break;;
    esac
done
remote_arg="$1"

if [ "$conf" ]; then
    echo "config file: $logf"
    if [ ! -f "$conf" ]; then
        echo "no configure file: $conf" >&2
        exit 1
    fi
    READ_CONFIG "$conf"
fi

# use specified arguments to overwrite
echo "overwrite setup with arguments:"
for var in port proxy remote logf autossh
do
    ARG_OVERWRITE $var '    '
done
echo

# set log file
if [ "$logf" ]; then
    echo "log file: $logf"
    LOG_FILE_SET "$logf"
fi

# if port not provided, generate one randomly
if [ -z "$port" ]; then
    echo -n "use a random port: "
    port=`RANDOM_PORT $minp $maxp`
    echo $port
fi

ECHO_CONFIG

if [ -z "$remote" ]; then
    echo "error: remote server unknown" >&2
    exit 3
fi

if [ "$onlyprint" == yes ]; then exit; fi

echo

# check local port bind
if ! lsof -i:$port &>/dev/null; then
    echo "port $port closed"

    if [ "$autossh" != yes ]; then
        if [ x"$logf" != x ]; then
            RESTORE_OUTERR
            echo "restore stderr/out"
        fi

        echo -n "Do you want to open it? yes/[no]: "
        read answer

        if [ "$logf" ]; then
            REDIRECT_OUTERR $logf
            echo -n "==>Do you want to open it? yes/[no]: "
            echo "$answer"
        fi

        if [ -z "$answer" -o "$answer" == no -o "$answer" == n ]
        then
            # echo "answer: [$answer]"
            echo "cannot open port $port"
            exit 1
        elif [ "$answer" != yes -a "$answer" != y ]; then
            echo "Error: unexpected input: $answer"
            exit 5
        fi
    fi

    echo "begin to open it"
    # exit
    ssh -fN -D $host:$port $remote ||
    (echo "error: open port $port failed" >&2; exit 2;)
fi
echo "port $port open"

# run chrome with proxy
echo
echo "google chrome run......"
google-chrome --proxy-server="${proxy}://${host}:${port}"
echo "google chrome end. port $port still open"
