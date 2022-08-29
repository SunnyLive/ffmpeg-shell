#!/bin/bash
export NDK=/home/sandy/android-ndk-r10d
SYSROOT=$NDK/platforms/android-14/arch-arm/
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86_64
CPU=arm 
PREFIX=/home/sandy/ffmpeg_x264_fdkaac/out/ffmpeg
ADDI_CFLAGS="-marm"
export outfaac=/home/sandy/ffmpeg_x264_fdkaac/out/fdkaac
export outx264=/home/sandy/ffmpeg_x264_fdkaac/out/x264
 
 
function build_one    
{    
cd ../ffmpeg-3.0.5
./configure \
--enable-nonfree \
--enable-version3 \
--prefix=$PREFIX \
--enable-static \
--enable-cross-compile \
--enable-gpl \
--disable-shared \
--disable-doc \
--disable-ffserver \
--disable-ffprobe \
--disable-devices \
--disable-avdevice \
--disable-encoders \
--disable-decoders \
--disable-protocols \
--disable-muxers \
--disable-demuxers \
--disable-bsfs \
--disable-network \
--enable-libx264 \
--enable-encoder=libx264 \
--enable-libfdk_aac \
--enable-decoder=pcm_alaw \
--enable-encoder=pcm_alaw \
--enable-decoder=pcm_mulaw \
--enable-decoder=pcm_mulaw \
--enable-decoder=h264 \
--enable-encoder=aac \
--enable-decoder=aac \
--enable-protocol=file \
--enable-protocol=rtsp \
--enable-muxer=mp4 \
--enable-muxer=mov \
--enable-demuxer=mp4 \
--enable-demuxer=mov \
--enable-demuxer=flv \
--enable-demuxer=avi \
--enable-bsf=h264_mp4toannexb \
--enable-bsf=aac_adtstoasc \
--cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
--target-os=linux \
--arch=arm \
--sysroot=$SYSROOT \
--extra-cflags="-I$outx264/include -I$outfaac/include -fPIC -DANDROID -D__thumb__ -mthumb -Wfatal-errors -Wno-deprecated -mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=armv7-a" \
--extra-ldflags="-L$outx264/lib -L$outfaac/lib"
$ADDITIONAL_CONFIGURE_FLAG
}
  
build_one
make clean
make -j4
make install







