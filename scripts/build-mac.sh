#!/bin/bash

SCRIPT_FOLDER="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPT_FOLDER}/ish/common.sh

#
#   Global variables
#
PLATFORM=mac
QMAKE_BIN=${CFG_QT_SDK_DIR}/clang_64/bin/qmake
MACDEPLOYQT_BIN=${CFG_QT_SDK_DIR}/clang_64/bin/macdeployqt
export QT_BUILD_DIR_SUFFIX=macos
BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}

SPARKLE_ARCH="Sparkle-1.23.0.tar.bz2"
SPARKLE_URL="https://github.com/sparkle-project/Sparkle/releases/download/1.23.0/${SPARKLE_ARCH}"

#***************************************************************************************
function get_sparkle() {
    echo
    echo "=== Get Sparkle framework"
    echo
    if [ "${CFG_BUILD_SPARKLE}" == "off" ]; then
        echo "Skip due to config parameter CFG_BUILD_SPARKLE"
        echo
        return
    fi

    pushd ${BUILD_DIR}

    wget ${SPARKLE_URL}
    check_error

    rm -rf sparkle || true
    mkdir sparkle
    tar -xvjf ${SPARKLE_ARCH} -C sparkle
    check_error

    rm ${SPARKLE_ARCH}
    rm -rf "sparkle/Sparkle Test App.app"
    rm -rf "sparkle/Sparkle Test App.app.dSYM"
    rm "sparkle/CHANGELOG"
    rm "sparkle/LICENSE"
    rm "sparkle/SampleAppcast.xml"
    popd
}

#***************************************************************************************

print_title

prepare_build_dir ${BUILD_DIR}s

build_iotkit macos

build_qxmpp clang_64

${SCRIPT_FOLDER}/copy-qt-iotkit.sh

get_sparkle

print_final_message
