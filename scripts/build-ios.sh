#!/bin/bash

SCRIPT_FOLDER="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPT_FOLDER}/ish/common.sh

#
#   Global variables
#
PLATFORM=ios
QMAKE_BIN=${CFG_QT_SDK_DIR}/ios/bin/qmake
export QT_BUILD_DIR_SUFFIX=ios
BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}

#*************************************************************************************************************
build_external_libs() {
    echo
    echo "=== Build iOS libs"
    echo
    if [ "${CFG_BUILD_IOS_CURL_SSL}" == "off" ]; then
        echo "Skip due to config parameter CFG_BUILD_IOS_CURL_SSL"
        echo
        return
    fi
    ${SCRIPT_FOLDER}/prepare-ios-libs.sh ${CONFIG_FILE} ${HOST_PLATFORM}
    check_error
}

#*************************************************************************************************************

print_title

prepare_build_dir ${BUILD_DIR}

build_external_libs

build_iotkit ios

build_qxmpp ios \
    -DAPPLE_PLATFORM="IOS" \
    -DAPPLE_BITCODE=OFF \
    -DCMAKE_TOOLCHAIN_FILE="${SCRIPT_FOLDER}/../virgil-iotkit/sdk/cmake/toolchain/apple.cmake"

${SCRIPT_FOLDER}/copy-qt-iotkit.sh

print_final_message
