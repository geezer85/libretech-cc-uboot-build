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

# Build fip blobs needed to sigm uboot image

echo "Building fip.bin from vendor u-boot. This will take a few minutes..."
cd vendor-uboot
make libretech_cc_defconfig 2>&1 >../build.log
make -j fip.bin 2>&1 >>../build.log
if [ $? -ne 0 ]; then
	echo "Build failed! Check build.log."
	exit 3
else
	echo "Success!"
	cd ..
fi

# If config exists copy it first, else use defaults.
cp config mainline-uboot/.config && cd mainline-uboot

# Build mainline-uboot
echo "Building mainline u-boot. This will take a few minutes..."
make -j 2>&1 >>../build.log
if [ $? -ne 0 ]; then
	echo "Build failed! Check build.log"
	exit 4
else
	echo "Success!"
	cd ..
fi

# Sign boot image
export FIPDIR=vendor-uboot/fip
mkdir fip
cp $FIPDIR/gxl/bl2.bin fip/
cp $FIPDIR/gxl/acs.bin fip/
cp $FIPDIR/gxl/bl21.bin fip/
cp $FIPDIR/gxl/bl30.bin fip/
cp $FIPDIR/gxl/bl301.bin fip/
cp $FIPDIR/gxl/bl31.img fip/
cp mainline-uboot/u-boot.bin fip/bl33.bin
$FIPDIR/blx_fix.sh fip/bl30.bin fip/zero_tmp fip/bl30_zero.bin fip/bl301.bin fip/bl301_zero.bin fip/bl30_new.bin bl30
$FIPDIR/acs_tool.pyc fip/bl2.bin fip/bl2_acs.bin fip/acs.bin 0
$FIPDIR/blx_fix.sh fip/bl2_acs.bin fip/zero_tmp fip/bl2_zero.bin fip/bl21.bin fip/bl21_zero.bin fip/bl2_new.bin bl2
$FIPDIR/gxl/aml_encrypt_gxl --bl3enc --input fip/bl30_new.bin
$FIPDIR/gxl/aml_encrypt_gxl --bl3enc --input fip/bl31.img
$FIPDIR/gxl/aml_encrypt_gxl --bl3enc --input fip/bl33.bin
$FIPDIR/gxl/aml_encrypt_gxl --bl2sig --input fip/bl2_new.bin --output fip/bl2.n.bin.sig
$FIPDIR/gxl/aml_encrypt_gxl --bootmk --output fip/u-boot.bin --bl2 fip/bl2.n.bin.sig --bl30 fip/bl30_new.bin.enc --bl31 fip/bl31.img.enc --bl33 fip/bl33.bin.enc
cp fip/u-boot.bin .
cp fip/u-boot.bin.sd.bin .
echo "Unless there was an error u-boot.bin (eMMC) and u-boot.bin.sd.bin (SD card) should be ready."

exit 0
