#!/usr/bin/env bash

SCRIPT_FOLDER="$( cd "$( dirname "$0" )" && pwd )"
source ${SCRIPT_FOLDER}/ish/common.ish

#
#   Global variables
#
PLATFORM=linux-g++
TOOL_NAME=qmake
BUILD_DIR=${PROJECT_DIR}/${BUILD_TYPE}/${TOOL_NAME}.${PLATFORM}/
LINUX_QMAKE="${QT_SDK_DIR}/gcc_64/bin/qmake"

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
     virgil-iotkit/sdk/scripts/build-for-qt.sh linux
     check_error

     export QT_BUILD_DIR_SUFFIX=linux

     echo
     echo "=== Make QXMPP"
     echo
      ${SCRIPT_FOLDER}/build-qxmpp.sh ${QT_SDK_DIR}/gcc_64 \
          -DQt5_DIR=${QT_SDK_DIR}/gcc_64/lib/cmake/Qt5/ \
          -DQt5Core_DIR=${QT_SDK_DIR}/gcc_64/lib/cmake/Qt5Core/ \
          -DQt5Network_DIR=${QT_SDK_DIR}/gcc_64/lib/cmake/Qt5Network/ \
          -DQt5Xml_DIR=${QT_SDK_DIR}/gcc_64/lib/cmake/Qt5Xml
     check_error
popd
