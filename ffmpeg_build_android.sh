#!/bin/bash

export API=21
# NDK的路径，根据自己的安装位置进行设置
export NDK=/Users/kaven/Library/Android/sdk/ndk-bundle
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64 # 这里找到对应得文件

function build_android(){
    echo "Compiling libx264 for $CPU"
    ./configure \
    --prefix=$PREFIX \
    --enable-pic \
    --enable-static \
    --disable-shared \
    --disable-cli \
    --disable-opencl \
    --disable-asm \
    \
    --target=android \
    --host=$HOST \
    --cross-prefix=$TOOLCHAIN/bin/$HOST- \
    --with-sysroot=$SYSROOT \
    --extra-cflags="-Os -fpic ${EXTRA_CFLAGS}" \
    --extra-ldflags="" \
    ${ADDITIONAL_CONFIGURE_FLAG}

make clean
make -j8
make install
echo "##############The Compilation of libx264 for $CPU is completed##############"
}

# armv8-a  
CPU=arm64-v8a
HOST=aarch64-linux-android
PREFIX=$(pwd)/lib/android/$CPU
OPTIMIZE_CFLAGS="-march=armv8-a -D__ANDROID__ -D__ARM_ARCH_8__ -D__ARM_ARCH_8A__"

export SYSROOT=$NDK/platforms/android-$API/arch-arm64
export AS=$TOOLCHAIN/bin/$HOST-as
export AR=$TOOLCHAIN/bin/$HOST-ar
export NM=$TOOLCHAIN/bin/$HOST-nm
export STRIP=$TOOLCHAIN/bin/$HOST-strip
export RANLIB=$TOOLCHAIN/bin/$HOST-ranlib
export LD=$TOOLCHAIN/bin/$HOST-ld
export CC=$TOOLCHAIN/bin/$HOST$API-clang
export CXX=$TOOLCHAIN/bin/$HOST$API-clang++
build_android

#armv7-a  
CPU=armv7-a
HOST=arm-linux-androideabi
PREFIX=$(pwd)/lib/android/$CPU
OPTIMIZE_CFLAGS="-march=armv7-a  -mfloat-abi=softfp -mfpu=neon"

export SYSROOT=$NDK/platforms/android-$API/arch-arm
export AS=$TOOLCHAIN/bin/$HOST-as
export AR=$TOOLCHAIN/bin/$HOST-ar
export NM=$TOOLCHAIN/bin/$HOST-nm
export STRIP=$TOOLCHAIN/bin/$HOST-strip
export RANLIB=$TOOLCHAIN/bin/$HOST-ranlib
export LD=$TOOLCHAIN/bin/$HOST-ld
export CC=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang
export CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang++
build_android

#x86_64 
CPU=x86_64
HOST=x86_64-linux-android
PREFIX=$(pwd)/lib/android/$CPU
OPTIMIZE_CFLAGS=" "

export AS=$TOOLCHAIN/bin/$HOST-as
export AR=$TOOLCHAIN/bin/$HOST-ar
export NM=$TOOLCHAIN/bin/$HOST-nm
export STRIP=$TOOLCHAIN/bin/$HOST-strip
export RANLIB=$TOOLCHAIN/bin/$HOST-ranlib
export LD=$TOOLCHAIN/bin/$HOST-ld
export CC=$TOOLCHAIN/bin/$HOST$API-clang
export CXX=$TOOLCHAIN/bin/$HOST$API-clang++
build_android

#x86
CPU=x86
HOST=i686-linux-android
PREFIX=$(pwd)/lib/android/$CPU
OPTIMIZE_CFLAGS=" "

export AS=$TOOLCHAIN/bin/$HOST-as
export AR=$TOOLCHAIN/bin/$HOST-ar
export NM=$TOOLCHAIN/bin/$HOST-nm
export STRIP=$TOOLCHAIN/bin/$HOST-strip
export RANLIB=$TOOLCHAIN/bin/$HOST-ranlib
export LD=$TOOLCHAIN/bin/$HOST-ld
export CC=$TOOLCHAIN/bin/$HOST$API-clang
export CXX=$TOOLCHAIN/bin/$HOST$API-clang++
build_android