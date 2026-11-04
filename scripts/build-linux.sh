#!/bin/sh
# GMU OS 0.1 Linux Build Script
# Assembles bootloader, kernel, programs, and creates bootable floppy and CD images.
# Must be run with root permissions for loopback mounting.
set -e

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

if [ "$(id -u)" -ne 0 ]; then
	echo "Error: You must run this build script as root (for loopback mounting)."
	echo "Usage: sudo ./scripts/build-linux.sh  (or sudo ./build-linux.sh)"
	exit 1
fi

mkdir -p disk_images
if [ ! -e disk_images/mikeos.flp ]; then
	echo ">>> Creating new 1.44 MB FAT12 floppy image..."
	mkdosfs -C disk_images/mikeos.flp 1440 || exit 1
fi

echo ">>> Assembling bootloader (NASM)..."
nasm -O0 -w+orphan-labels -f bin -o source/bootload/bootload.bin source/bootload/bootload.asm || exit 1

echo ">>> Assembling GMU OS kernel (NASM)..."
cd source
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit 1
cd "$ROOT"

echo ">>> Assembling assembly programs..."
cd programs
for i in *.asm; do
	[ -f "$i" ] || continue
	nasm -O0 -w+orphan-labels -f bin "$i" -o "$(basename "$i" .asm).bin" || exit 1
done
cd "$ROOT"

echo ">>> Writing bootloader to floppy image..."
dd status=noxfer conv=notrunc if=source/bootload/bootload.bin of=disk_images/mikeos.flp || exit 1

echo ">>> Copying GMU OS kernel and program files to floppy image..."
rm -rf tmp-loop
mkdir -p tmp-loop
mount -o loop -t vfat disk_images/mikeos.flp tmp-loop

cp source/kernel.bin tmp-loop/
cp programs/*.bin programs/*.BIN programs/*.bas programs/sample.pcx programs/vedithlp.txt programs/gen.4th programs/hello.512 tmp-loop/ 2>/dev/null || true

if [ -f programs/gmu_os.txt ]; then
	cp programs/gmu_os.txt tmp-loop/GMU_OS.TXT
fi

sleep 0.2
echo ">>> Unmounting loopback floppy..."
umount tmp-loop || exit 1
rm -rf tmp-loop

echo ">>> Creating bootable CD-ROM ISO image..."
rm -f disk_images/mikeos.iso
if command -v mkisofs >/dev/null 2>&1; then
	mkisofs -quiet -V 'GMUOS' -input-charset iso8859-1 -o disk_images/mikeos.iso -b mikeos.flp disk_images/ || true
elif command -v genisoimage >/dev/null 2>&1; then
	genisoimage -quiet -V 'GMUOS' -input-charset iso8859-1 -o disk_images/mikeos.iso -b mikeos.flp disk_images/ || true
fi

echo ">>> Build complete: disk_images/mikeos.flp ready."
