export NDK=/home/sandy/android-ndk-r10d
export PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.8/prebuilt
export PLATFORM=$NDK/platforms/android-14/arch-arm
export PREFIX=/home/sandy/ffmpeg_x264_fdkaac/out/x264
cd ../x264
./configure --prefix=$PREFIX \
--enable-static \
--disable-shared \
--enable-pic \
--disable-asm \
--disable-cli \
--host=arm-linux \
--cross-prefix=$PREBUILT/linux-x86_64/bin/arm-linux-androideabi- \
--sysroot=$PLATFORM
make
make install


