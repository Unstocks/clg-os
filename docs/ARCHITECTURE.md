# GMU OS 0.1 — System Architecture & Internals

> **Project**: GMU OS 0.1 — 16-Bit C-Oriented Learning Operating System  
> **Course**: UE25CS2304 — Operating System with Practice  
> **Institution**: GM University, Davanagere, Karnataka, India  
> **Upstream Foundation**: MikeOS 4.7.0 by Mike Saunders and Contributors  

---

## 1. Architectural Philosophy

GMU OS 0.1 is engineered around a hybrid educational paradigm:
1. **Low-Level Assembly Infrastructure**: The system bootloader (`source/bootload/bootload.asm`) and operating system core (`source/kernel.asm`) are written in 16-bit x86 real-mode assembly. Real-mode x86 directly interfaces with BIOS firmware routines (`INT 10h`, `INT 12h`, `INT 13h`, `INT 16h`, `INT 1Ah`), managing segment registers, processor interrupt flags, and hardware I/O ports.
2. **Freestanding C Application Layer**: Student applications are developed in freestanding C (`c_src/`). By establishing an ABI bridge (`c_src/include/gmuos.h`) and a dedicated 16-bit linker configuration (`c_src/gmu16.ld`), developers write structured C programs that execute in real-mode memory without requiring a modern hosted C runtime (such as glibc or newlib).

```
┌────────────────────────────────────────────────────────────────────────┐
│                        GMU OS 0.1 ARCHITECTURE                         │
├────────────────────────────────────────────────────────────────────────┤
│  User C Applications (0x8000)                                          │
│  ├── SCICALC.BIN   (Scientific Calculator & Taylor Trig Engine)        │
│  ├── GRADES2.BIN   (Interactive Student Grade Calculator 2.0)         │
│  ├── GRADES.BIN    (Static Academic Grade Analyzer)                   │
│  └── GMUINFO.BIN   (Hardware Telemetry & RTC Time/Date)                │
├────────────────────────────────────────────────────────────────────────┤
│  Freestanding C Runtime Layer                                          │
│  ├── gmuos.h       (Kernel System Call Wrappers & Inline Assembly)    │
│  └── gmu16.ld      (Custom 16-bit Linker Script for 0x8000 Entry)     │
├────────────────────────────────────────────────────────────────────────┤
│  Enhanced GMU OS CLI Shell                                             │
│  ├── Prompt: "GMUOS> "                                                 │
│  ├── Categorized HELP (Files, System, Launch)                         │
│  ├── ABOUT Command (Kernel Segment, Load Address & Academic Identity) │
│  └── 2-Column Enhanced DIR (Direct FAT12 Traversal, 61-Col Max)        │
├────────────────────────────────────────────────────────────────────────┤
│  Kernel Subsystems & Hardware Interface (0x2000:0000)                  │
│  ├── System Call Vector Table (Vectors 0x0000 - 0x0063)                │
│  ├── FAT12 Floppy Disk Subsystem (INT 13h)                            │
│  ├── Teletype Console & Video Subsystem (INT 10h)                     │
│  └── Real-Time Clock & Keyboard Subsystem (INT 16h / INT 1Ah)         │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Kernel Load & Execution Lifecycle

### 2.1 Boot Sector Stage (`0x07C0:0000`)
- When the x86 processor boots, the BIOS loads the first 512-byte sector of the floppy disk into physical address `0x07C00`.
- `bootload.asm` sets segment registers (`DS`, `ES`), initializes a local stack, queries disk geometry via BIOS `INT 13h, AH=08h`, searches the FAT12 root directory for `KERNEL.BIN`, loads the FAT table into memory, walks the cluster chain, and loads `KERNEL.BIN` into segment `0x2000:0000` (physical address `0x20000`).
- Execution jumps to `0x2000:0000`.

### 2.2 Kernel Initialization Stage (`0x2000:0000`)
- `kernel.asm` establishes flat segment registers for real mode:
  ```nasm
  mov ax, 2000h
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov sp, 0FFFEh
  ```
- The kernel sets up the 80x25 text video mode (`INT 10h, AH=00h, AL=03h`), displays the branded GMU OS welcome dialog box, or drops directly to the interactive command-line interface (`source/features/cli.asm`) upon pressing `Esc`.

---

## 3. Freestanding C Application Layer

### 3.1 Memory Model & Calling Convention
- User programs are loaded by the OS floppy loader at offset `0x8000` within the kernel segment (`0x2000:0x8000`, physical address `0x28000`).
- Because `CS=0x2000`, `DS=0x2000`, and `SS=0x2000`, applications operate under a small memory model where near pointers are 16 bits.
- Programs are compiled with GCC using `-m16 -march=i386 -ffreestanding -fno-pic -fno-pie -fno-stack-protector -fomit-frame-pointer -Os -nostdlib`.

### 3.2 Linker Script (`c_src/gmu16.ld`)
The custom linker script enforces 16-bit binary layout:
```ld
OUTPUT_FORMAT("binary")
ENTRY(gmu_main)

