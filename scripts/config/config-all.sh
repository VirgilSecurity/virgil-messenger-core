# Common
export CFG_CLEAN="on"
export CFG_BUILD_BREAKPAD="on"
export CFG_BUILD_QXMPP="on"
export CFG_BUILD_IOTKIT="on"
export CFG_BUILD_VS_SDK_CPP="on"
export CFG_BUILD_VS_CRYPTO="on"
export CFG_QT_SDK_DIR="${QT_SDK_ROOT:-/opt/Qt/5.15.0}"

# macOS
export CFG_BUILD_SPARKLE="on"

# iOS
export CFG_BUILD_FOR_IOS_DEVICES="on"
export CFG_BUILD_FOR_IOS_SIMULATOR="on"
export CFG_BUILD_IOS_CURL_SSL="on"

# Android
export CFG_BUILD_ANDROID_CURL_SSL="on"
export CFG_ANDROID_PLATFORM="android-24"
export CFG_ANDROID_NDK="${ANDROID_NDK_ROOT:-/opt/Android/Sdk/ndk/21.1.6352462}"


