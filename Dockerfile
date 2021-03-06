FROM debian:stable
MAINTAINER Scott Satkin satkin@limbix.com

RUN apt-get update && \
    apt-get -qqy install --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        git \
        mercurial \
        cmake \
        hugin \
        libass-dev \
        libgpac-dev \
        libtheora-dev \
        libtool \
        libvdpau-dev \
        libvorbis-dev \
        pkg-config \
        texi2html \
        zlib1g-dev \
        libmp3lame-dev \
	libx264-dev \
        libvpx-dev \
        libopencv-dev \
        libass-dev \
        wget \
        yasm && \
    apt-get -qqy clean && \
    rm -rf /var/lib/apt/lists/*

# Run build script

ADD script/build.sh /build.sh
RUN ["/bin/bash", "/build.sh"]

ENTRYPOINT ["/usr/local/bin/ffmpeg"]
