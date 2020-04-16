#!/bin/bash

PROJECT_DIR="${SCRIPT_FOLDER}/.."
APPLICATION_NAME=virgil-messenger
BUILD_TYPE=release
TOOL_NAME=qmake
BUILD_IOTKIT_FOR_QT_SH=${SCRIPT_FOLDER}/../virgil-iotkit/sdk/scripts/build-for-qt.sh

export QT_INSTALL_DIR_BASE=${PROJECT_DIR}/prebuilt

source ${SCRIPT_FOLDER}/ish/error.sh

#
# Check platform
#
if [ $(uname) == "Darwin" ]; then
    HOST_PLATFORM="darwin-x86_64"
    elif [ $(uname) == "Linux" ]; then
    HOST_PLATFORM="linux-x86_64"
else
    echo "Wrong platform $(uname). Supported only: [Linux, Darwin]"
    exit 1
fi

CONFIG_FILE=${1}
if [ ! -f ${CONFIG_FILE} ]; then
    echo "Wrong configuration file: ${CONFIG_FILE}"
    exit 1
fi

source ${CONFIG_FILE}

if [ -z "$CFG_QT_SDK_DIR" ] || [ ! -d ${CFG_QT_SDK_DIR} ]; then
    echo "Wrong Qt directory: CFG_QT_SDK_DIR=${CFG_QT_SDK_DIR}"
    exit 1
fi

#*************************************************************************************************************
function prepare_build_dir() {
    echo "=== Prepare directory"
    echo
    if [ "${CFG_CLEAN}" == "off" ]; then
        echo "Skip due to config parameter CFG_CLEAN"
        echo
        return
    fi
    rm -rf ${BUILD_DIR} || true
    mkdir -p ${BUILD_DIR}
    check_error
}

#*************************************************************************************************************
function print_title() {
    echo
    echo "===================================="
    echo "=== ${PLATFORM} ${APPLICATION_NAME} build"
    echo "=== Build type : ${BUILD_TYPE}"
    echo "=== Tool name : ${TOOL_NAME}"
    echo "=== Output directory : ${BUILD_DIR}"
    echo "===================================="
    echo
}

#*************************************************************************************************************
function print_final_message() {
    echo
    echo "===================================="
    echo "=== ${PLATFORM} is ready"
    echo "===================================="
    echo
}

#*************************************************************************************************************
function build_iotkit() {
    echo
    echo "=== Build IoTKit for Qt"
    echo
    if [ "${CFG_BUILD_IOTKIT}" == "off" ]; then
        echo "Skip due to config parameter CFG_BUILD_IOTKIT"
        echo
        return
    fi
    ${BUILD_IOTKIT_FOR_QT_SH} ${@}
    check_error
}

#*************************************************************************************************************
function build_qxmpp() {
    echo
    echo "=== Build QXMPP"
    echo
    if [ "${CFG_BUILD_QXMPP}" == "off" ]; then
        echo "Skip due to config parameter CFG_BUILD_QXMPP"
        echo
        return
    fi
    ${SCRIPT_FOLDER}/prepare-qxmpp.sh ${@:2} \
    ${CFG_QT_SDK_DIR}/${1} \
    -DQt5_DIR=${CFG_QT_SDK_DIR}/${1}/lib/cmake/Qt5/ \
    -DQt5Core_DIR=${CFG_QT_SDK_DIR}/${1}/lib/cmake/Qt5Core/ \
    -DQt5Network_DIR=${CFG_QT_SDK_DIR}/${1}/lib/cmake/Qt5Network/ \
    -DQt5Xml_DIR=${CFG_QT_SDK_DIR}/${1}/lib/cmake/Qt5Xml/
    check_error
}

#*************************************************************************************************************
