# Docker container for running ffmpeg with H.265 and Transform360 support

## Getting Started

Install and run Docker for [Mac](https://www.docker.com/docker-mac) or [Windows](https://www.docker.com/docker-windows).

### Download and build container
```bash
git clone git@github.com:LimbixHealth/limbix-docker-ffmpeg.git
cd limbix-docker-ffmpeg
docker build -t limbix-docker-ffmpeg:latest .
```
### Test
Running the command `docker run limbix-docker-ffmpeg:latest` will run `ffmpeg` in the container.

For example the following equivalent to `ffmpeg -version`, and is a good test to check which libraries are installed:

```bash
radish:limbix-docker-ffmpeg scott$ docker run limbix-docker-ffmpeg:latest -version
ffmpeg version git-2017-09-21-bba9c1c Copyright (c) 2000-2017 the FFmpeg developers
built with gcc 6.3.0 (Debian 6.3.0-18) 20170516
configuration: --extra-libs=-ldl --enable-gpl --enable-libass --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree --enable-libopencv --extra-libs='-lTransform360 -lstdc++'
libavutil      55. 75.100 / 55. 75.100
libavcodec     57.106.101 / 57.106.101
libavformat    57. 82.101 / 57. 82.101
libavdevice    57.  8.101 / 57.  8.101
libavfilter     6.105.100 /  6.105.100
libswscale      4.  7.103 /  4.  7.103
libswresample   2.  8.100 /  2.  8.100
libpostproc    54.  6.100 / 54.  6.100
```

Nice!  We have libvpx, lib265, libopencv, lTransform360 installed.

## Example usage

### Mount host machine directories on container
To get data *in* and *out* of the container, mount directories from your host machine on the container with the `-v` flag.

For example to reencode the video example_h264.mp4 from H.264 to H.265 format:

```bash
docker run -v=`pwd`:/tmp/host-dir limbix-docker-ffmpeg:latest -i /tmp/host-dir/example_h264.mp4 -c:v libx265 /tmp/host-dir/example_h265.mp4
```

Nice compression!

```bash
radish:git scott$ ls -lh *.mp4
-rw-------  1 scott  staff    19M Sep 20 19:58 example_h264.mp4
-rw-r--r--  1 scott  staff   6.7M Sep 20 20:01 example_h265.mp4
```

### Transform360
Convert from equirect to cubemap projection, mounting two directories for reading and writing:
```bash
docker run \
    -v=/Users/scott/Google\ Drive/VR\ Dev\ Content/Dev/:/tmp/host-gd \
    -v=`pwd`:/tmp/host-dir \
    limbix-docker-ffmpeg:latest \
    -i /tmp/host-gd/relaxation/Fountain.mp4 \
    -vf transform360="input_stereo_format=MONO
        :cube_edge_length=512
        :interpolation_alg=cubic
        :enable_low_pass_filter=1
        :enable_multi_threading=1
        :num_horizontal_segments=32
        :num_vertical_segments=15
        :adjust_kernel=1" \
    /tmp/host-dir/Fountain_cubemap.mp4
```
