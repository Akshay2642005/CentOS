#!/bin/bash

# Set tools
ASM="nasm"
CC="gcc"
SRC_DIR="src"
TOOLS_DIR="tools"
BUILD_DIR="build"
IMG_FILE="$BUILD_DIR/main_floppy.img"
BOOTLOADER_BIN="$BUILD_DIR/bootloader.bin"
KERNEL_BIN="$BUILD_DIR/kernel.bin"
TOOLS_FAT="$BUILD_DIR/tools/fat"

# Ensure build directory exists
mkdir -p "$BUILD_DIR"

# Clean build directory
clean() {
  echo "Cleaning build directory..."
  rm -rf "$BUILD_DIR"/*
  echo "Clean completed."
}

# Build bootloader
build_bootloader() {
  echo "Assembling bootloader..."
  $ASM "$SRC_DIR/bootloader/boot.asm" -f bin -o "$BOOTLOADER_BIN" || exit 1
  echo "Bootloader built successfully."
}

# Build kernel
build_kernel() {
  echo "Assembling kernel..."
  $ASM "$SRC_DIR/kernel/main.asm" -f bin -o "$KERNEL_BIN" || exit 1
  echo "Kernel built successfully."
}

# Create floppy image (without mtools)
build_floppy() {
  echo "Creating FAT12 floppy image using QEMU..."
  qemu-img create -f raw "$IMG_FILE" 1440K

  echo "Writing bootloader to floppy image..."
  dd if="$BOOTLOADER_BIN" of="$IMG_FILE" conv=notrunc

  echo "Appending kernel and test.txt..."
  cat "$KERNEL_BIN" >>"$IMG_FILE"

  if [ -f "test.txt" ]; then
    cat test.txt >>"$IMG_FILE"
  else
    echo "Warning: test.txt not found! Skipping..."
  fi

  echo "Floppy image created successfully."
}

# Build tools (FAT utility)
build_tools_fat() {
  echo "Building FAT tool..."
  mkdir -p "$BUILD_DIR/tools"
  $CC -g -o "$TOOLS_FAT" "$TOOLS_DIR/fat/fat.c" || exit 1
  echo "FAT tool built successfully."
}

# Build everything
build_all() {
  build_bootloader
  build_kernel
  build_floppy
  build_tools_fat
  echo "Build completed successfully."
}

# Display usage
usage() {
  echo "Usage: $0 {all|floppy|bootloader|kernel|clean|tools_fat}"
  exit 1
}

# Parse command-line arguments
case "$1" in
all) build_all ;;
floppy) build_floppy ;;
bootloader) build_bootloader ;;
kernel) build_kernel ;;
tools_fat) build_tools_fat ;;
clean) clean ;;
*) usage ;;
esac
