# GMU OS 0.1 — Memory Map & Segment Layout

> **Processor Mode**: 16-Bit Real Mode (x86)  
> **Physical Address Space**: 1 MB (0x00000 – 0xFFFFF)  
> **Addressing Scheme**: `Segment * 16 + Offset`  

---

## 1. 1 MB Real-Mode Memory Map

```
+-----------------------------------+ 0xFFFFF (1 MB)
|  Motherboard BIOS ROM & Reset Vec |
|  (Power-On Reset Vector @ 0xFFFF0)| 64 KB
+-----------------------------------+ 0xF0000
|  Option ROMs & Video BIOS         | 192 KB
+-----------------------------------+ 0xC0000
|  Video RAM (VRAM) Text Buffer     |
|  (Color Text Mode @ 0xB800:0000)  | 128 KB
+-----------------------------------+ 0xA0000 (640 KB Top of Base RAM)
|  Real-Mode System Stack           |
|  (SS:SP = 0x2000:0xFFFE)          | Grows downward
+-----------------------------------+ ~0x9FFFF
|  FAT12 Disk Buffer (disk_buffer)  |
|  (Direct Root Dir Cache @ 0x6000) | 64 KB
+-----------------------------------+ 0x60000
|  Kernel Code, Data & Vectors      |
|  (CS = DS = SS = 0x2000)          |
|  • System Call Vectors (0x0000)   |
|  • CLI Shell & Core Routines      | 64 KB Segment
+-----------------------------------+ 0x20000
|  Transient Program Area (TPA)     |
|  (C Applications Loaded @ 0x8000) |
|  • SCICALC.BIN, GRADES2.BIN       | Up to 64 KB
+-----------------------------------+ 0x08000 (Physical 0x28000 in DS:0x2000)
|  Boot Sector Stack & Safety Zone  |
+-----------------------------------+ 0x07E00
|  Master Boot Record (MBR)         |
|  (bootload.asm Loaded by BIOS)    | 512 Bytes
+-----------------------------------+ 0x07C00
|  Free Low Memory / BIOS Scratch   |
+-----------------------------------+ 0x00500
|  BIOS Data Area (BDA)             | 256 Bytes
+-----------------------------------+ 0x00400
|  Interrupt Vector Table (IVT)     |
|  (256 x 4-Byte Vectors)           | 1 KB
+-----------------------------------+ 0x00000
```

---

## 2. Segment Register Allocations

In GMU OS 0.1, the kernel operates with flat 64 KB segment registers:

| Register | Value | Base Physical Address | Description |
| :---: | :---: | :---: | :--- |
| `CS` | `0x2000` | `0x20000` | Code Segment for kernel and loaded C applications |
| `DS` | `0x2000` | `0x20000` | Data Segment for global variables, strings, and buffers |
| `SS` | `0x2000` | `0x20000` | Stack Segment |
| `SP` | `0xFFFE` | `0x2FFFE` | Top of Stack (grows downwards toward `0x8000` program code) |
| `ES` | `0x2000` | `0x20000` | Extra Segment (used dynamically for disk I/O and string operations) |

---

## 3. C Application Memory Layout (`0x8000`)

When a C program is launched from the `GMUOS> ` shell:
1. The kernel loads file sectors into memory starting at offset `0x8000` relative to segment `0x2000` (physical address `0x28000`).
2. The custom linker script `c_src/gmu16.ld` guarantees the following section order:

```ld
SECTIONS
{
    . = 0x8000;

    .text : {
        *(.text.startup)  /* GMU_C_ENTRY(_start) must be first */
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

### Critical Systems Engineering Consideration:
* **The Floppy Loader Does NOT Zero BSS**: The MikeOS floppy loader transfers sectors from disk into RAM at `0x8000`. Uninitialized variables in `.bss` contain dirty RAM remnants from previously executed programs.
* **Remediation**: All C applications in GMU OS 0.1 (such as `GRADES2.BIN`) implement explicit BSS initialization routines (e.g. `initialize_data()`) at application entry before accessing any global buffers.

---

## 4. Disk & Buffer Allocations

* **Disk Buffer (`0x6000:0000` or `0x6000` offset)**:
  - Used by `source/features/disk.asm` and `source/features/cli.asm`.
  - The enhanced `DIR` command buffers all 14 root-directory sectors (7,168 bytes) into `0x6000` to parse 224 directory entries without multiple disk head seeks.
* **Line Input Buffer (`cli.asm`)**:
  - Located in the kernel data area.
  - Accommodates up to 256 characters with automatic length-capping and backspace handling.

