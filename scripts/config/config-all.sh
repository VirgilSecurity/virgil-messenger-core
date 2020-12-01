# Common
export BUILD_DIR_BASE=${SCRIPT_FOLDER}/..
export QT_INSTALL_DIR_BASE=${SCRIPT_FOLDER}/../prebuilt

export CFG_ANDROID_PLATFORM="android-29"
export CFG_ANDROID_NDK="${ANDROID_NDK:-/opt/Android/Sdk/ndk/21.1.6352462}"
export ANDOID_APP_ID="com.virgilsecurity.qtmessenger"


if [ -z "${QTDIR}" ]; then
    CFG_QT_SDK_DIR="${QT_SDK_ROOT:-/opt/Qt/5.15.0}"
else    
    echo "=== ENV QTDIR found [${QTDIR}]"
    CFG_QT_SDK_DIR="$(dirname ${QTDIR})"
    echo "=== Set CFG_QT_SDK_DIR = ${CFG_QT_SDK_DIR}"
fi

export CFG_QT_SDK_DIR
