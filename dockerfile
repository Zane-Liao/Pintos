# My Path: Macos 26 ARM
# build docker image: docker build --progress=plain --platform=linux/amd64 -t your_image_name .
# If Your Computer with X86-64
# build docker image: docker build --progress=plain -t your_image_name .
FROM ubuntu:23.10

RUN sed -i 's/archive.ubuntu.com/old-releases.ubuntu.com/g; s/security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        git \
        cmake \
        gdb \
        build-essential \
        clang \
        clang-tidy \
        clang-format \
        gcc-doc \
        pkg-config \
        glibc-doc \
        tcpdump \
        tshark \
        bison \
        flex \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
        texinfo \
        xz-utils

RUN dpkg --add-architecture i386

RUN apt-get update && \
    apt-get install -y  --no-install-recommends \ 
    libc6:i386 \
    libstdc++6:i386 \
    gcc-multilib \
    g++-multilib

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && update-ca-certificates

WORKDIR /opt

RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-14.1.0/gcc-14.1.0.tar.xz && \
    tar -xf binutils-2.42.tar.xz && \
    tar -xf gcc-14.1.0.tar.xz

RUN mkdir build-binutils && cd build-binutils && \
    ../binutils-2.42/configure --target=i386-elf --prefix=/opt/cross --disable-nls && \
    make -j"$(nproc)" && \
    make install

RUN mkdir build-gcc && cd build-gcc && \
    ../gcc-14.1.0/configure --target=i386-elf --prefix=/opt/cross --disable-nls --enable-languages=c --without-headers && \
    make all-gcc -j"$(nproc)" && \
    make install-gcc

ENV PATH="/opt/cross/bin:${PATH}"

RUN which i386-elf-gcc && i386-elf-gcc --version

RUN apt-get update && \
    apt-get install -y \
    qemu-system-i386 \
    bochs \
    bochs-x \
    bochs-sdl \
    bochsbios

# test: qemu-system-i386 --version && bochs --version