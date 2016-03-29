#!/bin/bash

#
# MAC OS X LOGOUT HOOK (DEPRECATED)
#
# LogoutHook runs under the super user privilege!
#
# To add this LogoutHook script:
# chmod +x /path/to/logouthook.sh
# sudo defaults write com.apple.loginwindow LogoutHook /path/to/loginhook.sh
#
# To confirm added:
# sudo defaults read com.apple.loginwindow LogoutHook
#
# To remove it:
# sudo defaults delete com.apple.loginwindow LogoutHook
#
# Reference:
# https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CustomLogin.html


##
# Variables

CWD=$(pwd)
USER=${1}
eval HOMELOC=~${USER}


# Start
logger -i -t LogoutHook "LogoutHook: Starting for ${USER}"


# Done
unset \
    CWD \
    USER \
    HOMELOC
