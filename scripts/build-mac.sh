#!/usr/bin/env bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
. ${SCRIPT_FOLDER}/ish/error.ish

PROJECT_DIR="$1"
QT_SDK_DIR="${2:-/Users/eponomarenko/Qt/5.12.6}"

[ "${PROJECT_DIR}" == "" ] && exit 1

APPLICATION_NAME=virgil-messenger
BUILD_TYPE=release
PLATFORM=mac
TOOL_NAME=qmake
BUILD_DIR=${PROJECT_DIR}/${BUILD_TYPE}/${TOOL_NAME}.${PLATFORM}/
QMAKE_BIN=${QT_SDK_DIR}/clang_64/bin/qmake
MACDEPLOYQT_BIN=${QT_SDK_DIR}/clang_64/bin/macdeployqt

#***************************************************************************************

echo
echo "===================================="
echo "=== ${PLATFORM} ${APPLICATION_NAME} build"
echo "=== Build type : ${BUILD_TYPE}"
echo "=== Tool name : ${TOOL_NAME}"
echo "=== Output directory : ${BUILD_DIR}"
echo "===================================="
echo

echo "=== Building library"
echo

pushd ${PROJECT_DIR}
     echo
     echo "=== Make IoTKit for Qt"
     echo
     ext/virgil-iotkit/sdk/scripts/build-for-qt.sh macos
     check_error

     echo
     echo "=== Make QXMPP"
     echo

     export QT_INSTALL_DIR_BASE=${PROJECT_DIR}/ext/prebuilt
     export QT_BUILD_DIR_SUFFIX=macos

     scripts/build-qxmpp.sh ${QT_SDK_DIR}/clang_64 \
          -DQt5_DIR=${QT_SDK_DIR}/clang_64/lib/cmake/Qt5/ \
          -DQt5Core_DIR=${QT_SDK_DIR}/clang_64/lib/cmake/Qt5Core/ \
          -DQt5Network_DIR=${QT_SDK_DIR}/clang_64/lib/cmake/Qt5Network/ \
          -DQt5Xml_DIR=${QT_SDK_DIR}/clang_64/lib/cmake/Qt5Xml

     check_error
popd

echo "=== Prepare directory"
echo
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
pushd ${BUILD_DIR}

  echo
  echo "=== Make application bundle"

  # Add version to the executable
  BUILD_NUMBER="${BUILD_NUMBER:-0}"
  if [ -f "${PROJECT_DIR}/VERSION_MESSENGER" ]; then
     VERSION="$(cat ${PROJECT_DIR}/VERSION_MESSENGER | tr -d '\n').${BUILD_NUMBER}"
  fi
  echo "=== VERSION=${VERSION}"
  echo

  ${QMAKE_BIN} -config ${BUILD_TYPE} ${PROJECT_DIR} DEFINES+="VERSION=\"${VERSION}\""
  check_error
  make
  check_error

  echo
  echo "=== Deploy MAC application"
  echo

  ${MACDEPLOYQT_BIN} ${APPLICATION_NAME}.app -qmldir=${PROJECT_DIR}/src/qml -dmg -always-overwrite
  check_error
  echo "MAC .dmg file: ${BUILD_DIR}${APPLICATION_NAME}.dmg"
popd
