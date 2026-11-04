#!/bin/sh
# GMU OS 0.1 Master Build Script for Linux / GCC-m16 environments.
# 1) Builds freestanding C applications (GRADES, GRADES2, GMUINFO, SCICALC).
# 2) Invokes base kernel & bootloader assembly.
# 3) Packages binaries and creates disk_images/gmuos.flp.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

if [ "$(id -u)" -ne 0 ]; then
	echo "Error: You must run this build script as root (for loopback mounting)."
	echo "Usage: sudo ./scripts/build-gmu-linux.sh  (or sudo ./build-gmu-linux.sh)"
	exit 1
fi

echo "=================================================================="
echo "GMU OS 0.1 -- Master Build Process"
echo "=================================================================="

# 1. Compile 16-bit C applications
echo ">>> [1/3] Building freestanding 16-bit C applications..."
"$ROOT/c_src/build-c-linux.sh"

# 2. Assemble bootloader, kernel, and programs
echo ">>> [2/3] Assembling kernel and userland programs..."
"$ROOT/scripts/build-linux.sh"

# 3. Create GMU OS distribution floppy image
echo ">>> [3/3] Creating final GMU OS floppy distribution image..."
mkdir -p tmp-gmu-loop
mount -o loop -t vfat disk_images/mikeos.flp tmp-gmu-loop

if [ -f programs/gmu_os.txt ]; then
	cp programs/gmu_os.txt tmp-gmu-loop/GMU_OS.TXT
fi
cp programs/*.BIN tmp-gmu-loop/ 2>/dev/null || true

umount tmp-gmu-loop
rmdir tmp-gmu-loop
cp disk_images/mikeos.flp disk_images/gmuos.flp

echo "=================================================================="
echo ">>> GMU OS 0.1 Image Ready: disk_images/gmuos.flp"
echo ">>> Boot in QEMU: qemu-system-i386 -fda disk_images/gmuos.flp"
echo "=================================================================="
