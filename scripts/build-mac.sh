#!/bin/bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
source ${SCRIPT_FOLDER}/ish/common.sh

#
#   Global variables
#
PLATFORM=mac
QMAKE_BIN=${CFG_QT_SDK_DIR}/clang_64/bin/qmake
MACDEPLOYQT_BIN=${CFG_QT_SDK_DIR}/clang_64/bin/macdeployqt
export QT_BUILD_DIR_SUFFIX=macos
BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}

#***************************************************************************************

print_title

prepare_build_dir

build_iotkit macos

build_qxmpp clang_64

print_final_message
