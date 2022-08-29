export NDK=/home/sandy/android-ndk-r10d
export ANDROID_ROOT=$NDK/platforms/android-14/arch-arm
export ANDROID_BIN=$NDK/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86_64/bin
export PREFIX=/home/sandy/ffmpeg_x264_fdkaac/out/fdkaac
 
export CFLAGS="-DANDROID -fPIC -ffunction-sections -funwind-tables -fstack-protector -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300"
 
export LDFLAGS="-Wl,--fix-cortex-a8"
export CC="arm-linux-androideabi-gcc --sysroot=$ANDROID_ROOT"
export CXX="arm-linux-androideabi-g++ --sysroot=$ANDROID_ROOT"
 
export PATH=$ANDROID_BIN:$PATH
 
cd ../fdk-aac-0.1.5
./configure --host=arm-linux-androideabi  --with-sysroot="$ANDROID_ROOT" --enable-static --disable-shared --prefix=$PREFIX
make clean
make -j4
make install


