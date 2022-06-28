# libretech-cc-uboot-build
Scripts for building mainline u-boot images on Libretech CC (Le Potato)

Notes:

The closed-source fip_create and aml_encrypt_gxl binaries from the chipset vendor are compiled (statically) for x86_64 Linux. To sign the image on ARM qemu-user-static must be installed (at least qemu-x86_64_static). 

Steps:

1) If building on an architecture other than aarch64, download or build cross-compile toolchains for arm-none-eabi- and aarch64-none-elf- targets and add them to your PATH:

The easiest option is to use the ARM Developer toolchains from here: https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-a/downloads. Download both AArch32 bare metal target and AArch64 ELF bare-metal target compilers, extract them, and add the bin directory from each to your PATH.

2) Run "git submodule update --init" to populate submodules

3) Edit or remove config (optional):

Two example mainline u-boot configurations are included. The config symlink points to config.emmc. If you use an SD card instead you can point it to config.sdcard. If you would prefer defaults simply delete the symlink before proceeding. You can also edit it like any other KConfig file (make menuconfig, etc.) if you copy it to the mainline-uboot directory first.

4) Run build.sh

5) Install on eMMC/SD card:

Warning: Make sure to use the correct devices or you'll wipe your OS.

For SD Card:
# dd if=fip/u-boot.bin.sd.bin of=/dev/xxx conv=fsync,notrunc bs=1 count=444
# dd if=fip/u-boot.bin.sd.bin of=/dev/xxx conv=fsync,notrunc bs=512 skip=1 seek=1

For eMMC:

You will need to do this from an OS running on the device. The debian/ubuntu images from libre.computer or Armbian on an SD card work.

# dd if=u-boot.bin of=/dev/xxx bs=512 seek=1
