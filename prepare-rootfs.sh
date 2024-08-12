#! /bin/bash

# This process sets up a cross-compilation environment for the ARM64 architecture on an Ubuntu system.

# setup binfmt hooks if not already done check by using ll /proc/sys/fs/binfmt_misc/{qemu-aarch64,qemu-riscv64}
# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Usage: ./prepare-rootfs.bash <arch> <linux_suite> <cache_dir> <output_dir>
# Example: ./prepare-rootfs.bash jammy arm64 ./cache ./fs

# this will create a rootfs directory with the specified linux suite and architecture
# ./fs/arm64/jammy will be created
# ./cache/aptcache/arm64/jammy/archives will be created

set -e
arch=$1
linux_suite=$2
given_cache_dir=$3
output_dir=$4
rootfs_dir=${output_dir}/${arch}/${linux_suite}
cache_dir=${given_cache_dir}/aptcache/${arch}/${linux_suite}/archives

echo creating rootfs and cache directorries
mkdir -p $cache_dir $rootfs_dir
rootfs_dir=$(realpath ${output_dir}/${arch}/${linux_suite})
cache_dir=$(realpath ${given_cache_dir}/aptcache/${arch}/${linux_suite}/archives)

# sudo apt update && apt install -y debootstrap
echo 'debootstrapping for $arch:$linux_suite <- stage 1'
fakeroot debootstrap --variant=minbase --arch=$arch '--include=libssl-dev,libcurl4-openssl-dev' '--components=main,universe,restricted' --cache-dir=$cache_dir --foreign $linux_suite $rootfs_dir http://ports.ubuntu.com/
fakeroot cp /usr/bin/qemu-aarch64-static $rootfs_dir/usr/bin/

echo 'preparing fakechroot and mount points'
# to elevate the chroot environment
sudo mount -o bind /dev $rootfs_dir/dev
sudo mount -o bind /proc $rootfs_dir/proc
sudo mount -o bind /sys $rootfs_dir/sys
# TODO: change this to dynamic in the future
sudo ln -sf $rootfs_dir/lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1

echo 'debootstrapping for $arch:$linux_suite <- stage 2'
fakechroot chroot $rootfs_dir /debootstrap/debootstrap --second-stage
# or
# sudo chroot $rootfs_dir /debootstrap/debootstrap --second-stage

# Set proxy variables inside chroot
# fakeroot chroot $rootfs_dir /bin/bash -c "export http_proxy=$http_proxy; export https_proxy=$https_proxy; export ftp_proxy=$ftp_proxy; export no_proxy=$no_proxy; apt-get update"

sudo umount $rootfs_dir/dev
sudo umount $rootfs_dir/proc
sudo umount $rootfs_dir/sys
# TODO: change this to dynamic in the future
sudo rm /lib/ld-linux-aarch64.so.1

echo "rootfs for $arch:$linux_suite prepared at $rootfs_dir"

