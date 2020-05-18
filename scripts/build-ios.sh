#!/bin/bash

SCRIPT_FOLDER="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPT_FOLDER}/ish/common.sh

#
#   Global variables
#
PLATFORM=ios
QMAKE_BIN=${CFG_QT_SDK_DIR}/ios/bin/qmake

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
build_ios() {
    echo "=== Build iOS libs"
    echo
    if [ "${CFG_BUILD_FOR_IOS_DEVICES}" == "off" ]; then
        echo "Skip due to config parameter CFG_BUILD_FOR_IOS_DEVICES"
        echo
        return
    fi

    print_title

    export QT_BUILD_DIR_SUFFIX=ios
    BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}
    prepare_build_dir ${BUILD_DIR}

    build_external_libs

    build_iotkit ios

    build_qxmpp ios \
        -DAPPLE_PLATFORM="IOS" \
        -DAPPLE_BITCODE=OFF \
        -DCMAKE_TOOLCHAIN_FILE="${SCRIPT_FOLDER}/../virgil-iotkit/sdk/cmake/toolchain/apple.cmake"

    print_final_message
}

#*************************************************************************************************************
build_ios_sim() {
    echo "=== Build iOS simulator libs"
    echo
    if [ "${CFG_BUILD_FOR_IOS_SIMULATOR}" == "off" ]; then
        echo "Skip due to config parameter CFG_BUILD_FOR_IOS_SIMULATOR"
        echo
        return
    fi

    print_title

    export QT_BUILD_DIR_SUFFIX=ios-sim
    BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}
    prepare_build_dir ${BUILD_DIR}

    build_external_libs

    build_iotkit ios-sim

    build_qxmpp ios \
        -DAPPLE_PLATFORM="IOS_SIM64" \
        -DAPPLE_BITCODE=OFF \
        -DCMAKE_TOOLCHAIN_FILE="${SCRIPT_FOLDER}/../virgil-iotkit/sdk/cmake/toolchain/apple.cmake"

    print_final_message
}

#*************************************************************************************************************

build_ios

build_ios_sim

# Copy Qt wrapper
${SCRIPT_FOLDER}/copy-qt-iotkit.sh
