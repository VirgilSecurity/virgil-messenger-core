#!/bin/bash

build_qtwebdriver() {
   local QMAKE_BIN="${1}"
   local DESTDIR_BIN="${BUILD_DIR}/release/installed/usr/local"
   rm -rf ${PROJECT_DIR}/qtwebdriver/build
   mkdir -p ${PROJECT_DIR}/qtwebdriver/build
   check_error
   pushd ${PROJECT_DIR}/qtwebdriver/build
     ${QMAKE_BIN} ..
     check_error
     make
     check_error
     mkdir -p ${DESTDIR_BIN}/lib || true
     cp -f bin/* ${DESTDIR_BIN}/lib
     check_error
     mkdir -p ${DESTDIR_BIN}/include/qtwebdriver || true
     cp -rf ${PROJECT_DIR}/qtwebdriver/inc/* ${DESTDIR_BIN}/include/qtwebdriver/
     check_error     
   popd
   
   
}
