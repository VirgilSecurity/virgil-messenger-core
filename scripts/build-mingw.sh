#!/usr/bin/env bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
. ${SCRIPT_FOLDER}/ish/error.ish

PROJECT_DIR="$1/"
QT_SDK_DIR="${2:-/opt/Qt/5.12.6}"

[ "${PROJECT_DIR}" == "" ] && exit 1

APPLICATION_NAME=virgil-messenger
BUILD_TYPE=release
PLATFORM=linux-mingw
PROJECT_FILE=${PROJECT_DIR}${APPLICATION_NAME}.pro
TOOL_NAME=qmake
BUILD_DIR=${PROJECT_DIR}${BUILD_TYPE}/${TOOL_NAME}.${PLATFORM}/

LINUX_QMAKE="${QT_SDK_DIR}/mingw32/bin/qmake"

#***************************************************************************************
echo
echo "===================================="
echo "=== ${PLATFORM} ${APPLICATION_NAME} build"
echo "=== Build type : ${BUILD_TYPE}"
echo "=== Tool name : ${TOOL_NAME}"
echo "=== Output directory : ${BUILD_DIR}"
echo "===================================="
echo

echo "=== Prepare directory"
echo

pushd ${PROJECT_DIR}
     echo
     echo "=== Make IoTKit for Qt"
     echo
     ext/virgil-iotkit/sdk/scripts/build-for-qt.sh windows
     check_error
     export QT_INSTALL_DIR_BASE=${PROJECT_DIR}/ext/prebuilt
     export QT_BUILD_DIR_SUFFIX=windows


     echo
     echo "=== Make QXMPP"
     echo
     scripts/build-qxmpp.sh ${QT_SDK_DIR}/gcc_64 \
          -DQt5_DIR=${QT_SDK_DIR}/gcc_64/lib/cmake/Qt5/ \
          -DQt5Core_DIR=${QT_SDK_DIR}/gcc_64/lib/cmake/Qt5Core/ \
          -DQt5Network_DIR=${QT_SDK_DIR}/gcc_64/lib/cmake/Qt5Network/ \
          -DQt5Xml_DIR=${QT_SDK_DIR}/gcc_64/lib/cmake/Qt5Xml \
          -DCMAKE_TOOLCHAIN_FILE=/usr/share/mingw/toolchain-mingw32.cmake \
          -DCYGWIN=1
     check_error

popd

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

pushd ${BUILD_DIR}
  check_error

  echo
  echo "=== Make application bundle"
  echo

  ${LINUX_QMAKE} -config ${BUILD_TYPE} ${PROJECT_DIR} -spec win32-x-g++
  check_error
  make
  check_error

  echo 
  echo "== Deploying application"
  echo
  cqtdeployer -bin ${BUILD_DIR}/release/${APPLICATION_NAME}.exe -qmlDir ${PROJECT_DIR}src/qml -qmake ${LINUX_QMAKE} clear
  check_error
  
  
  echo "=== Copy libvs-messenger-internal.dll "
  cp ${PROJECT_DIR}/ext/virgil-iotkit/sdk/cmake-build-windows/release/modules/messenger/internal/libvs-messenger-internal.dll DistributionKit/lib
  check_error

  echo "=== Copy libvs-messenger-crypto.dll "
  cp ${PROJECT_DIR}/ext/virgil-iotkit/sdk/cmake-build-windows/release/modules/messenger/crypto/libvs-messenger-crypto.dll DistributionKit/lib
  check_error

  echo "=== Copy openssl libraries"
  cp ${SCRIPT_FOLDER}/../pkgs/win/dll/* DistributionKit/lib
  cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libssl-10.dll DistributionKit/lib
  check_error
  
  echo "=== Add custom env variables"
  sed -i 's/start/SET VS_CURL_CA_BUNDLE=%BASE_DIR%\/ca\/curl-ca-bundle-win.crt\nstart/g' DistributionKit/virgil-messenger.bat
  check_error

  echo "=== Copy libcrypto-10.dll"
  cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libcrypto-10.dll DistributionKit/lib
  check_error
    
  echo "=== Copy libcurl-4.dll"
  cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libcurl-4.dll DistributionKit/lib
  check_error
  
  echo "=== Copy libgcc_s_sjlj-1.dll"
  cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libgcc_s_sjlj-1.dll DistributionKit/lib
  check_error  
  
  echo "=== Copy libcrypto-10.dll"
  cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libcrypto-10.dll DistributionKit/lib
  check_error  
  
  echo "=== Copy libssl-10.dll"
  cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libssl-10.dll DistributionKit/lib
  check_error  
  
  echo "=== Copy libssh2-1.dll"
  cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libssh2-1.dll DistributionKit/lib
  check_error  
  
  echo "=== Copy libidn2-0.dll"
  cp /usr/i686-w64-mingw32/sys-root/mingw/bin/libidn2-0.dll DistributionKit/lib
  check_error  
  
  echo "=== Copy zlib1.dll"
  cp /usr/i686-w64-mingw32/sys-root/mingw/bin/zlib1.dll DistributionKit/lib
  check_error  
  
  echo "=== Copy certs "
  mkdir -p DistributionKit/ca
  check_error
  cp ${PROJECT_DIR}/src/qml/resources/ca/curl-ca-bundle-win.crt DistributionKit/ca
  check_error
  unix2dos DistributionKit/ca/curl-ca-bundle-win.crt
  check_error  
  
popd  

