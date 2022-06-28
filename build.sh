#!/bin/sh

arch=$(uname -m)
# Check if we are running on ARM with qemu-x86_64-static
if [ $arch = "aarch64" ]; then
	grep qemu-x86_64-static amlogic-boot-fip/gxl.inc 2>&1 >/dev/null
	if [ $? -ne 0 ]; then
		which qemu-x86_64-static 2>&1 >/dev/null
		if [ $? -eq 0 ]; then
			sed -i 's/\.\/aml_encrypt_gxl/qemu-x86_64-static \.\/aml_encrypt_gxl/g' amlogic-boot-fip/gxl.inc
		else
			echo "To build on ARM you must install qemu-user-static."
			exit 3
		fi
	fi
fi

# Check for cross-compile support
if [ $arch != "aarch64" ]; then
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
fi

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
