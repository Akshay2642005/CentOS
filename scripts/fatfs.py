import fatfs

fatfs format --type=FAT12 build/main_floppy.img
fatfs copy build/kernel.bin build/main_floppy.img /KERNEL.BIN
fatfs ls build/main_floppy.img