SECTIONS
{
    . = 0x8000;

    .text : {
        *(.text.startup)
        *(.text)
        *(.text.*)
    }

    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }

    .data : {
        *(.data)
        *(.data.*)
    }

    .bss : {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    }
}
```

### 3.3 Entry Point Macro (`GMU_C_ENTRY`)
Because `0x8000` is the exact byte where the OS jumps to launch an external binary, the first instruction at `0x8000` must be the entry point. `gmuos.h` provides:
```c
#define GMU_C_ENTRY(entry_func) \
    void _start(void) __attribute__((section(".text.startup"))); \
    void _start(void) { entry_func(); }
```
This forces `_start()` into `.text.startup` at the absolute beginning of the binary, transferring execution immediately to `gmu_main()`.

---

## 4. System Call Vector Table

MikeOS and GMU OS maintain an assembly jump table at the very start of the kernel binary (`0x2000:0000`). Each system call occupies exactly 3 bytes (`jmp near routine`), providing immutable vector entry points:

| Vector Offset | Function Name | Input Registers | Output / Effect | Description |
| :---: | :--- | :--- | :--- | :--- |
| `0x0003` | `os_print_string` | `SI = string pointer` | None | Prints null-terminated string to screen teletype |
| `0x0006` | `os_move_cursor` | `DH = row, DL = column` | None | Moves hardware cursor to specified coordinate |
| `0x0009` | `os_clear_screen` | None | None | Clears 80x25 text screen and resets cursor to (0,0) |
| `0x000C` | `os_print_horiz_line` | `AX = character attribute` | None | Draws horizontal line across the current row |
| `0x0012` | `os_wait_for_key` | None | `AL = ASCII, AH = scan code` | Blocks until key press |
| `0x0015` | `os_check_for_key` | None | `ZF set if no key, AL = ASCII` | Non-blocking keystroke poll |
| `0x0054` | `os_get_time_string` | `BX = buffer pointer` | String at `[BX]` | Queries CMOS RTC for current time (`HH:MM:SS`) |
| `0x005D` | `os_get_date_string` | `BX = buffer pointer` | String at `[BX]` | Queries CMOS RTC for current date (`YYYY/MM/DD`) |

In `c_src/include/gmuos.h`, inline assembly bridges C function calls directly to these vectors:
```c
static inline void gmu_print(const char *msg) {
    __asm__ __volatile__(
        "call *0x0003\n\t"
        :
        : "S"(msg)
        : "ax"
    );
}
```

---

## 5. Subsystem Implementations

### 5.1 CLI Shell (`source/features/cli.asm`)
- **Prompt**: Displays `GMUOS> ` and awaits user keyboard input into a 256-byte line buffer.
- **Parser**: Tokenizes the input command, trims whitespace, and compares against internal command dispatch tables.
- **Categorized Help**: Built-in `HELP` command outputs categorized listings:
  - *Files*: `DIR`, `LS`, `CAT`, `COPY`, `REN`, `DEL`, `SIZE`
  - *System*: `CLS`, `HELP`, `ABOUT`, `VER`, `TIME`, `DATE`, `EXIT`
  - *Launch*: Type program name (`.BIN` or `.BAS`)
- **About Command**: Reports kernel load segment (`0x2000`), physical memory address (`0x20000`), course information, and architecture.

### 5.2 FAT12 Floppy Disk Subsystem (`source/features/disk.asm` & `cli.asm`)
- Floppy media uses 1.44 MB standard 3.5-inch geometry (512 bytes/sector, 18 sectors/track, 2 heads, 80 cylinders).
- **Directory Traversal (`DIR`)**:
  - The enhanced `DIR` routine reads the 14 root-directory sectors (logical sectors 19 to 32) into `disk_buffer` (`0x6000`) in a single BIOS `INT 13h` transaction.
  - Iterates through 32-byte directory entries up to 224 entries (`disk_buffer + 7168`).
  - Filters deleted entries (`0xE5`), volume labels (`0x08`), subdirectories (`0x10`), and VFAT long-filename entries (`0x0F`).
  - Converts 32-bit little-endian binary file sizes into 10-digit decimal strings.
  - Formats output into a balanced 2-column layout (max width 61 columns), preventing screen-wrap on 80x25 teletype displays.

