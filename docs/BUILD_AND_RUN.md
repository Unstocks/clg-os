# GMU OS 0.1 — Build & Execution Guide

> **Target Platform**: 16-Bit Real-Mode x86 PC  
> **Development Environment**: Ubuntu Linux (or VirtualBox Ubuntu VM / WSL)  
> **Host Compatibility**: Windows Preview supported via Python mockup  

---

## 1. Prerequisites & Toolchain Setup

To assemble the x86 real-mode kernel and compile the freestanding C applications, install the required toolchain packages on Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y \
    nasm \
    gcc \
    gcc-multilib \
    binutils \
    dosfstools \
    mtools \
    qemu-system-x86
```

### Toolchain Package Overview
* **`nasm`**: Netwide Assembler for real-mode 16-bit x86 assembly.
* **`gcc` & `gcc-multilib`**: C compiler supporting 16-bit real-mode code generation (`-m16 -march=i386`).
* **`binutils`**: Provides `ld` with 32-bit ELF emulation (`-m elf_i386`) used by `gmu16.ld`.
* **`dosfstools` & `mtools`**: FAT12 floppy filesystem utilities (`mkdosfs`, `mcopy`).
* **`qemu-system-x86`**: Full x86 PC emulator for booting floppy disk images.

---

## 2. One-Step Master Build (Recommended)

To compile all C applications, assemble the bootloader and kernel, and generate the final bootable floppy image (`disk_images/gmuos.flp`):

```bash
# Clone the repository
git clone https://github.com/Unstocks/clg-os.git
cd clg-os

# Make scripts executable
chmod +x build-gmu-linux.sh scripts/*.sh c_src/*.sh

# Run master build as root (required for loopback floppy mounting)
sudo ./build-gmu-linux.sh
```

### What the Master Build Does:
1. Executes `c_src/build-c-linux.sh` to compile:
   - `c_src/examples/grades.c` -> `programs/GRADES.BIN`
   - `c_src/examples/grades2.c` -> `programs/GRADES2.BIN`
   - `c_src/examples/gmuinfo.c` -> `programs/GMUINFO.BIN`
   - `c_src/scientific_calc/` -> `programs/SCICALC.BIN`
2. Assembles `source/bootload/bootload.asm` -> `source/bootload/bootload.bin`.
3. Assembles `source/kernel.asm` -> `source/kernel.bin`.
4. Formats a 1.44 MB FAT12 floppy disk image (`disk_images/mikeos.flp`).
5. Copies the bootloader to the first sector and writes the kernel and program binaries.
6. Duplicates the final tested image to `disk_images/gmuos.flp`.

---

## 3. Modular Step-by-Step Build

If you are modifying specific subsystems and want granular compilation:

### Step 3.1: Build Freestanding C Applications Only
```bash
cd c_src
./build-c-linux.sh
cd ..
```
*Outputs compiled binaries into `c_src/build/` and automatically copies them to `programs/`.*

### Step 3.2: Assemble Kernel & Bootloader Only
```bash
# Assemble boot sector
nasm -O0 -w+orphan-labels -f bin -o source/bootload/bootload.bin source/bootload/bootload.asm

# Assemble kernel
cd source
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm
cd ..
```

### Step 3.3: Rebuild Floppy Image
```bash
sudo ./scripts/build-linux.sh
```

---

## 4. Booting and Running in QEMU

Launch the operating system in the QEMU emulator:

```bash
# Using the convenience script
./test-linux.sh

# Or invoke QEMU directly:
qemu-system-i386 -soundhw pcspk -drive format=raw,file=disk_images/gmuos.flp,index=0,if=floppy
```

### Navigating the Operating System:
1. At boot, the welcome dialog is displayed. Press `Esc` to enter the command shell.
2. The command prompt appears: `GMUOS> `
3. Type `HELP` to list all available commands.
4. Type `DIR` to inspect floppy files in 2-column format.
5. Launch C applications by typing their executable names:
   ```text
   GMUOS> SCICALC.BIN
   GMUOS> GRADES2.BIN
   GMUOS> GRADES.BIN
   GMUOS> GMUINFO.BIN
   ```
6. Press `Esc` or the documented application key to return to the `GMUOS> ` prompt.

---

## 5. Windows Local Preview (No Compiler Required)

If you are on Windows or do not have a Linux VM configured, preview the exact input flow and mathematical engine of the Scientific Calculator:

```powershell
# From the repository root
python c_src/scientific_calc/preview_calc.py
```

This Python simulator mocks the `gmuos.h` terminal teletype functions, allowing you to test trigonometric evaluation, Taylor series precision, and exact radical fraction formatting directly inside your Windows terminal.

---

## 6. Troubleshooting & Common Issues

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| `You must run this build script as root` | Loopback mounting requires superuser privileges | Prepend `sudo` to the build command: `sudo ./build-gmu-linux.sh`. |
| `fatal error: bits/libc-header-start.h: No such file` | 32-bit/16-bit C headers missing | Install `gcc-multilib`: `sudo apt install gcc-multilib`. |
| `nasm: command not found` | Assembler not installed | Run `sudo apt install nasm`. |
| `qemu-system-i386: command not found` | Emulator not installed | Run `sudo apt install qemu-system-x86`. |
| `Permission denied` on shell scripts | Missing execution permissions | Run `chmod +x build-gmu-linux.sh scripts/*.sh c_src/*.sh`. |
| Dirty uninitialized global variables | Real-mode loader does not zero BSS | Ensure applications invoke explicit initialization (e.g. `initialize_data()`) at startup. |

