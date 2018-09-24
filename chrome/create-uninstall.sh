#!/bin/bash

# create uninstall script to clean the install

# must support -o option to output filename of uninstall script

name=chrome-with-proxy-uninstall    # script to uninstall
if [ x"$1" == x"-o" ]; then # only output
    bindir=$2
    echo $bindir/$name
    exit
fi

echo "handle uninstall script"

script_dir="`dirname "$(readlink -f "$0")"`"

bindir="$1"
appf="$2"

# absolute path
bindir="$(readlink -f "$bindir")"
appf="$(readlink -f "$appf")"

fname="${bindir}/$name"
echo "uninstall script: $fname"

cat >$fname <<EOF
#!/bin/bash

# remove scripts
echo "remove scripts"
EOF

scripts_bin=(`${script_dir}/install.sh -o`)

# clean scripts
echo "clean scripts"
echo "scripts: ${scripts_bin[@]}"
for f in "${scripts_bin[@]}"
do
    echo "clean $f"
    echo "rm \"${bindir}/$f\"" >>$fname
done

# clean desktop
echo
echo "clean desktop"
echo "desktop: $appf"

cat >>$fname <<EOF

# remove desktop
echo "remove desktop"
EOF

## sudo for app dir
appdir=`dirname "$appf"`
echo "app directory: $appdir"

if [ -w "$appdir" ]; then sudo=''; else sudo='sudo '; fi
[ "$sudo" ] && echo "sudo: yes" || echo "sudo: no"

## command
echo "${sudo}rm \"$appf\"" >> $fname

# self clean
echo
echo "clean uninstall: self destroy"
echo "script: $name"

cat >>$fname <<EOF

# remove uninstall: self destroy
echo "remove $name"
rm "$fname"
EOF

chmod a+x "$fname"