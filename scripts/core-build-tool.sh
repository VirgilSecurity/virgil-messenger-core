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
  echo "  -t [ linux | android | macos | ios | ios-sim ]  - Target platform "
  echo "  -h"
  exit 0
}
############################################################################################
#
#  Script parameters
#
############################################################################################

TARGET_OS="linux"
BUILD_TYPE="release"
export INSTALL_DIR_BASE="${PROJECT_DIR}/prebuilt"
while [ -n "$1" ]
 do
   case "$1" in
     -h) print_usage
         exit 0
         ;;
     -t) TARGET_OS="$2"
         shift
         ;;          
     -b) BUILD_TYPE="$2"
         shift
         ;;                   
     -i) export INSTALL_DIR_BASE="$2"
         shift
         ;;                      
     *) print_usage;;
   esac
   shift
done

############################################################################################
function get_sparkle() {
    
    print_message "=== Get Sparkle framework"

    BUILD_DIR=${PROJECT_DIR}/prebuilt/macos
    SPARKLE_ARCH="Sparkle-1.23.0.tar.bz2"
    SPARKLE_URL="https://github.com/sparkle-project/Sparkle/releases/download/1.23.0/${SPARKLE_ARCH}"
    
    pushd ${BUILD_DIR}
        wget ${SPARKLE_URL}
        rm -rf sparkle || true
        mkdir sparkle
        tar -xvjf ${SPARKLE_ARCH} -C sparkle

        rm ${SPARKLE_ARCH}
        rm -rf "sparkle/Sparkle Test App.app"
        rm -rf "sparkle/Sparkle Test App.app.dSYM"
        rm "sparkle/CHANGELOG"
        rm "sparkle/LICENSE"
        rm "sparkle/SampleAppcast.xml"
    popd
}

