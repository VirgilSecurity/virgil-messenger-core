#!/bin/bash

SCRIPT_FOLDER="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPT_FOLDER}/ish/common.sh

#
#   Global variables
#
BUILD_DIR="${PROJECT_DIR}/tmp/"
LIBS_REPO="https://github.com/VirgilSecurity/openssl-curl-android.git"
LIBS_BRANCH="feature/build_ios"
export INSTALL_DIR_BASE="${PROJECT_DIR}/prebuilt"

IS_SIMULATOR=${3}

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
./build-curl-ios.sh "${IS_SIMULATOR}"
check_error
popd
popd
