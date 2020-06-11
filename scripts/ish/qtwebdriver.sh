#!/bin/bash

build_qtwebdriver() {
   local QMAKE_BIN="${1}"
   rm -rf ${PROJECT_DIR}/qtwebdriver/build
   mkdir -p ${PROJECT_DIR}/qtwebdriver/build
   check_error
   pushd ${PROJECT_DIR}/qtwebdriver/build
     ${QMAKE_BIN} ..
     check_error
     make
     check_error

     mkdir -p ${BUILD_DIR}/release/installed/usr/local/lib || true
     mkdir -p ${BUILD_DIR}/release/installed/usr/local/include/qtwebdriver/src || true
     cp -rf ${PROJECT_DIR}/qtwebdriver/inc/* ${BUILD_DIR}/release/installed/usr/local/include/qtwebdriver/
     cp -rf ${PROJECT_DIR}/qtwebdriver/src/* ${BUILD_DIR}/release/installed/usr/local/include/qtwebdriver/src/
     cp -f bin/* ${BUILD_DIR}/release/installed/usr/local/lib
     check_error     
     
     if [ "${BUILD_WITH_DEBUG}" == "true" ]; then
       mkdir -p ${BUILD_DIR}/debug/installed/usr/local/lib || true     
       mkdir -p ${BUILD_DIR}/debug/installed/usr/local/include/qtwebdriver/src || true     
       cp -f bin/* ${BUILD_DIR}/debug/installed/usr/local/lib     
       cp -rf ${PROJECT_DIR}/qtwebdriver/inc/* ${BUILD_DIR}/debug/installed/usr/local/include/qtwebdriver/
       cp -rf ${PROJECT_DIR}/qtwebdriver/src/* ${BUILD_DIR}/debug/installed/usr/local/include/qtwebdriver/src/            
       check_error
     fi
   popd
   
   
}