############################################################################################
function build_qxmpp() {
    local PLATFORM="${1}"
    local ANDROID_ABI="${2}"

    local CORES=10
    local QXMPP_DIR="${SCRIPT_FOLDER}/../ext/qxmpp"
    local BUILD_DIR_SUFFIX="${PLATFORM}"

    echo
    echo "===================================="
    echo "=== Building QXMPP"
    echo "=== ${QT_BUILD_DIR_SUFFIX} ${BUILD_TYPE} build"
    echo "=== Output directory: ${BUILD_DIR}"
    echo "===================================="
    echo
    
   if [[ "${PLATFORM}" == "macos" ]]; then
       QT_PREFIX="clang_64"
       CMAKE_DEPS_ARGUMENTS=" "
   elif [[ "${PLATFORM}" == "windows" && "$(uname)" == "Linux" ]]; then
       QT_PREFIX="mingw81_64"
       CMAKE_DEPS_ARGUMENTS="-DCMAKE_TOOLCHAIN_FILE=/usr/share/mingw/toolchain-mingw64.cmake \
           -DWINVER=0x0601 -D_WIN32_WINNT=0x0601 \
           -DCYGWIN=1 \
           "
   elif [[ "${PLATFORM}" == "linux" ]]; then
       QT_PREFIX="gcc_64"
       CMAKE_DEPS_ARGUMENTS=" "
   elif [[ "${PLATFORM}" == "ios" ]]; then
       QT_PREFIX="ios"         
       CMAKE_DEPS_ARGUMENTS=" \
        -DAPPLE_PLATFORM=IOS -DAPPLE_BITCODE=ON \
        -DCMAKE_TOOLCHAIN_FILE=${SCRIPT_FOLDER}/../ext/virgil-crypto-c/cmake/apple.cmake
        "
   elif [[ "${PLATFORM}" == "ios-sim" ]]; then
       QT_PREFIX="ios"      
       CMAKE_DEPS_ARGUMENTS=" \
        -DAPPLE_PLATFORM=IOS_SIM64 -DAPPLE_BITCODE=ON \
        -DCMAKE_TOOLCHAIN_FILE=${SCRIPT_FOLDER}/../ext/virgil-crypto-c/cmake/apple.cmake
        "
   elif [[ "${PLATFORM}" == "android" ]]; then
       QT_PREFIX="android"   
       BUILD_DIR_SUFFIX="${PLATFORM}.${ANDROID_ABI}"
       CMAKE_DEPS_ARGUMENTS=" \
	   -DANDROID_PLATFORM=${CFG_ANDROID_PLATFORM} \
	   -DANDROID_ABI=${ANDROID_ABI} \
	   -DCMAKE_TOOLCHAIN_FILE=${CFG_ANDROID_NDK}/build/cmake/android.toolchain.cmake \
	   "
    fi    
    
    local BUILD_DIR=${QXMPP_DIR}/cmake-build-${BUILD_DIR_SUFFIX}/${BUILD_TYPE}
    local INSTALL_DIR=${INSTALL_DIR_BASE}/${BUILD_DIR_SUFFIX}/${BUILD_TYPE}/installed
    
    rm -rf ${BUILD_DIR}
    mkdir -p ${BUILD_DIR}
    mkdir -p ${INSTALL_DIR}

    pushd ${BUILD_DIR}
    # prepare to build
    cmake  -DBUILD_SHARED=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF \
	   -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -G "Unix Makefiles" \
	   -DCMAKE_PREFIX_PATH="${CFG_QT_SDK_DIR}/${QT_PREFIX}" \
           -DQt5_DIR=${CFG_QT_SDK_DIR}/${QT_PREFIX}/lib/cmake/Qt5/ \
           -DQt5Core_DIR=${CFG_QT_SDK_DIR}/${QT_PREFIX}/lib/cmake/Qt5Core/ \
           -DQt5Network_DIR=${CFG_QT_SDK_DIR}/${QT_PREFIX}/lib/cmake/Qt5Network/ \
           -DQt5Xml_DIR=${CFG_QT_SDK_DIR}/${QT_PREFIX}/lib/cmake/Qt5Xml/ \
           ${CMAKE_DEPS_ARGUMENTS} \
           ${QXMPP_DIR}
    
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
    local PLATFORM="${1}"
    local ANDROID_ABI="${2}"        

    [ "$(arch)" == "x86_64" ] && LIB_ARCH="64" || LIB_ARCH=""    
    local CRYPTO_C_DIR="${SCRIPT_FOLDER}/../ext/virgil-crypto-c"
    local LIBS_DIR=${INSTALL_DIR}/usr/local/lib${LIB_ARCH}
    local BUILD_DIR_SUFFIX="${PLATFORM}"

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
           -DCMAKE_TOOLCHAIN_FILE=${CRYPTO_C_DIR}/cmake/apple.cmake \
           -DVSSC_HTTP_CLIENT_CURL=OFF \
           -DVSSC_HTTP_CLIENT_X=ON"
   elif [[ "${PLATFORM}" == "ios-sim" ]]; then
       CMAKE_DEPS_ARGUMENTS=" \
           -DAPPLE_PLATFORM=IOS_SIM64 \
           -DAPPLE_BITCODE=ON \
           -DCMAKE_TOOLCHAIN_FILE=${CRYPTO_C_DIR}/cmake/apple.cmake \
           -DVSSC_HTTP_CLIENT_CURL=OFF \
           -DVSSC_HTTP_CLIENT_X=ON"
   elif [[ "${PLATFORM}" == "android" ]]; then
       BUILD_DIR_SUFFIX="${PLATFORM}.${ANDROID_ABI}"
       CMAKE_DEPS_ARGUMENTS=" \
           -DCMAKE_CROSSCOMPILING=ON \
           -DANDROID=ON \
           -DANDROID_QT=ON  \
           -DANDROID_PLATFORM=${ANDROID_PLATFORM} \
           -DANDROID_ABI=${ANDROID_ABI} \
           -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
           -DCURL_ROOT_DIR=${INSTALL_DIR_BASE}/${BUILD_DIR_SUFFIX}/${BUILD_TYPE}/installed/usr/local/"
    fi    

    local BUILD_DIR=${CRYPTO_C_DIR}/cmake-build-${BUILD_DIR_SUFFIX}/${BUILD_TYPE}    
    local INSTALL_DIR=${INSTALL_DIR_BASE}/${BUILD_DIR_SUFFIX}/${BUILD_TYPE}/installed        

    echo
    echo "===================================="
    echo "=== ${BUILD_DIR_SUFFIX} ${BUILD_TYPE} build"
    echo "=== Output directory: ${BUILD_DIR}"
    echo "=== Install directory: ${INSTALL_DIR}"
    echo "=== CURL directory: ${INSTALL_DIR_BASE}/${BUILD_DIR_SUFFIX}/${BUILD_TYPE}/installed/usr/local}"
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
	  -DVIRGIL_LIB_PYTHIA=OFF -DVIRGIL_SDK_PYTHIA=OFF -DRELIC_LIBRARY=OFF \
	  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" -G "Unix Makefiles" ${CMAKE_DEPS_ARGUMENTS} ${CRYPTO_C_DIR}

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
    print_title
    prepare_build_dir linux
    build_comkit linux
    build_qxmpp linux
    print_final_message
}

############################################################################################
build_android() {
    print_title
    prepare_build_dir ${PROJECT_DIR}/prebuilt/android.arm64-v8a
    prepare_build_dir ${PROJECT_DIR}/prebuilt/android.armeabi-v7a
    prepare_build_dir ${PROJECT_DIR}/prebuilt/android.x86
    prepare_build_dir ${PROJECT_DIR}/prebuilt/android.x86_64

    build_curl
    build_comkit android arm64-v8a
    build_qxmpp  android arm64-v8a
    build_comkit android armeabi-v7a
    build_qxmpp  android armeabi-v7a
    build_comkit android x86
    build_qxmpp  android x86
    build_comkit android x86_64
    build_qxmpp  android x86_64
    print_final_message    

}

############################################################################################
build_macos() {
    print_title
    prepare_build_dir macos
    build_comkit macos
    build_qxmpp macos
    get_sparkle
    print_final_message

}

############################################################################################
build_ios() {
    print_title
    prepare_build_dir ios
    build_comkit ios
    build_qxmpp ios
    print_final_message

}

############################################################################################
build_ios_sim() {
    print_title
    prepare_build_dir ios-sim
    build_comkit ios-sim
    build_qxmpp ios-sim
    print_final_message

}

############################################################################################
build_windows() {
    print_title
    prepare_build_dir windows
    build_comkit windows
    build_qxmpp windows
    print_final_message
}


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
  ios-sim) build_ios_sim
           ;;
  windows) build_windows
           ;;
esac

############################################################################################
############################################################################################
############################################################################################


