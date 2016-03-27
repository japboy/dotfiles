#!/bin/bash

#
# MAC OS X LOGOUT HOOK
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
logger "LogoutHook: Starting for ${USER}"


##
# Halt CoreOS instance through Vagrant if it exists

if [ -x /usr/local/bin/vagrant ] && [ -d ${HOMELOC}/.coreos-vagrant ]
then
    su - ${USER} <<__SCRIPT__
cd ${HOMELOC}/.coreos-vagrant && [[ 'poweroff' == $(/usr/local/bin/vagrant status | awk '/core-[0-9]{2}/ {print $2}') ]] && exit 0
cd ${HOMELOC}/.coreos-vagrant && exec /usr/local/bin/vagrant halt
__SCRIPT__
fi


# Done
unset \
    CWD \
    USER \
    HOMELOC
