#!/usr/bin/env bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
source ${SCRIPT_FOLDER}/ish/common.sh

PLATFORM=linux-mingw
LINUX_QMAKE="${CFG_QT_SDK_DIR}/mingw32/bin/qmake"
export QT_BUILD_DIR_SUFFIX=windows
BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}

#***************************************************************************************
print_title

prepare_build_dir ${BUILD_DIR}

build_iotkit windows

# TODO: Why do we use gcc_64 ? Looks like there is need in a fix.
build_qxmpp gcc_64 \
-DCMAKE_TOOLCHAIN_FILE=/usr/share/mingw/toolchain-mingw32.cmake \
-DCYGWIN=1

${SCRIPT_FOLDER}/copy-qt-iotkit.sh

print_final_message
