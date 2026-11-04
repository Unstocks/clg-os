#!/bin/sh
# Starts the QEMU x86 PC emulator, booting from the GMU OS floppy image.
set -e

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

IMG="disk_images/gmuos.flp"
if [ ! -f "$IMG" ]; then
    IMG="disk_images/mikeos.flp"
fi

if [ ! -f "$IMG" ]; then
    echo "Error: Floppy image not found at disk_images/gmuos.flp or disk_images/mikeos.flp"
    echo "Please run: sudo ./scripts/build-gmu-linux.sh"
    exit 1
fi

echo ">>> Launching QEMU with $IMG..."
qemu-system-i386 -soundhw pcspk -drive format=raw,file="$IMG",index=0,if=floppy
