#!/bin/bash
export API=21
# NDK的路径，根据自己的安装位置进行设置
export NDK=/Users/kaven/Library/Android/sdk/ndk-bundle
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64 # 这里找到对应得文件
export SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot

CFLAGS=" "
export CXXFLAGS=$CFLAGS
export CFLAGS=$CFLAGS

function build_android(){
    echo "Compiling fdk-acc for $CPU"
    ./configure \
    --prefix=$PREFIX \
    --target=android \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --with-sysroot=$SYSROOT \

make clean
make -j4
make install
echo "The Compilation of fdk-aac for $CPU is completed"
}

#armv8-a  
CPU=arm64
HOST=aarch64-linux-android
PREFIX=$(pwd)/lib/android/$CPU

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
CPU=armv7
HOST=arm-linux-androideabi
PREFIX=$(pwd)/lib/android/$CPU

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

export AS=$TOOLCHAIN/bin/$HOST-as
export AR=$TOOLCHAIN/bin/$HOST-ar
export NM=$TOOLCHAIN/bin/$HOST-nm
export STRIP=$TOOLCHAIN/bin/$HOST-strip
export RANLIB=$TOOLCHAIN/bin/$HOST-ranlib
export LD=$TOOLCHAIN/bin/$HOST-ld
export CC=$TOOLCHAIN/bin/$HOST$API-clang
export CXX=$TOOLCHAIN/bin/$HOST$API-clang++
build_android