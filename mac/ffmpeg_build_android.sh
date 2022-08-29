#!/bin/bash

#这里修改的是最低支持的android sdk版本（r20版本ndk中armv8a、x86_64最低支持21，armv7a、x86最低支持16）

# NDK的路径，根据自己的安装位置进行设置
export NDK=/Users/kaven/Library/Android/sdk/ndk-bundle
export SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64 # 这里找到对应得文件


set -e
set -x

function build_android
{
#相当于Android中Log.i
echo "Compiling FFmpeg for $CPU"

./configure \
    --prefix=$PREFIX \
    --target-os=android \
    --arch=$ARCH \
    --cpu=$CPU \
    --cc=$CC \
    --cxx=$CXX \
    --enable-cross-compile \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT \
    \
    --ar=$AR \
    --ranlib=$RANLIB \
    --strip=$STRIP \
    --nm=$NM \
    \
    --enable-neon \
    --enable-pic \
    --enable-gpl \
    --enable-version3 \
    --enable-nonfree \
    \
    --disable-shared \
    --enable-static \
    \
    --disable-encoders \
    $CONFIGURE_FLAGS \
    --enable-encoder=aac \
    --enable-encoder=mjpeg \
    \
    --disable-decoders \
    --enable-decoder=aac \
    --enable-decoder=aac_latm \
    --enable-decoder=h264 \
    --enable-decoder=hevc \
    --enable-decoder=mjpeg \
    \
    --enable-jni \
    --enable-mediacodec \
    --enable-hwaccel=h264_mediacodec \
    --enable-decoder=h264_mediacodec \
    --enable-decoder=hevc_mediacodec \
    --enable-decoder=mpeg4_mediacodec \
    \
    --enable-muxers \
    --enable-muxer=h264 \
    --enable-muxer=hevc \
    --enable-muxer=mjpeg \
    \
    --disable-demuxers \
    --enable-demuxer=h264 \
    --enable-demuxer=hevc \
    --enable-demuxer=mjpeg \
    \
    --disable-parsers \
    --enable-parser=h264 \
    \
    --disable-bsfs \
    --enable-bsf=h264_metadata \
    --enable-bsf=h264_mp4toannexb \
    --enable-bsf=hevc_metadata \
    --enable-bsf=hevc_mp4toannexb \
    --enable-bsf=aac_adtstoasc \
    \
    --disable-protocols \
    --enable-protocol='file' \
    \
    --disable-filters \
    \
    --disable-doc \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-txtpages \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-avdevice \
    --disable-postproc \
    --disable-indevs \
    --disable-outdevs \
    --disable-devices \
    --disable-debug \
    --disable-asm \
    --disable-symver \
    \
    --extra-cflags="$CFLAGS" \
    --extra-ldflags="$LDFLAGS" \
    $ADDITIONAL_CONFIGURE_FLAG

make clean
make
make install
echo "The Compilation of FFmpeg for $CPU is completed"

}

#####-----把多个静态库合并成一个动态库-----------
function build_so(){

    $TOOLCHAIN/bin/$HOST-ld \
    -rpath-link=$PLATFORM/usr/lib \
    -L$PLATFORM/usr/lib \
    -soname libffmpeg.so -shared -Bsymbolic --whole-archive -o \
    $PREFIX/lib/libffmpeg.so \
    $PREFIX/lib/libavcodec.a \
    $PREFIX/lib/libavfilter.a \
    $PREFIX/lib/libswresample.a \
    $PREFIX/lib/libavformat.a \
    $PREFIX/lib/libavutil.a \
    $PREFIX/lib/libswscale.a \
    $X264_LIB/libx264.a \
    $AAC_LIB/libfdk-aac.a \
    -lstdc++ -fPIC -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
    $TOOLCHAIN/lib/gcc/$HOST/4.9.x/libgcc.a

}

# \
    # --enable-jni \
    # --enable-mediacodec \
    # --enable-hwaccel=h264_mediacodec \
    # --enable-decoder=h264_mediacodec \
    # --enable-decoder=hevc_mediacodec \
    # --enable-decoder=mpeg4_mediacodec \
