#!/bin/bash

ASM="nasm"
SRC_DIR="src"
BUILD_DIR="build"
IMG_FILE="$BUILD_DIR/main_floppy.img"
BOOTLOADER_BIN="$BUILD_DIR/bootloader.bin"
KERNEL_BIN="$BUILD_DIR/kernel.bin"

mkdir -p "$BUILD_DIR"

clean() {
  echo "Cleaning build directory..."
  rm -rf "$BUILD_DIR"/*
  echo "Clean completed."
}

build_bootloader() {
  echo "Assembling bootloader..."
  $ASM "$SRC_DIR/bootloader/boot.asm" -f bin -o "$BOOTLOADER_BIN" || exit 1
  echo "Bootloader built successfully."
}

build_kernel() {
  echo "Assembling kernel..."
  $ASM "$SRC_DIR/kernel/main.asm" -f bin -o "$KERNEL_BIN" || exit 1
  echo "Kernel built successfully."
}

build_floppy() {
  echo "Creating floppy image..."
  qemu-img create -f raw "$IMG_FILE" 1440K
  dd if="$BOOTLOADER_BIN" of="$IMG_FILE" conv=notrunc status=none
  dd if="$KERNEL_BIN" of="$IMG_FILE" seek=1 bs=512 conv=notrunc status=none
  echo "Floppy image created successfully."
}

ACTION="${1:-all}"

case "$ACTION" in
all)
  build_bootloader
  build_kernel
  build_floppy
  ;;
bootloader) build_bootloader ;;
kernel) build_kernel ;;
floppy) build_floppy ;;
clean) clean ;;
*) echo "Usage: $0 {all|bootloader|kernel|floppy|clean}" ;;
esac
