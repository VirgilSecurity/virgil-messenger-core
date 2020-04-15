#!/bin/bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
source ${SCRIPT_FOLDER}/ish/common.ish

#
#   Global variables
#
BUILD_DIR="${PROJECT_DIR}"
LIBS_REPO="https://github.com/VirgilSecurity/openssl-curl-android.git"
LIBS_BRANCH="virgil"
export INSTALL_DIR_BASE="${SCRIPT_FOLDER}/prebuilt"

#***************************************************************************************

function usage_example() {
    echo "Example: ${0} $HOME/Library/Android/sdk/ndk/20.1.5948944 darwin-x86_64 com.virgilsecurity.qtmessenger"
}

#***************************************************************************************

#
#    Check input parameters
#

ANDROID_NDK_HOME="${1}"
HOST_TAG="${2}"
ANDROID_APP_ID="${3}"

if [ -z "$ANDROID_NDK_HOME" ] || [ ! -d ${ANDROID_NDK_HOME} ]; then
    echo "Wrong NDK path: ${ANDROID_NDK_HOME}"
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
          ./build.sh ${ANDROID_NDK_HOME} ${HOST_TAG} ${ANDROID_APP_ID}
          check_error
     popd
popd