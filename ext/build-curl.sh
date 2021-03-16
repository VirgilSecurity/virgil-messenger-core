#!/bin/bash

#
#   Global variables
#
SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
export CA_FILE=/data/user/0/${APP_ID}/files/cert.pem
BUILD_TYPE="${1:-release}"
#
#   Includes
#
source ${SCRIPT_FOLDER}/ish/error.ish

#***************************************************************************************
function build_curl() {
    export TARGET_HOST=${1}
    local BUILD_DIR=${2}
    local OPENSSL_LIB_PREFIX=${3}
    
    echo "##############################"
    echo "### Current build directory [${BUILD_DIR}]"
    echo "##############################"
    
    local DEBUG_PARAM="--disable-debug"
    [ "${BUILD_TYPE}" == "debug" ] && DEBUG_PARAM="--enable-debug"
    
    if [ $TARGET_HOST == "armv7a-linux-androideabi" ]; then
        TOOLS_PREFIX=arm-linux-androideabi
    else
        TOOLS_PREFIX=$TARGET_HOST
    fi
    
    local PRFIX_DIR=${INSTALL_DIR_BASE}/android.${BUILD_DIR}/${BUILD_TYPE}/installed/usr/local
    
    # Prepare QT shared OpenSSL libs
    rm -rf ${PWD}/${BUILD_DIR}/openssl_lib
    mkdir -p ${PWD}/${BUILD_DIR}/openssl_lib
    ln -s ${ANDROID_SDK_ROOT}/android_openssl/latest/${OPENSSL_LIB_PREFIX}/libcrypto_1_1.so ${PWD}/${BUILD_DIR}/openssl_lib/libcrypto.so
    ln -s ${ANDROID_SDK_ROOT}/android_openssl/latest/${OPENSSL_LIB_PREFIX}/libssl_1_1.so    ${PWD}/${BUILD_DIR}/openssl_lib/libssl.so
    export CPPFLAGS="-I${ANDROID_SDK_ROOT}/android_openssl/static/include" 
    export LDFLAGS="-Wl,-L${PWD}/${BUILD_DIR}/openssl_lib/"
    
    # Prepare toolchain    
    export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
    PATH=$TOOLCHAIN/bin:$PATH
    export AR=$TOOLCHAIN/bin/$TOOLS_PREFIX-ar
    export AS=$TOOLCHAIN/bin/$TOOLS_PREFIX-as
    export CC=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang
    export CXX=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang++
    export LD=$TOOLCHAIN/bin/$TARGET_HOST-ld
    export RANLIB=$TOOLCHAIN/bin/$TOOLS_PREFIX-ranlib
    export STRIP=$TOOLCHAIN/bin/$TOOLS_PREFIX-strip
    
    make clean

    ./configure --host=$TARGET_HOST \
    --target=$TARGET_HOST \
    --prefix=${PRFIX_DIR} \
    --with-ssl \
    --disable-dependency-tracking \
    --with-ca-bundle=$CA_FILE \
    --disable-shared \
    --disable-verbose \
    --disable-manual \
    ${DEBUG_PARAM} \
    --disable-crypto-auth \
    --disable-unix-sockets \
    --disable-ares \
    --disable-rtsp \
    --disable-ipv6 \
    --disable-proxy \
    --disable-versioned-symbols \
    --enable-hidden-symbols \
    --without-libidn \
    --without-librtmp \
    --without-zlib \
    --disable-dict \
    --disable-file \
    --disable-ftp \
    --disable-ftps \
    --disable-gopher \
    --disable-imap \
    --disable-imaps \
    --disable-pop3 \
    --disable-pop3s \
    --disable-smb \
    --disable-smbs \
    --disable-smtp \
    --disable-smtps \
    --disable-telnet \
    --disable-tftp
    check_error
    
    make -j10
    check_error
    
    make install
    check_error

#    rm -rf ${PWD}/${BUILD_DIR}/openssl_lib
}

#***************************************************************************************
#
#   Prepare artifacts folder
#
OPENSSL_DIR="${SCRIPT_FOLDER}/build/curl"
if [ -d ${OPENSSL_DIR} ]; then
    rm -rf OPENSSL_DIR
fi
mkdir -p ${OPENSSL_DIR}
check_error

#
#   Buils for all architectures
#
pushd ${SCRIPT_FOLDER}/curl
./buildconf
check_error

# arm64
build_curl aarch64-linux-android arm64-v8a arm64
check_error

# arm
build_curl armv7a-linux-androideabi armeabi-v7a arm
check_error

# x86
build_curl i686-linux-android x86 x86
check_error

# x64
build_curl x86_64-linux-android x86_64 x86_64
check_error

popd

#***************************************************************************************
