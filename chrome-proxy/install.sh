#!/bin/bash

scripts=(chrome-with-proxy close-port open-port-to)

# just output scripts, and then exit
if [ x"$1" == x"-o" ]; then # only output
    echo "${scripts[@]}"
    exit
fi

function confirm_dir() {
    # confirm directory exists
    if [ ! -d "$1" ]; then
        echo "$1 not exist. will create it" 
        mkdir -p "$1"
        echo "$1 created"
    fi
}

if(($#<2)); then
    echo "usage: install.sh BINDIR CONDIR [APPDIR]"
    echo "Error: need bin dir and config dir" >&2
    exit 1
fi

script_dir="`dirname "$(readlink -f "$0")"`"

proj="$(basename "$script_dir")"

echo "project: $proj"

# user specified directory
bindir="$1"
condir="$2"

if [ "$bindir" != "/" ]; then bindir=${bindir%/}; fi
if [ "$condir" != "/" ]; then condir=${condir%/}/; fi

condir=${condir}$proj

# optional
appdir="$3"
if [ -z "$appdir" ]; then appdir='/usr/share/applications'; fi

# confirm bin dir, config dir, app dir exist
echo "confirm directory exist"
confirm_dir "$bindir"
confirm_dir "$condir"
confirm_dir "$appdir"

# absolute path
bindir="$(readlink -f "$bindir")"
condir="$(readlink -f "$condir")"
appdir="$(readlink -f "$appdir")"

conf=${condir}/config

echo
echo "install paths setup:"
echo "bin dir: $bindir"
echo "config dir: $condir"
echo "application dir: $appdir"
echo "script dir: $script_dir"

echo "configure file: $conf"

# handle scripts
echo
echo "handle scripts"
for script in "${scripts[@]}"
do
    echo "script: $script"
    cp "${script_dir}/${script}.sh" "${bindir}/$script"
done

# handle initial configure
echo
echo "handle configure file"
if [ -f "$conf" ]; then
    echo "conf: $conf exist."
    echo "use previous configure file"
else
    echo "conf: $conf not exist."
    echo "create a template configure file."
    echo -e "${RED}WARNING: fill up commented lines before use${NONE}" >&2

    echo "# port LOCAL-PORT"            >$conf
    echo "port-type socks5"            >>$conf
    echo "# remote-server USER@SERVER" >>$conf
    echo                               >>$conf
    echo "# log-file FILE-NAME"        >>$conf
    echo "auto-ssh yes"                >>$conf
fi

# handle desktop
echo
echo "handle desktop"
appf="$appdir/$(${script_dir}/create-desktop-in.sh -o)"
echo "desktop app file: $appf"

## app dir permission
if [ -w "$appdir" ]; then sudo=''; else sudo=sudo; fi
[ "$sudo" ] && echo "sudo: yes" || echo "sudo: no"

## bin dir in PATH or not
commd="${bindir}/chrome-with-proxy"
for d in "$(echo $PATH | sed 's/:/ /g')"
do
    path="$(readlink -f "$d")"
    if [ "$path" == "$bindir" ]; then commd="chrome-with-proxy"; break; fi
done
echo "script file: $commd"

$sudo ${script_dir}/create-desktop-in.sh "$commd" "$conf" "$appdir"

# handle uninstall script
echo
echo "handle uninstall script"
${script_dir}/create-uninstall.sh "$bindir" "$appf"
