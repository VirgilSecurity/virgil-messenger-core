#!/bin/bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
source ${SCRIPT_FOLDER}/ish/common.sh

#
#   Global variables
#
BUILD_DIR="${PROJECT_DIR}/tmp/"
LIBS_REPO="https://github.com/VirgilSecurity/openssl-curl-android.git"
# LIBS_BRANCH="virgil"
LIBS_BRANCH="feature/build-debug"
export INSTALL_DIR_BASE="${PROJECT_DIR}/prebuilt"

#***************************************************************************************

function usage_example() {
    echo "Example: ${0} $HOME/Library/Android/sdk/ndk/20.1.5948944 darwin-x86_64 com.virgilsecurity.qtmessenger"
}

#***************************************************************************************

#
#    Check input parameters
#
HOST_TAG="${2}"
ANDROID_APP_ID="${3}"

if [ -z "$CFG_ANDROID_NDK" ] || [ ! -d ${CFG_ANDROID_NDK} ]; then
    echo "Wrong NDK path: ${CFG_ANDROID_NDK}"
    usage_example
    exit 1
fi

if [ -z "$HOST_TAG" ]; then
    echo "Host tag is not set: ${HOST_TAG}"
    usage_example
    exit 1
fi

if [ -z "$ANDROID_APP_ID" ]; then
    echo "App ID is not set: ${ANDROID_APP_ID}"
    usage_example
    exit 1
fi

#
# Prepare directory
#
if [ -d ${BUILD_DIR} ]; then
    rm -rf ${BUILD_DIR}
fi
mkdir ${BUILD_DIR}
check_error

pushd ${BUILD_DIR}
#
#    Clone repository
#
git clone --recursive -b ${LIBS_BRANCH} ${LIBS_REPO}
check_error

#
#    Build for all Android architectures
#
pushd openssl-curl-android
export
./build.sh ${CFG_ANDROID_NDK} ${HOST_TAG} ${ANDROID_APP_ID}
check_error
popd
popd