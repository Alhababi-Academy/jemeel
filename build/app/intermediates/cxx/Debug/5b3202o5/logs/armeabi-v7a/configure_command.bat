@echo off
"C:\\Users\\zeyad\\AppData\\Local\\Android\\Sdk\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HC:\\src\\flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=23" ^
  "-DANDROID_PLATFORM=android-23" ^
  "-DANDROID_ABI=armeabi-v7a" ^
  "-DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a" ^
  "-DANDROID_NDK=C:\\Users\\zeyad\\AppData\\Local\\Android\\Sdk\\ndk\\21.3.6528147" ^
  "-DCMAKE_ANDROID_NDK=C:\\Users\\zeyad\\AppData\\Local\\Android\\Sdk\\ndk\\21.3.6528147" ^
  "-DCMAKE_TOOLCHAIN_FILE=C:\\Users\\zeyad\\AppData\\Local\\Android\\Sdk\\ndk\\21.3.6528147\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=C:\\Users\\zeyad\\AppData\\Local\\Android\\Sdk\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=D:\\Programming\\Flutter\\jemeel\\build\\app\\intermediates\\cxx\\Debug\\5b3202o5\\obj\\armeabi-v7a" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=D:\\Programming\\Flutter\\jemeel\\build\\app\\intermediates\\cxx\\Debug\\5b3202o5\\obj\\armeabi-v7a" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BD:\\Programming\\Flutter\\jemeel\\android\\app\\.cxx\\Debug\\5b3202o5\\armeabi-v7a" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
