#!/bin/bash
set -xe

# Fetch sources
mkdir -p /usr/local/src
cd /usr/local/src
git clone --depth 1 https://github.com/l-smash/l-smash
hg clone https://bitbucket.org/multicoreware/x265
git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
#git clone --depth 1 git://source.ffmpeg.org/ffmpeg
git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git
git clone --depth 1 https://gitlab.com/mulx/aacgain.git
git clone https://github.com/facebook/transform360.git 

# Build Transform360
cd /usr/local/src/transform360/
git checkout 0f28a31160bf109be62283c1957488996ebef289
cd Transform360/
cmake ./
make -j $(nproc)
make install

# Add transform360 cc to FFmpeg
ls /usr/local/src/
cp vf_transform360.c /usr/local/src/FFmpeg/libavfilter/
cd /usr/local/src/FFmpeg/

# Register Transform360 in libavfilter (insert before AVBENCH)
sed -i '/extern AVFilter ff_af_abench;/i extern AVFilter ff_vf_transform360;' libavfilter/allfilters.c

# Add Transform360 to libavfilter makefile (insert before ALPHAEXTRACT)
sed -i '/CONFIG_ALPHAEXTRACT_FILTER/ i\
OBJS-\$(CONFIG_TRANSFORM360_FILTER) += vf_transform360.o\
' libavfilter/Makefile

# Fix includes
sed -i 's/.*VideoFrameTransformHandler.h.*/#include "Transform360\/Library\/VideoFrameTransformHandler.h"/' libavfilter/vf_transform360.c
sed -i 's/.*VideoFrameTransformHelper.h.*/#include "Transform360\/Library\/VideoFrameTransformHelper.h"/' libavfilter/vf_transform360.c

# Build L-SMASH
cd /usr/local/src/l-smash
./configure
make -j $(nproc)
make install

# Build libx265
cd /usr/local/src/x265/build/linux
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ../../source
make -j $(nproc)
make install

# Build libfdk-aac
cd /usr/local/src/fdk-aac
autoreconf -fiv
./configure --disable-shared
make -j $(nproc)
make install

# Build ffmpeg.
cd /usr/local/src/FFmpeg
./configure --extra-libs="-ldl" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree --enable-libopencv --extra-libs='-lTransform360 -lstdc++'
make -j $(nproc)
make install

# Build aacgain
cd /usr/local/src/aacgain/mp4v2
./configure && make -k -j $(nproc) || true # some commands fail but build succeeds
cd /usr/local/src/aacgain/faad2
./configure && make -k -j $(nproc) || true # some commands fail but build succeeds
cd /usr/local/src/aacgain
./configure && make -j $(nproc) && make install

# Remove sources
rm -rf /usr/local/src
