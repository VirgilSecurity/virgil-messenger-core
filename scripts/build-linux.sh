#!/usr/bin/env bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
source ${SCRIPT_FOLDER}/ish/common.sh

#
#   Global variables
#
PLATFORM=linux-g++
LINUX_QMAKE="${CFG_QT_SDK_DIR}/gcc_64/bin/qmake"
export QT_BUILD_DIR_SUFFIX=linux
BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}

#***************************************************************************************

print_title

prepare_build_dir

build_iotkit linux

build_qxmpp gcc_64

print_final_message
