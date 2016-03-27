#!/bin/bash

#
# MAC OS X LOGIN HOOK
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
logger "LoginHook: Starting for ${USER}"


##
# Ramdisk configuration

RD_SIZE=262144  # 128 MB!!
RD_MOUNTPOINT=/Volumes/ramdisk

if [ ! -d ${RD_MOUNTPOINT} ]
then
    RD_IMAGE=$(hdid -nomount ram://${RD_SIZE})

    mkdir -p ${RD_MOUNTPOINT}
    newfs_hfs -v ramdisk ${RD_IMAGE}
    mount -t hfs ${RD_IMAGE} ${RD_MOUNTPOINT}
    chmod 777 ${RD_MOUNTPOINT}

    unset RD_IMAGE
fi


##
# Caches to the ramdisk

RAMDISK_CACHE_PATH="${RD_MOUNTPOINT}/Caches"

SRC_PATHS=(
    "${HOMELOC}/Library/Caches/com.apple.Safari"
    "${HOMELOC}/Library/Caches/com.google.Chrome"
    "${HOMELOC}/Library/Caches/com.google.Chrome.canary"
    "${HOMELOC}/Library/Caches/com.operasoftware.Opera"
    "${HOMELOC}/Library/Caches/org.mozilla.firefox"
    "${HOMELOC}/Library/Caches/Chromium"
    "${HOMELOC}/Library/Caches/Firefox"
    "${HOMELOC}/Library/Caches/Google"
    "${HOMELOC}/Library/Caches/Opera"
)

DEST_PATHS=(
    "${RAMDISK_CACHE_PATH}/com.apple.Safari"
    "${RAMDISK_CACHE_PATH}/com.google.Chrome"
    "${RAMDISK_CACHE_PATH}/com.google.Chrome.canary"
    "${RAMDISK_CACHE_PATH}/com.operasoftware.Opera/"
    "${RAMDISK_CACHE_PATH}/org.mozilla.firefox"
    "${RAMDISK_CACHE_PATH}/Chromium"
    "${RAMDISK_CACHE_PATH}/Firefox"
    "${RAMDISK_CACHE_PATH}/Google"
    "${RAMDISK_CACHE_PATH}/Opera"
)

mkdir -p ${RAMDISK_CACHE_PATH}

for (( IDX=0; IDX < ${#DEST_PATHS[@]}; ++IDX ))
do
    mkdir -p ${DEST_PATHS[${IDX}]}

    # Check if UA cache directory is symbolic linked to the ram disk
    if [ ! -d ${SRC_PATHS[${IDX}]} ] || [ ! -L ${SRC_PATHS[${IDX}]} ]
    then
        rm -rf ${SRC_PATHS[${IDX}]}
        sudo -u ${USER} ln -s ${DEST_PATHS[${IDX}]} ${SRC_PATHS[${IDX}]}
    fi
done

chmod -R u=rwX,g=rX,o=rX ${RAMDISK_CACHE_PATH}
chown -R ${USER}:staff ${RAMDISK_CACHE_PATH}


##
# Disable built-in keyboarddd (only for specific machine)

if [ 'C02GH2A9DV7M' == $(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}') ]
then
    kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext
fi


##
# Halt CoreOS instance through Vagrant if it exists

if [ -x /usr/local/bin/vagrant ] && [ -d ${HOMELOC}/.coreos-vagrant ]
then
    su - ${USER} <<__SCRIPT__
export PATH="/usr/local/bin:${PATH}"
cd ~/.coreos-vagrant
[[ 'running' == $(vagrant status | awk '/core-[0-9]{2}/ {print $2}') ]] && exit 0
vagrant up
__SCRIPT__
fi


# Done
unset \
    CWD \
    USER \
    HOMELOC \
    RD_SIZE \
    RD_MOUNTPOINT \
    RAMDISK_CACHE_PATH \
    DEST_PATHS \
    SRC_PATHS
