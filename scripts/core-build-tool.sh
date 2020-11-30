#!/bin/bash
#
#   Global variables
#

SCRIPT_FOLDER="$(cd $(dirname "$0") && pwd)"
source ${SCRIPT_FOLDER}/ish/common.sh
set -e

############################################################################################
print_usage() {
  echo
  echo "$(basename ${0})"
  echo
  echo "  -t < Target OS  >"
  echo "  -h"
  exit 0
}
############################################################################################
#
#  Script parameters
#
############################################################################################

TARGET_OS="linux"
while [ -n "$1" ]
 do
   case "$1" in
     -h) print_usage
         exit 0
         ;;
     -s) SOURCE_DIR="$2"
         shift
         ;;
     -t) TARGET_OS="$2"
         shift
         ;;          
     -c) CUSTOMER="$2"
         shift
         ;;          
     *) print_usage;;
   esac
   shift
done

############################################################################################

function build_qxmpp() {
    local BUILD_TYPE="release"
    local QT_LIB_PREFIX=$1
    local CORES=10
    local QXMPP_DIR="${SCRIPT_FOLDER}/../ext/qxmpp"
    local BUILD_DIR_BASE="${QXMPP_DIR}"
    local BUILD_DIR=${BUILD_DIR_BASE}/cmake-build-${QT_BUILD_DIR_SUFFIX}/${BUILD_TYPE}
    local INSTALL_DIR=${QT_INSTALL_DIR_BASE}/${QT_BUILD_DIR_SUFFIX}/${BUILD_TYPE}/installed
    
    echo
    echo "===================================="
    echo "=== Building QXMPP"
    echo "=== ${QT_BUILD_DIR_SUFFIX} ${BUILD_TYPE} build"
    echo "=== Output directory: ${BUILD_DIR}"
    echo "===================================="
    echo
    
    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    mkdir -p ${INSTALL_DIR}
    
    pushd ${BUILD_DIR}
    # prepare to build
    cmake  -DBUILD_SHARED=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DWITH_OPUS=OFF \
	   -DWITH_VPX=OFF -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -G "Unix Makefiles" \
	   -DCMAKE_PREFIX_PATH="${CFG_QT_SDK_DIR}/${QT_LIB_PREFIX}" \
           -DQt5_DIR=${CFG_QT_SDK_DIR}/${QT_LIB_PREFIX}/lib/cmake/Qt5/ \
           -DQt5Core_DIR=${CFG_QT_SDK_DIR}/${QT_LIB_PREFIX}/lib/cmake/Qt5Core/ \
           -DQt5Network_DIR=${CFG_QT_SDK_DIR}/${QT_LIB_PREFIX}/lib/cmake/Qt5Network/ \
           -DQt5Xml_DIR=${CFG_QT_SDK_DIR}/${QT_LIB_PREFIX}/lib/cmake/Qt5Xml/  ${BUILD_DIR_BASE}
    
    # build all targets
    make -j ${CORES}
    
    # install all targets
    make DESTDIR=${INSTALL_DIR} install
    if [ -d ${INSTALL_DIR}/usr/local/lib64 ]; then
        mkdir -p ${INSTALL_DIR}/usr/local/lib
        cp -rf ${INSTALL_DIR}/usr/local/lib64/* ${INSTALL_DIR}/usr/local/lib
        rm -rf ${INSTALL_DIR}/usr/local/lib64
    fi
    popd
}

############################################################################################
build_curl() {
    print_message "Building CURL"
    pushd ${PROJECT_DIR}/ext/openssl-curl-android
        ./build.sh "${CFG_ANDROID_NDK}" "${HOST_PLATFORM}" "com.virgilsecurity.qtmessenger"
    popd
}

############################################################################################
build_comkit() {

    CRYPTO_C_DIR="${SCRIPT_FOLDER}/../ext/virgil-crypto-c"
    BUILD_DIR_BASE="${CRYPTO_C_DIR}"
    PLATFORM="${1}"
    ANDROID_ABI="${2}"
    BUILD_DIR_SUFFIX=${PLATFORM}
    BUILD_TYPE="release"
    BUILD_DIR=${BUILD_DIR_BASE}/cmake-build-${BUILD_DIR_SUFFIX}/${BUILD_TYPE}
    LIBS_DIR=${INSTALL_DIR}/usr/local/lib${LIB_ARCH}

    [ "$(arch)" == "x86_64" ] && LIB_ARCH="64" || LIB_ARCH=""

   print_message "Building comm-kit"
    
   if [[ "${PLATFORM}" == "macos" ]]; then
       CMAKE_DEPS_ARGUMENTS=" \
       -DVSSC_HTTP_CLIENT_CURL=OFF \
       -DVSSC_HTTP_CLIENT_X=ON"
   elif [[ "${PLATFORM}" == "windows" && "$(uname)" == "Linux" ]]; then
       CMAKE_DEPS_ARGUMENTS=" \
           -DCMAKE_TOOLCHAIN_FILE=/usr/share/mingw/toolchain-mingw64.cmake \
           -DWINVER=0x0601 -D_WIN32_WINNT=0x0601 \
           -DCYGWIN=1"
   elif [[ "${PLATFORM}" == "linux" ]]; then
       CMAKE_DEPS_ARGUMENTS=" "
   elif [[ "${PLATFORM}" == "ios" ]]; then
       CMAKE_DEPS_ARGUMENTS=" \
           -DAPPLE_PLATFORM=IOS \
           -DAPPLE_BITCODE=ON \
           -DCMAKE_TOOLCHAIN_FILE=${BUILD_DIR_BASE}/ext/virgil-crypto-c/cmake/apple.cmake \
           -DVSSC_HTTP_CLIENT_CURL=OFF \
           -DVSSC_HTTP_CLIENT_X=ON"
   elif [[ "${PLATFORM}" == "ios-sim" ]]; then
       CMAKE_DEPS_ARGUMENTS=" \
           -DAPPLE_PLATFORM=IOS_SIM64 \
           -DAPPLE_BITCODE=ON \
           -DCMAKE_TOOLCHAIN_FILE=${BUILD_DIR_BASE}/ext/virgil-crypto-c/cmake/apple.cmake \
           -DVSSC_HTTP_CLIENT_CURL=OFF \
           -DVSSC_HTTP_CLIENT_X=ON"
   elif [[ "${PLATFORM}" == "android" ]]; then
       BUILD_DIR_SUFFIX="${PLATFORM}.${ANDROID_ABI}"
       CMAKE_DEPS_ARGUMENTS=" \
           -DCMAKE_CROSSCOMPILING=ON \
           -DANDROID=ON \
           -DANDROID_QT=ON  \
           ${ANDROID_PLATFORM} \
           -DANDROID_ABI=${ANDROID_ABI} \
           -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
           -DCURL_ROOT_DIR=${QT_INSTALL_DIR_BASE}/${BUILD_DIR_SUFFIX}/${BUILD_TYPE}/installed/usr/local/"
    fi    

    INSTALL_DIR=${QT_INSTALL_DIR_BASE}/${BUILD_DIR_SUFFIX}/${BUILD_TYPE}/installed    

    echo
    echo "===================================="
    echo "=== ${BUILD_DIR_SUFFIX} ${BUILD_TYPE} build"
    echo "=== Output directory: ${BUILD_DIR}"
    echo "=== Install directory: ${INSTALL_DIR}"
    echo "=== CURL directory: ${QT_INSTALL_DIR_BASE}/${BUILD_DIR_SUFFIX}/${BUILD_TYPE}/installed/usr/local}"
    echo "===================================="
    echo

    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    mkdir -p ${INSTALL_DIR}

    pushd ${BUILD_DIR}

    # prepare to build
    echo "==========="
    echo "=== Run CMAKE "
    echo "==========="
    cmake -DENABLE_TESTING=OFF -DENABLE_CLANGFORMAT=OFF -DVIRGIL_LIB_RATCHET=OFF \
	  -DVIRGIL_LIB_PHE=OFF -DVIRGIL_POST_QUANTUM=OFF -DBUILD_APPLE_FRAMEWORKS=OFF \
	  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" -G "Unix Makefiles" ${CMAKE_DEPS_ARGUMENTS} ${BUILD_DIR_BASE} 
			    
    # build all targets
    echo "==========="
    echo "=== Building"
    echo "==========="
    make -j 10

    # install all targets
    echo "==========="
    echo "=== Installing"
    echo "==========="
    make DESTDIR=${INSTALL_DIR} install

    if [ -d ${INSTALL_DIR}/usr/local/lib64 ]; then
        mkdir -p ${INSTALL_DIR}/usr/local/lib
        cp -rf ${INSTALL_DIR}/usr/local/lib64/* ${INSTALL_DIR}/usr/local/lib
        rm -rf ${INSTALL_DIR}/usr/local/lib64
    fi

    # Clean
    rm -rf ${INSTALL_DIR}/$(echo "$HOME" | cut -d "/" -f2)

    popd

}

############################################################################################
build_linux() {
    PLATFORM=linux-g++
    LINUX_QMAKE="${CFG_QT_SDK_DIR}/gcc_64/bin/qmake"
    export QT_BUILD_DIR_SUFFIX=linux
    BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}

    print_title
    prepare_build_dir ${BUILD_DIR}
#    print_message "Building qtwebdriver"
#    build_qtwebdriver ${LINUX_QMAKE} ${BUILD_DIR}
    build_comkit linux
    build_qxmpp gcc_64
    print_final_message
}

############################################################################################
build_android() {
    prepare_build_dir ${PROJECT_DIR}/prebuilt/android.arm64-v8a
    prepare_build_dir ${PROJECT_DIR}/prebuilt/android.armeabi-v7a
    prepare_build_dir ${PROJECT_DIR}/prebuilt/android.x86
    prepare_build_dir ${PROJECT_DIR}/prebuilt/android.x86_64

    build_curl
    build_comkit android arm64-v8a
    build_comkit android armeabi-v7a
    build_comkit android x86
    build_comkit android x86_64
    
    build_qxmpp gcc_64
}

############################################################################################
build_macos() {
 echo
}

############################################################################################

############################################################################################
case "${TARGET_OS}" in
  linux)   build_linux
           ;;
  macos)   build_macos
           ;;
  android) build_android
           ;;          
  ios)     build_ios
           ;;          
esac

############################################################################################
############################################################################################
############################################################################################


