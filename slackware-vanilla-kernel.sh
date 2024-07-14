#!/bin/bash
# Version 0.2
# Greetings.
# A rather vanilla kernel with gcc optimization patch
# Script assumes aria2 is installed for parallel download of Linux kernel source code.
# aria2 is available from slackbuilds.org
# Donald Cooley
VERSION=$1
if [ -z $VERSION ]; then
	echo "kernel version?"
	exit 0
fi

# download gpg keys

#jobs=$(expr $(nproc) + 1)
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
KERNEL_FILES="/usr/src/linux/arch/x86/boot"
KERNEL_SERVER="https://www.kernel.org/pub/linux/kernel/v6.x/linux"
SOURCE_DIRECTORY='/usr/src'

#set -e

# Donwload the kernel source and verify its gpg signature

fetch_kernel () {
    echo 'Downloading kernel source code and verifying its gpg signature'
    cd $SOURCE_DIRECTORY
    aria2c -x5 $KERNEL_SERVER-$VERSION.tar.xz
    wget $KERNEL_SERVER-$VERSION.tar.sign
    xz -dc linux-$VERSION.tar.xz | gpg --verify linux-$VERSION.tar.sign -
    return
}

# Decompress kernel

decompress_kernel () {
    echo "Decompressing kernel"
    cd $SOURCE_DIRECTORY
    tar -xf linux-$VERSION.tar.xz -C $SOURCE_DIRECTORY
    rm linux
    ln -s linux-$VERSION linux
    return
}

configure_kernel () {
    echo "Configure kernel"
    cd $SOURCE_DIRECTORY/linux
    make mrproper
    zcat /proc/config.gz > .config
    make oldconfig
    return
}

# Compile kernel
compile_kernel () {
    echo "Compiling kernel. This will take some time ..."
    export KCFLAGS='-march=native'
    export KCPPFLAGS='-march=native'
    time ( make $NUMJOBS bzImage modules && make modules_install )
    return
}

# Move files into place
move_kernel () {
    echo "Moving kernel and its files into /boot"
    cp System.map /boot/System.map-$VERSION-custom
    cp $KERNEL_FILES/bzImage /boot/vmlinuz-$VERSION-custom
    cd /boot
    rm System.map
    ln -s System.map-$VERSION-custom System.map
    echo "Don't forget to run /usr/share/mkinitrd/mkinitrd_command_generator.sh \
        and to edit /etc/lilo.conf. Finally, run lilo again."
    return
}


cd $SOURCE_DIRECTORY
# Donwload kernel's gpg key
echo "Retrieve gpg key for our kernel source code"
gpg2 --locate-keys torvalds@kernel.org gregkh@kernel.org

fetch_kernel

decompress_kernel

configure_kernel

compile_kernel

move_kernel
