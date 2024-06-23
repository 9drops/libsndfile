#!/bin/bash

set -e

SDK_VERSION="14.4"
LIBSND_DIR=$(pwd)
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)

ARCHS=("arm64" "x86_64" "armv7" "armv7s")

DEVELOPER=$(xcode-select --print-path)

build() {
    ARCH=$1
    HOST=$2

    export CC="${DEVELOPER}/usr/bin/gcc -arch ${ARCH} -isysroot ${IOS_SDK}"
    export CXX="${DEVELOPER}/usr/bin/g++ -arch ${ARCH} -isysroot ${IOS_SDK}"
    export CPP="${CC} -E"
    export CFLAGS="-arch ${ARCH} -isysroot ${IOS_SDK} -miphoneos-version-min=${SDK_VERSION}"
    export CXXFLAGS="${CFLAGS}"
    export LDFLAGS="${CFLAGS}"
    export PKG_CONFIG_PATH=${LIBSND_DIR}/ios_build/${ARCH}/lib/pkgconfig

    mkdir -p build/${ARCH}
    cd build/${ARCH}

    ${LIBSND_DIR}/configure --host=${HOST} --prefix=${LIBSND_DIR}/ios_build/${ARCH} --disable-shared --enable-static --disable-tests --disable-examples
    make -j4
    make install

    cd ../..
}

for ARCH in "${ARCHS[@]}"; do
    if [ "$ARCH" == "x86_64" ]; then
        build "x86_64" "x86_64-apple-darwin"
    elif [ "$ARCH" == "arm64" ]; then
        build "arm64" "aarch64-apple-darwin"
    elif [ "$ARCH" == "armv7" ]; then
        build "armv7" "arm-apple-darwin"
    elif [ "$ARCH" == "armv7s" ]; then
        build "armv7s" "arm-apple-darwin"
    fi
done

# Create a universal library
mkdir -p ios_build/universal/lib
lipo -create -output ios_build/universal/lib/libsndfile.a \
    ios_build/arm64/lib/libsndfile.a \
    ios_build/armv7/lib/libsndfile.a \
    ios_build/armv7s/lib/libsndfile.a \
    ios_build/x86_64/lib/libsndfile.a

cp -r ios_build/arm64/include ios_build/universal/
