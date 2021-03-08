# libretech-cc-uboot-build
Scripts for building mainline u-boot images on Libretech CC (Le Potato)

Notes:

The closed-source fip_create and aml_encrypt_gxl binaries from the chipset vendor are compiled (statically) for x86_64 Linux. It is not currently possible to build the vendor u-boot on any other OS or architecture.

Steps:

1) Download or build cross-compile toolchains for arm-none-eabi- and aarch64-none-elf- targets and add them to your PATH:

The easiest option is to use the ARM Developer toolchains from here: https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-a/downloads. Download both AArch32 bare metal target and AArch64 ELF bare-metal target compilers, extract them, and add the bin directory from each to your PATH.

2) Edit or remove config (optional):

Two example mainline u-boot configurations are included. The config symlink points to config.emmc. If you use an SD card instead you can point it to config.sdcard. If you would prefer defaults simply delete the symlink before proceeding. You can also edit it like any other KConfig file (make menuconfig, etc.) if you copy it to the mainline-uboot directory first. If it does not exist run "git submodule update --remote --recursive" in the top-level directory.

3) Run build.sh

4) Install on eMMC/SD card:

Warning: Make sure to use the correct devices or you'll wipe your OS. If in doubt Balena Etcher works for the SD card.

For SD Card:
# dd if=fip/u-boot.bin.sd.bin of=/dev/xxx conv=fsync,notrunc bs=1 count=444
# dd if=fip/u-boot.bin.sd.bin of=/dev/xxx conv=fsync,notrunc bs=512 skip=1 seek=1

For eMMC:

You will need to do this from an OS running on the device. The debian/ubuntu images from libre.computer or Armbian on an SD card work.

# dd if=u-boot.bin of=/dev/xxx bs=512 seek=1
