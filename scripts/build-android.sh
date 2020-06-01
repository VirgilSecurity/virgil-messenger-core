#!/bin/bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
source ${SCRIPT_FOLDER}/ish/common.sh

#
#    Check input parameters
#

if [ -z "$CFG_ANDROID_NDK" ] || [ ! -d ${CFG_ANDROID_NDK} ]; then
    echo "Wrong Android NDK directory: ${CFG_ANDROID_NDK}"
    exit 1
fi

if [ -z "$CFG_ANDROID_PLATFORM" ]; then
    echo "Android platform is not set"
    exit 1
fi
export ANDROID_NDK_ROOT=${CFG_ANDROID_NDK}

#
#   Global variables
#
PLATFORM=android-clang
ANDOID_APP_ID="com.virgilsecurity.qtmessenger"
ANDROID_MAKE="${CFG_ANDROID_NDK}/prebuilt/${HOST_PLATFORM}/bin/make"

#*************************************************************************************************************
build_external_libs() {
    echo
    echo "=== Build Android libs"
    echo
    if [ "${CFG_BUILD_ANDROID_CURL_SSL}" == "off" ]; then
        echo "Skip due to config parameter CFG_BUILD_ANDROID_CURL_SSL"
        echo
        return
    fi
    ${SCRIPT_FOLDER}/prepare-android-libs.sh ${CONFIG_FILE} ${HOST_PLATFORM} ${ANDOID_APP_ID}
    check_error
}

#*************************************************************************************************************
build_proc() {
    PLATFORM="$1"
    LIB_ARCH="$2"
    
    local ANDROID_QMAKE="${CFG_QT_SDK_DIR}/${PLATFORM}/bin/qmake"
    local ANDROID_DEPLOY_QT="${CFG_QT_SDK_DIR}/${PLATFORM}/bin/androiddeployqt"
    export QT_BUILD_DIR_SUFFIX=android.${LIB_ARCH}
    BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}
    
    print_title
    build_iotkit android ${CFG_ANDROID_NDK} ${LIB_ARCH} ${CFG_ANDROID_PLATFORM}
    
    build_qxmpp ${PLATFORM} \
    -DANDROID_QT=ON \
    -DANDROID_PLATFORM=${CFG_ANDROID_PLATFORM} \
    -DANDROID_ABI=${LIB_ARCH} \
    -DCMAKE_TOOLCHAIN_FILE=${CFG_ANDROID_NDK}/build/cmake/android.toolchain.cmake
    
    print_final_message
}

#*************************************************************************************************************

prepare_build_dir ${PROJECT_DIR}/prebuilt/android.arm64-v8a
prepare_build_dir ${PROJECT_DIR}/prebuilt/android.armeabi-v7a
prepare_build_dir ${PROJECT_DIR}/prebuilt/android.x86

build_external_libs

build_proc android_arm64_v8a arm64-v8a
build_proc android_armv7 armeabi-v7a
build_proc android_x86 x86

${SCRIPT_FOLDER}/copy-qt-iotkit.sh