#--disable-everything
# export PKG_CONFIG_PATH=$(pwd)/x264/lib/android/$ARCH/pkgconfig:$PKG_CONFIG_PATH
# export PKG_CONFIG_PATH=$(pwd)/fdk-aac/lib/android/$ARCH/pkgconfig:$PKG_CONFIG_PATH

#是否开启编译带x264的库，里面填任何值 都是开启
X264=""
aac=""

CONFIGURE_FLAGS=""
if [ "$X264" ]
then
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libx264 --enable-encoder=libx264"
fi

if [ "$aac" ]
then
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-libfdk_aac --enable-encoder=libfdk_aac"
fi

#armv8-a ====================================================================
API=21
ARCH=arm64
CPU=armv8-a
HOST=aarch64-linux-android
PREFIX=$(pwd)/lib/android/$ARCH
PLATFORM=$NDK_ROOT/platforms/android-$API/arch-$ARCH

CC=$TOOLCHAIN/bin/aarch64-linux-android$API-clang
CXX=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++
SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-
OPTIMIZE_CFLAGS="-march=$CPU"
CFLAGS="-Os -fpic $OPTIMIZE_CFLAGS"
LDFLAGS="$ADDI_LDFLAGS"

export AS=$TOOLCHAIN/bin/$HOST-as
export AR=$TOOLCHAIN/bin/$HOST-ar
export NM=$TOOLCHAIN/bin/$HOST-nm
export STRIP=$TOOLCHAIN/bin/$HOST-strip

#编译带x264 aac的库
if [ "$X264" -o "$aac" ]
then
PREFIX=$(pwd)/lib/android_x264_aac/$ARCH
CFLAGS="$CFLAGS -I${SYSROOT}/usr/include"
LDFLAGS="$LDFLAGS -lm"
fi

if [ "$X264" ]
then
X264_INCLUDE=$(pwd)/x264/lib/android/$ARCH/include
X264_LIB=$(pwd)/x264/lib/android/$ARCH/lib
CFLAGS="$CFLAGS -I${X264_INCLUDE}"
LDFLAGS="$LDFLAGS -L${X264_LIB} -lx264"
fi

if [ "$aac" ]
then
AAC_INCLUDE=$(pwd)/fdk-aac/lib/android/$ARCH/include
AAC_LIB=$(pwd)/fdk-aac/lib/android/$ARCH/lib
CFLAGS="$CFLAGS -I${AAC_INCLUDE}"
LDFLAGS="$LDFLAGS -L${AAC_LIB} -lfdk-aac"
fi
build_android


#armv7-a ====================================================================
API=17
ARCH=arm
CPU=armv7-a
KKK=armv7
HOST=arm-linux-androideabi
PREFIX=$(pwd)/lib/android/$KKK

CC=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang
CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang++
SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
CROSS_PREFIX=$TOOLCHAIN/bin/arm-linux-androideabi-
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU"
CFLAGS="-Os -fpic $OPTIMIZE_CFLAGS"
LDFLAGS="$ADDI_LDFLAGS"

export AS=$TOOLCHAIN/bin/$HOST-as
export AR=$TOOLCHAIN/bin/$HOST-ar
export NM=$TOOLCHAIN/bin/$HOST-nm
export STRIP=$TOOLCHAIN/bin/$HOST-strip

#编译带x264 aac的库
if [ "$X264" -o "$aac" ]
then
PREFIX=$(pwd)/lib/android_x264_aac/$KKK
CFLAGS="$CFLAGS -I${SYSROOT}/usr/include"
LDFLAGS="$LDFLAGS -lm"
fi

if [ "$X264" ]
then
X264_INCLUDE=$(pwd)/x264/lib/android/$KKK/include
X264_LIB=$(pwd)/x264/lib/android/$KKK/lib
CFLAGS="$CFLAGS -I${X264_INCLUDE}"
LDFLAGS="$LDFLAGS -L${X264_LIB} -lx264"
fi

