#!/bin/bash

#
# MAC OS X LOGIN HOOK
#
# LoginHook runs under the super user privilege!
#
# To add this LoginHook script:
# chmod +x /path/to/hook.sh
# sudo defaults write com.apple.loginwindow LoginHook /path/to/hook.sh
#
# To confirm added:
# sudo defaults read com.apple.loginwindow LoginHook
#
# To remove it:
# sudo defaults delete com.apple.loginwindow LoginHook


logger "LoginHook: Starting for ${1}"


##
# Variables

USER=${1}
eval HOMELOC=~${USER}


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
    "${RAMDISK_CACHE_PATH}/Firefox"
    "${RAMDISK_CACHE_PATH}/Google"
    "${RAMDISK_CACHE_PATH}/Opera"
)

mkdir -p ${RAMDISK_CACHE_PATH}

for (( I=0; I < ${#DEST_PATHS[@]}; ++I ))
do
    mkdir -p ${DEST_PATHS[${I}]}

    # Check if UA cache directory is symbolic linked to the ram disk
    if [ ! -d ${SRC_PATHS[${I}]} ] || [ ! -L ${SRC_PATHS[${I}]} ]
    then
        rm -rf ${SRC_PATHS[${I}]}
        sudo -u ${USER} ln -s ${DEST_PATHS[${I}]} ${SRC_PATHS[${I}]}
    fi
done

chmod -R u=rwX,g=rwX,o=rwX ${RAMDISK_CACHE_PATH}


##
# Other optimisations

# Disable built-in keyboard
if [ 'C02GH2A9DV7M' == $(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}') ]
then
    kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext
fi


# Done
unset \
    USER \
    HOMELOC \
    RD_SIZE \
    RD_MOUNTPOINT \
    RAMDISK_CACHE_PATH \
    DEST_PATHS \
    SRC_PATHS
