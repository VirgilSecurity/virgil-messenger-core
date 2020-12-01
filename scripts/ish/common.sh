#!/bin/bash

PROJECT_DIR="${SCRIPT_FOLDER}/.."
source ${SCRIPT_FOLDER}/config/config-all.sh    

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

#*************************************************************************************************************
function prepare_build_dir() {
    echo "=== Prepare directory"
    echo
    if [ "${CFG_CLEAN}" == "off" ]; then
        echo "Skip due to config parameter CFG_CLEAN"
        echo
    else
        rm -rf ${1} || true
    fi
    mkdir -p ${1} || true
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
function print_message() {
    echo
    echo "=== $@"
    echo
}