if [ "$aac" ]
then
AAC_INCLUDE=$(pwd)/fdk-aac/lib/android/$KKK/include
AAC_LIB=$(pwd)/fdk-aac/lib/android/$KKK/lib
CFLAGS="$CFLAGS -I${AAC_INCLUDE}"
LDFLAGS="$LDFLAGS -L${AAC_LIB} -lfdk-aac"
fi
build_android

#x86 ====================================================================
API=17
ARCH=x86
CPU=x86
HOST=i686-linux-android
PREFIX=$(pwd)/lib/android/$CPU

CC=$TOOLCHAIN/bin/i686-linux-android$API-clang
CXX=$TOOLCHAIN/bin/i686-linux-android$API-clang++
SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
CROSS_PREFIX=$TOOLCHAIN/bin/i686-linux-android-
OPTIMIZE_CFLAGS="-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32"
CFLAGS="-Os -fpic $OPTIMIZE_CFLAGS"
LDFLAGS="$ADDI_LDFLAGS"

export AS=$TOOLCHAIN/bin/$HOST-as
export AR=$TOOLCHAIN/bin/$HOST-ar
export NM=$TOOLCHAIN/bin/$HOST-nm
export STRIP=$TOOLCHAIN/bin/$HOST-strip

#编译带x264 aac的库
if [ "$X264" -o "$aac" ]
then
PREFIX=$(pwd)/lib/android_x264_aac/$ARCH
CFLAGS="$CFLAGS -I${SYSROOT}/usr/include"
LDFLAGS="$LDFLAGS -lm"
fi

if [ "$X264" ]
then
X264_INCLUDE=$(pwd)/x264/lib/android/$ARCH/include
X264_LIB=$(pwd)/x264/lib/android/$ARCH/lib
CFLAGS="$CFLAGS -I${X264_INCLUDE}"
LDFLAGS="$LDFLAGS -L${X264_LIB} -lx264"
fi

if [ "$aac" ]
then
AAC_INCLUDE=$(pwd)/fdk-aac/lib/android/$ARCH/include
AAC_LIB=$(pwd)/fdk-aac/lib/android/$ARCH/lib
CFLAGS="$CFLAGS -I${AAC_INCLUDE}"
LDFLAGS="$LDFLAGS -L${AAC_LIB} -lfdk-aac"
fi
build_android

#x86_64 ====================================================================
API=21
ARCH=x86_64
CPU=x86-64
HOST=x86_64-linux-android
PREFIX=$(pwd)/lib/android/$ARCH

CC=$TOOLCHAIN/bin/x86_64-linux-android$API-clang
CXX=$TOOLCHAIN/bin/x86_64-linux-android$API-clang++
SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
CROSS_PREFIX=$TOOLCHAIN/bin/x86_64-linux-android-
OPTIMIZE_CFLAGS="-march=$CPU -msse4.2 -mpopcnt -m64 -mtune=intel"
CFLAGS="-Os -fpic $OPTIMIZE_CFLAGS"
LDFLAGS="$ADDI_LDFLAGS"

export AS=$TOOLCHAIN/bin/$HOST-as
export AR=$TOOLCHAIN/bin/$HOST-ar
export NM=$TOOLCHAIN/bin/$HOST-nm
export STRIP=$TOOLCHAIN/bin/$HOST-strip

#编译带x264 aac的库
if [ "$X264" -o "$aac" ]
then
PREFIX=$(pwd)/lib/android_x264_aac/$ARCH
CFLAGS="$CFLAGS -I${SYSROOT}/usr/include"
LDFLAGS="$LDFLAGS -lm"
fi

if [ "$X264" ]
then
X264_INCLUDE=$(pwd)/x264/lib/android/$ARCH/include
X264_LIB=$(pwd)/x264/lib/android/$ARCH/lib
CFLAGS="$CFLAGS -I${X264_INCLUDE}"
LDFLAGS="$LDFLAGS -L${X264_LIB} -lx264"
fi

