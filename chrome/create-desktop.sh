#!/bin/bash

# most contents of desktop file copied from
#         /usr/share/applications/google-chrome.desktop


name=google-chrome-proxy.desktop


script="$1"
config="$2"

exec="$script -f $config"

cat >$name <<EOF
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

chmod a+x $name
