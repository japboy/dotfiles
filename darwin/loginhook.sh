#!/bin/bash

#
# MAC OS X LOGIN HOOK (DEPRECATED)
#
# LoginHook runs under the super user privilege!
#
# To add this LoginHook script:
# chmod +x /path/to/loginhook.sh
# sudo defaults write com.apple.loginwindow LoginHook /path/to/loginhook.sh
#
# To confirm added:
# sudo defaults read com.apple.loginwindow LoginHook
#
# To remove it:
# sudo defaults delete com.apple.loginwindow LoginHook
#
# Reference:
# https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CustomLogin.html


##
# Variables

CWD=$(pwd)
USER=${1}
eval HOMELOC=~${USER}


# Start
logger -t -t LoginHook "LoginHook: Starting for ${USER}"


# Done
unset \
    CWD \
    USER \
    HOMELOC
