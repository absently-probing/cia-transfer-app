#!/bin/sh

export PREFIX="$(pwd)/libc_types-ios"
export IOS32_BASE="ios32"
export IOS32s_BASE="ios32s"
export IOS64_BASE="ios64"
export SIMULATOR32_BASE="simulator32"
export SIMULATOR64_BASE="simulator64"

export IOS32_PREFIX="$PREFIX/tmp/$IOS32_BASE"
export IOS32s_PREFIX="$PREFIX/tmp/$IOS32s_BASE"
export IOS64_PREFIX="$PREFIX/tmp/$IOS64_BASE"
export SIMULATOR32_PREFIX="$PREFIX/tmp/$SIMULATOR32_BASE"
export SIMULATOR64_PREFIX="$PREFIX/tmp/$SIMULATOR64_BASE"
export XCODEDIR=$(xcode-select -p)

#export CLANG="$(xcodebuild -find clang)"
#export LIBTOOL="$(xcodebuild -find libtool)"

export IOS_SIMULATOR_VERSION_MIN=${IOS_SIMULATOR_VERSION_MIN-"6.0.0"}
export IOS_VERSION_MIN=${IOS_VERSION_MIN-"6.0.0"}

mkdir -p $SIMULATOR32_PREFIX $SIMULATOR64_PREFIX $IOS32_PREFIX $IOS32s_PREFIX $IOS64_PREFIX || exit 1

# Build for the simulator
export BASEDIR="${XCODEDIR}/Platforms/iPhoneSimulator.platform/Developer"
export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
export SDK="${BASEDIR}/SDKs/iPhoneSimulator.sdk"

## i386 simulator
export CFLAGS="-O2 -arch i386 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"
export LDFLAGS="-arch i386 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"

# execute here
clang $CFLAGS $LDFLAGS -dynamiclib src/c_types.c -o $SIMULATOR32_PREFIX/libc_types.dylib
clang $CFLAGS -c src/c_types.c -o $SIMULATOR32_PREFIX/c_types.o
libtool -static $SIMULATOR32_PREFIX/c_types.o -o $SIMULATOR32_PREFIX/libc_types.a

## x86_64 simulator
export CFLAGS="-O2 -arch x86_64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"
export LDFLAGS="-arch x86_64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"

# execute here
clang $CFLAGS -c src/c_types.c -o $SIMULATOR64_PREFIX/c_types.o
libtool -static $SIMULATOR64_PREFIX/c_types.o -o $SIMULATOR64_PREFIX/libc_types.a
clang $CFLAGS $LDFLAGS -dynamiclib src/c_types.c -o $SIMULATOR64_PREFIX/libc_types.dylib

# Build for iOS
export BASEDIR="${XCODEDIR}/Platforms/iPhoneOS.platform/Developer"
export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
export SDK="${BASEDIR}/SDKs/iPhoneOS.sdk"

## 32-bit iOS
export CFLAGS="-fembed-bitcode -O2 -mthumb -arch armv7 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"
export LDFLAGS="-fembed-bitcode -mthumb -arch armv7 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"

# execute here
clang $CFLAGS -c src/c_types.c -o $IOS32_PREFIX/c_types.o
libtool -static $IOS32_PREFIX/c_types.o -o $IOS32_PREFIX/libc_types.a
clang $CFLAGS $LDFLAGS -dynamiclib src/c_types.c -o $IOS32_PREFIX/libc_types.dylib

## 32-bit armv7s iOS
export CFLAGS="-fembed-bitcode -O2 -mthumb -arch armv7s -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"
export LDFLAGS="-fembed-bitcode -mthumb -arch armv7s -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"

# execute here
clang $CFLAGS -c src/c_types.c -o $IOS32s_PREFIX/c_types.o
libtool -static $IOS32s_PREFIX/c_types.o -o $IOS32s_PREFIX/libc_types.a
clang $CFLAGS $LDFLAGS -dynamiclib src/c_types.c -o $IOS32s_PREFIX/libc_types.dylib

## 64-bit iOS
export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN} -fembed-bitcode"
export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN} -fembed-bitcode"

# execute here
clang $CFLAGS -c src/c_types.c -o $IOS64_PREFIX/c_types.o
libtool -static $IOS64_PREFIX/c_types.o -o $IOS64_PREFIX/libc_types.a
clang $CFLAGS $LDFLAGS -dynamiclib src/c_types.c -o $IOS64_PREFIX/libc_types.dylib

mkdir -p -- "$PREFIX/lib"
lipo -create \
  "$SIMULATOR32_PREFIX/libc_types.a" \
  "$SIMULATOR64_PREFIX/libc_types.a" \
  "$IOS32_PREFIX/libc_types.a" \
  "$IOS32s_PREFIX/libc_types.a" \
  "$IOS64_PREFIX/libc_types.a" \
  -output "$PREFIX/lib/libc_types.a"

#mkdir -p -- "$PREFIX/platforms/$SIMULATOR32_BASE/lib"
#mkdir -p -- "$PREFIX/platforms/$SIMULATOR64_BASE/lib"
#mkdir -p -- "$PREFIX/platforms/$IOS32_BASE/lib"
#mkdir -p -- "$PREFIX/platforms/$IOS32s_BASE/lib"
#mkdir -p -- "$PREFIX/platforms/$IOS64_BASE/lib"

#cp "$IOS32_PREFIX/libc_types.dylib" "$PREFIX/platforms/$IOS32_BASE/lib"
#cp "$IOS32s_PREFIX/libc_types.dylib" "$PREFIX/platforms/$IOS32s_BASE/lib"
#cp "$IOS64_PREFIX/libc_types.dylib" "$PREFIX/platforms/$IOS64_BASE/lib"
#cp "$SIMULATOR32_PREFIX/libc_types.dylib" "$PREFIX/platforms/$SIMULATOR32_BASE/lib"
#cp "$SIMULATOR64_PREFIX/libc_types.dylib" "$PREFIX/platforms/$SIMULATOR64_BASE/lib"

lipo -create \
  "$SIMULATOR32_PREFIX/libc_types.dylib" \
  "$SIMULATOR64_PREFIX/libc_types.dylib" \
  "$IOS32_PREFIX/libc_types.dylib" \
  "$IOS32s_PREFIX/libc_types.dylib" \
  "$IOS64_PREFIX/libc_types.dylib" \
  -output "$PREFIX/lib/libc_types.dylib"
install_name_tool -id "@rpath/CTYPES.framework/libc_types.dylib" "$PREFIX/lib/libc_types.dylib"

file -- "$PREFIX/lib/libc_types.a"
rm -rf -- "$PREFIX/tmp"
