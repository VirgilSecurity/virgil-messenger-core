#!/bin/bash

SCRIPT_FOLDER="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPT_FOLDER}/ish/common.sh

PLATFORM=linux-mingw
LINUX_QMAKE="${CFG_QT_SDK_DIR}/mingw32/bin/qmake"
export QT_BUILD_DIR_SUFFIX=windows
BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}
COMMON_LIB_PATH=${BUILD_DIR}/release/installed/usr/local/lib

#***************************************************************************************
cp_libs() {
  local SRC_COMMON_LIB="${1}"
  for cur_file in ${SRC_COMMON_LIB}; do
    if [ ! -f $cur_file ]; then
      echo " > ${cur_file} NOT FOUND"
      return 1
    fi
    echo " > Copy $(basename ${cur_file}) -> lib"
    cp -f "${cur_file}" "${COMMON_LIB_PATH}"
    check_error
  done
}

#***************************************************************************************
print_title

prepare_build_dir ${BUILD_DIR}

build_iotkit windows

# TODO: Why do we use gcc_64 ? Looks like there is need in a fix.
build_qxmpp gcc_64 \
  -DCMAKE_TOOLCHAIN_FILE=/usr/share/mingw/toolchain-mingw64.cmake \
  -DCYGWIN=1

${SCRIPT_FOLDER}/copy-qt-iotkit.sh

echo
echo "=== Copy common library"
echo

# Copy dlls from bin directory
cp_libs "${BUILD_DIR}/release/installed/usr/local/bin/*.dll"
rm -rf ${BUILD_DIR}/release/installed/usr/local/bin

# Copy already built windows dll's. openssl 1.1
cp_libs "${SCRIPT_FOLDER}/../win/dll/*.dll"

MINGW_BASE="/usr/x86_64-w64-mingw32/sys-root/mingw/bin"

pushd "${MINGW_BASE}"
cp_libs libssl-10.dll
cp_libs libcrypto-10.dll
cp_libs libcurl-4.dll
cp_libs libgcc_s_sjlj-1.dll
cp_libs libcrypto-10.dll
cp_libs libssl-10.dll
cp_libs libssh2-1.dll
cp_libs libidn2-0.dll
cp_libs zlib1.dll
cp_libs libgcc_s_sjlj-1.dll
cp_libs ${CFG_QT_SDK_DIR}/mingw64/bin/libgcc_s_dw2-1.dll
popd

print_final_message
