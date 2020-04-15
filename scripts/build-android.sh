#!/bin/bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
source ${SCRIPT_FOLDER}/ish/common.ish

#
#    Check input parameters
#
ANDROID_NDK="${2:-/opt/android/ndk}"
ANDROID_PLATFORM="${3:-android-24}"

if [ -z "$ANDROID_NDK" ] || [ ! -d ${ANDROID_NDK} ]; then
    echo "Wrong Android NDK directory: ${ANDROID_NDK}"
    exit 1
fi

if [ -z "$ANDROID_PLATFORM" ]; then
    echo "Android platform is not set"
    exit 1
fi
export ANDROID_NDK_ROOT=${ANDROID_NDK}

#
#   Global variables
#
ANDOID_APP_ID="com.virgilsecurity.qtmessenger"
PLATFORM=android-clang

TOOL_NAME=qmake
ANDROID_MAKE="${ANDROID_NDK}/prebuilt/${HOST_PLATFORM}/bin/make"

#*************************************************************************************************************
build_external_libs() {
    echo
    echo "=== Make Android libs"
    echo
    ${SCRIPT_FOLDER}/prepare-android-libs.sh ${ANDROID_NDK} ${HOST_PLATFORM} ${ANDOID_APP_ID}
    check_error 
}

#*************************************************************************************************************
build_proc() {
  PLATFORM="$1"
  LIB_ARCH="$2"
  
  local ANDROID_QMAKE="${QT_SDK_DIR}/${PLATFORM}/bin/qmake"
  local BUILD_DIR="${PROJECT_DIR}/${BUILD_TYPE}/${TOOL_NAME}.${PLATFORM}"
  local ANDROID_DEPLOY_QT="${QT_SDK_DIR}/${PLATFORM}/bin/androiddeployqt"

  echo
  echo "===================================="
  echo "=== ${PLATFORM} ${APPLICATION_NAME} build"
  echo "=== Build type : ${BUILD_TYPE}"
  echo "=== Tool name : ${TOOL_NAME}"
  echo "=== Output directory : ${BUILD_DIR}"
  echo "===================================="
  echo

  echo
  echo "=== Make application bundle [${PLATFORM}]"
  echo

  echo "=== Prepare directory"
  echo  
  rm -rf ${BUILD_DIR} || true
  mkdir -p ${BUILD_DIR}  
  check_error
  
  echo "=== Building libraries"
  echo
  
  pushd ${PROJECT_DIR}
    echo
    echo "=== Make IoTKit for Qt"
    echo
    virgil-iotkit/sdk/scripts/build-for-qt.sh android ${ANDROID_NDK} ${LIB_ARCH} ${ANDROID_PLATFORM}
    check_error

    echo
    echo "=== Make QXMPP"
    echo
    export QT_BUILD_DIR_SUFFIX=android.${LIB_ARCH}

    ${SCRIPT_FOLDER}/build-qxmpp.sh ${QT_SDK_DIR}/${PLATFORM} -DANDROID_QT=ON \
    -DQt5_DIR=${QT_SDK_DIR}/${PLATFORM}/lib/cmake/Qt5/ \
    -DQt5Core_DIR=${QT_SDK_DIR}/${PLATFORM}/lib/cmake/Qt5Core/ \
    -DQt5Network_DIR=${QT_SDK_DIR}/${PLATFORM}/lib/cmake/Qt5Network/ \
    -DQt5Xml_DIR=${QT_SDK_DIR}/${PLATFORM}/lib/cmake/Qt5Xml/ \
    -DANDROID_PLATFORM=${ANDROID_PLATFORM} \
    -DANDROID_ABI=${LIB_ARCH} \
    -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake

    check_error
  popd
}

#*************************************************************************************************************

build_external_libs

build_proc android_arm64_v8a arm64-v8a
build_proc android_armv7 armeabi-v7a
build_proc android_x86 x86