if [ "$aac" ]
then
AAC_INCLUDE=$(pwd)/fdk-aac/lib/android/$ARCH/include
AAC_LIB=$(pwd)/fdk-aac/lib/android/$ARCH/lib
CFLAGS="$CFLAGS -I${AAC_INCLUDE}"
LDFLAGS="$LDFLAGS -L${AAC_LIB} -lfdk-aac"
fi
build_android


# function build_x264_aac
# {
# #相当于Android中Log.i
# echo "Compiling FFmpeg for $CPU"

# ./configure \
#     --prefix=$PREFIX \
#     --target-os=android \
#     --arch=$ARCH \
#     --cpu=$CPU \
#     --enable-cross-compile \
#     --cross-prefix=$CROSS_PREFIX \
#     --sysroot=$SYSROOT \
#     --cc=$CC \
#     --cxx=$CXX \
#     \
#     --ar=$AR \
#     --ranlib=$RANLIB \
#     --strip=$STRIP \
#     --nm=$NM \
#     \
#     --enable-neon \
#     --enable-pic \
#     --enable-gpl \
#     --enable-version3 \
#     --enable-nonfree \
#     --enable-small \
#     \
#     --disable-shared \
#     --enable-static \
#     \
#     --disable-everything \
#     \
#     --enable-libx264 \
#     --enable-encoder=libx264 \
#     --enable-libfdk_aac \
#     --enable-encoder=libfdk_aac \
#     \
#     --enable-decoder=aac \
#     --enable-decoder=aac_latm \
#     --enable-decoder=h264 \
#     --enable-decoder=hevc \
#     --enable-decoder=mjpeg \
#     \
#     --enable-muxer=h264 \
#     --enable-muxer=mjpeg \
#     \
#     --enable-demuxer=h264 \
#     --enable-demuxer=hevc \
#     --enable-demuxer=mjpeg \
#     \
#     --enable-parser=h264 \
#     --enable-bsf=h264_mp4toannexb \
#     \
#     --enable-protocol='file' \
#     \
#     --disable-doc \
#     --disable-htmlpages \
#     --disable-manpages \
#     --disable-podpages \
#     --disable-txtpages \
#     --disable-ffmpeg \
#     --disable-ffplay \
#     --disable-ffprobe \
#     --enable-avdevice \
#     --disable-postproc \
#     --disable-indevs \
#     --disable-outdevs \
#     --disable-devices \
#     --disable-debug \
#     --disable-logging \
#     --disable-asm \
#     --disable-symver \
#     \
#     --extra-cflags="-I${X264_INCLUDE} -I${AAC_INCLUDE} -I${SYSROOT}/usr/include -Os -fpic ${OPTIMIZE_CFLAGS}" \
#     --extra-ldflags="-lm -L${X264_LIB} -L${AAC_LIB} -lx264 -lfdk-aac ${ADDI_LDFLAGS}" \
#     $ADDITIONAL_CONFIGURE_FLAG

# make clean
# make -j8
# make install
# echo "The Compilation of FFmpeg for $CPU is completed"
# }


# # armv8-a
# ARCH=arm64
# CPU=armv8-a
# HOST=aarch64-linux-android

# export AS=$TOOLCHAIN/bin/$HOST-as
# export AR=$TOOLCHAIN/bin/$HOST-ar
# export NM=$TOOLCHAIN/bin/$HOST-nm
# export STRIP=$TOOLCHAIN/bin/$HOST-strip
# #export RANLIB=$TOOLCHAIN/bin/$HOST-ranlib
# CC=$TOOLCHAIN/bin/aarch64-linux-android$API-clang
# CXX=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++
# CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-
# PREFIX=$(pwd)/lib/android_x264_acc/$CPU
# OPTIMIZE_CFLAGS="-march=$CPU"

# X264_INCLUDE=$(pwd)/x264/lib/android/arm64-v8a/include
# X264_LIB=$(pwd)/x264/lib/android/arm64-v8a/lib

