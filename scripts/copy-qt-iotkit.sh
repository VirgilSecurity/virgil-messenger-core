#!/usr/bin/env bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
VS_COMMON_SIMPIFIED="true"
source ${SCRIPT_FOLDER}/ish/common.sh

#
#   Global variables
#
CONFIG_SRC_DIR=${PROJECT_DIR}/virgil-iotkit/sdk/config
QT_IOTKIT_SRC_DIR=${PROJECT_DIR}/virgil-iotkit/integration/qt
QT_IOTKIT_DST_DIR=${PROJECT_DIR}/prebuilt/qt

if [ -d ${QT_IOTKIT_DST_DIR} ]; then
    rm -rf ${QT_IOTKIT_DST_DIR}
fi
mkdir -p ${QT_IOTKIT_DST_DIR}
check_error

cp -r "${QT_IOTKIT_SRC_DIR}" "${QT_IOTKIT_DST_DIR}/../"
check_error

cp -r "${CONFIG_SRC_DIR}" "${QT_IOTKIT_DST_DIR}/"
check_error