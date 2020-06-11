#!/bin/bash

SCRIPT_FOLDER="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPT_FOLDER}/ish/common.sh
source ${SCRIPT_FOLDER}/ish/qtwebdriver.sh

PLATFORM=linux-mingw
LINUX_QMAKE="${CFG_QT_SDK_DIR}/mingw32/bin/qmake"
export QT_BUILD_DIR_SUFFIX=windows
BUILD_DIR=${PROJECT_DIR}/prebuilt/${QT_BUILD_DIR_SUFFIX}

#***************************************************************************************
cp_libs() {
  local SRC_COMMON_LIB="${1}"
  local BUILD_TYPE="${2}"
  local COMMON_LIB_PATH=${BUILD_DIR}/${BUILD_TYPE}/installed/usr/local/lib

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
function copy_libs() {
   local BUILD_TYPE="${1}"
   MINGW_BASE="/usr/x86_64-w64-mingw32/sys-root/mingw/bin"

   # Copy dlls from bin directory
   cp_libs "${BUILD_DIR}/${BUILD_TYPE}/installed/usr/local/bin/*.dll" "${BUILD_TYPE}"
   rm -rf ${BUILD_DIR}/${BUILD_TYPE}/installed/usr/local/bin

   # Copy already built windows dll's. openssl 1.1
   cp_libs "${SCRIPT_FOLDER}/../win/dll/*.dll" "${BUILD_TYPE}"

   pushd "${MINGW_BASE}"
     cp_libs libssl-10.dll          "${BUILD_TYPE}"
     cp_libs libcrypto-10.dll       "${BUILD_TYPE}"
     cp_libs libcurl-4.dll          "${BUILD_TYPE}"
     cp_libs libgcc_s_sjlj-1.dll    "${BUILD_TYPE}"
     cp_libs libcrypto-10.dll       "${BUILD_TYPE}"
     cp_libs libssl-10.dll          "${BUILD_TYPE}"
     cp_libs libssh2-1.dll          "${BUILD_TYPE}"
     cp_libs libidn2-0.dll          "${BUILD_TYPE}"
     cp_libs zlib1.dll              "${BUILD_TYPE}"
     cp_libs libgcc_s_sjlj-1.dll    "${BUILD_TYPE}"
     cp_libs ${CFG_QT_SDK_DIR}/mingw64/bin/libgcc_s_seh-1.dll "${BUILD_TYPE}"
   popd
}
#***************************************************************************************
print_title

prepare_build_dir ${BUILD_DIR}

print_message "Building qtwebdriver"

build_qtwebdriver ${LINUX_QMAKE} ${BUILD_DIR}

build_iotkit windows

# TODO: Why do we use gcc_64 ? Looks like there is need in a fix.
build_qxmpp gcc_64 \
  -DCMAKE_TOOLCHAIN_FILE=/usr/share/mingw/toolchain-mingw64.cmake \
  -DCYGWIN=1

${SCRIPT_FOLDER}/copy-qt-iotkit.sh

echo
echo "=== Copy common library (debug)"
echo
copy_libs debug

echo
echo "=== Copy common library (release)"
echo
copy_libs release

print_final_message