# AAC_INCLUDE=$(pwd)/fdk-aac/lib/android/arm64-v8a/include
# AAC_LIB=$(pwd)/fdk-aac/lib/android/arm64-v8a/lib
# build_x264_aac
# # export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$(pwd)/x264/android/arm64-v8a/pkgconfig


# #armv7-a
# ARCH=arm
# CPU=armv7-a
# HOST=arm-linux-androideabi

# export AS=$TOOLCHAIN/bin/$HOST-as
# export AR=$TOOLCHAIN/bin/$HOST-ar
# export NM=$TOOLCHAIN/bin/$HOST-nm
# export STRIP=$TOOLCHAIN/bin/$HOST-strip
# #export RANLIB=$TOOLCHAIN/bin/$HOST-ranlib

# CC=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang
# CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang++
# SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
# CROSS_PREFIX=$TOOLCHAIN/bin/arm-linux-androideabi-
# PREFIX=$(pwd)/lib/android_x264_acc/$CPU
# OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU"

# X264_INCLUDE=$(pwd)/x264/lib/android/armv7-a/include
# X264_LIB=$(pwd)/x264/lib/android/armv7-a/lib

# AAC_INCLUDE=$(pwd)/fdk-aac/lib/android/armv7-a/include
# AAC_LIB=$(pwd)/fdk-aac/lib/android/armv7-a/lib
# build_x264_aac

# #x86
# ARCH=x86
# CPU=x86
# HOST=i686-linux-android

# export AS=$TOOLCHAIN/bin/$HOST-as
# export AR=$TOOLCHAIN/bin/$HOST-ar
# export NM=$TOOLCHAIN/bin/$HOST-nm
# export STRIP=$TOOLCHAIN/bin/$HOST-strip
# #export RANLIB=$TOOLCHAIN/bin/$HOST-ranlib

# CC=$TOOLCHAIN/bin/i686-linux-android$API-clang
# CXX=$TOOLCHAIN/bin/i686-linux-android$API-clang++
# SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
# CROSS_PREFIX=$TOOLCHAIN/bin/i686-linux-android-
# PREFIX=$(pwd)/lib/android_x264_acc/$CPU
# OPTIMIZE_CFLAGS="-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32"

# X264_INCLUDE=$(pwd)/x264/lib/android/x86/include
# X264_LIB=$(pwd)/x264/lib/android/x86/lib

# AAC_INCLUDE=$(pwd)/fdk-aac/lib/android/x86/include
# AAC_LIB=$(pwd)/fdk-aac/lib/android/x86/lib
# build_x264_aac

# #x86_64
# ARCH=x86_64
# CPU=x86-64
# HOST=x86_64-linux-android

# export AS=$TOOLCHAIN/bin/$HOST-as
# export AR=$TOOLCHAIN/bin/$HOST-ar
# export NM=$TOOLCHAIN/bin/$HOST-nm
# export STRIP=$TOOLCHAIN/bin/$HOST-strip
# #export RANLIB=$TOOLCHAIN/bin/$HOST-ranlib

# CC=$TOOLCHAIN/bin/x86_64-linux-android$API-clang
# CXX=$TOOLCHAIN/bin/x86_64-linux-android$API-clang++
# SYSROOT=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
# CROSS_PREFIX=$TOOLCHAIN/bin/x86_64-linux-android-
# PREFIX=$(pwd)/lib/android_x264_acc/$CPU
# OPTIMIZE_CFLAGS="-march=$CPU -msse4.2 -mpopcnt -m64 -mtune=intel"

# X264_INCLUDE=$(pwd)/x264/lib/android/x86_64/include
# X264_LIB=$(pwd)/x264/lib/android/x86_64/lib

# AAC_INCLUDE=$(pwd)/fdk-aac/lib/android/x86_64/include
# AAC_LIB=$(pwd)/fdk-aac/lib/android/x86_64/lib
# build_x264_aac

