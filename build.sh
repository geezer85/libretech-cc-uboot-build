#!/bin/sh

# Check for cross-compile support
which arm-none-eabi-gcc 2>&1 >/dev/null
if [ $? -ne 0 ]; then
	echo "Missing \"arm-none-eabi-\" cross-compiler. See Readme.md for details."
	exit 1
fi
which aarch64-none-elf-gcc 2>&1 >/dev/null
if [ $? -ne 0 ]; then
	echo "Missing \"aarch64-none-elf-\" cross-compiler. See Readme.md for details."
	exit 2
fi

# Set Environment variables for cross-compile
export ARCH=arm
export CROSS_COMPILE=aarch64-none-elf-

cp config mainline-uboot/.config && cd mainline-uboot

# Build mainline-uboot
echo "Building mainline u-boot. This will take a few minutes..."
yes '' | make oldconfig 2>&1 >>../build.log
make -j 2>&1 >>../build.log
if [ $? -ne 0 ]; then
	echo "Build failed! Check build.log"
	exit 4
else
	echo "Success!"
	cd ..
fi

# Sign image
cd amlogic-boot-fip
./build-fip.sh lepotato ../mainline-uboot ..

echo "Unless there was an error u-boot.bin (eMMC) and u-boot.bin.sd.bin (SD card) should be ready."

exit 0
