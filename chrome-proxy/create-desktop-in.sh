#!/bin/bash

# create desktop in a directory, in pwd by fault

# most contents of desktop file copied from
#         /usr/share/applications/google-chrome.desktop

name=google-chrome-proxy.desktop

# just output desktop name, and then exit
if [ "$1" == "-o" ]; then # only output
    echo "$name"
    exit
fi

script="$1"
config="$2"

appdir="$3"  # directory to store desktop file
if [ -z "$appdir" ]; then appdir=$PWD; fi

fname="$appdir/$name"
echo "create desktop: $fname"

exec="$script -f $config"
echo "command: $exec"

cat >$fname <<EOF
[Desktop Entry]
Version=1.0
Name=Google Chrome with Proxy
# Only KDE 4 seems to use GenericName, so we reuse the KDE strings.
# From Ubuntu's language-pack-kde-XX-base packages, version 9.04-20090413.
GenericName=Web Browser
# Gnome and KDE 3 uses Comment.
Comment=Access the Internet
Exec=$exec
StartupNotify=true
Terminal=false
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
Actions=new-window;new-private-window;

[Desktop Action new-window]
Name=New Window
Exec=/usr/bin/google-chrome-stable

[Desktop Action new-private-window]
Name=New Incognito Window
Exec=/usr/bin/google-chrome-stable --incognito
EOF

chmod a+x $fname
