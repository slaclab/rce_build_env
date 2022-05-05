FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles
RUN apt-get update && apt-get install -y \
    apt-utils \
    curl \
    automake \
    autogen \
    bash \
    build-essential \
    u-boot-tools \
    libssl-dev \
    bc \
    bzip2 \
    ca-certificates \
    curl \
    cpio \
    file \
    git \
    gzip \
    make \
    ncurses-dev \
    pkg-config \
    libtool \
    python \
    rsync \
    sed \
    bison \
    flex \
    tar \
    vim \
    wget \
    runit \
    xz-utils \
    software-properties-common \
    sudo \
    cmake \
    binfmt-support \
    qemu-user-static \
    debootstrap \
    libbz2-dev \
    libbz2-dev  \
    gnuplot \
    python3-dev \
    gnupg \
    ruby

COPY etc/sudoers /etc/sudoers 
COPY etc/apt/sources.list /etc/apt/sources.list
COPY etc/profile.d/02-sethome.sh /etc/profile.d/02-sethome.sh
COPY etc/profile.d/03-register-binfmt.sh /etc/profile.d/03-register-binfmt.sh
COPY bin/qemu-binfmt-conf.sh /bin/qemu-binfmt-conf.sh
RUN apt-add-repository multiverse && apt-get update
RUN apt-get update
RUN apt-get install -y crossbuild-essential-armhf
RUN apt-get install -y crossbuild-essential-arm64

RUN dpkg --add-architecture armhf
RUN dpkg --add-architecture arm64
RUN apt-get update

# The cross-compiling emulator
RUN apt-get update && apt-get install -y \
    qemu-user \
    qemu-user-static
# install foreign archs for cross compilation
RUN apt-get install -y libbz2-dev:armhf libbz2-dev:armhf libzmq3-dev:armhf libpython3-dev:armhf
RUN apt-get install -y libbz2-dev:arm64 libbz2-dev:arm64 libzmq3-dev:arm64 libpython3-dev:arm64
# install SLAC atlas RCE PPA and kernels
RUN curl -s --compressed "https://slaclab.github.io/atlas-rce-repo/ubuntu/KEY.gpg" | sudo apt-key add -
RUN curl -s --compressed -o /etc/apt/sources.list.d/atlas-rce.list https://slaclab.github.io/atlas-rce-repo/ubuntu/atlas-rce.list
RUN apt-get update
# user geoclue does not exist
RUN sed -i '/geoclue/d' /var/lib/dpkg/statoverride

# install ruby package fpm
RUN gem install fpm
