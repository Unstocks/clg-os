# GMU OS 0.1 — Upstream Provenance & Attribution

> **Base Project**: MikeOS 4.7.0  
> **Original Author**: Mike Saunders and the MikeOS Developers  
> **Website**: [https://mikeos.sourceforge.net/](https://mikeos.sourceforge.net/)  
> **Original License**: BSD 3-Clause License  

---

## 1. Respecting Open-Source Foundations

GMU OS 0.1 is proud to be built upon **MikeOS 4.7.0**, an elegant, lightweight, and thoroughly documented 16-bit real-mode operating system created by Mike Saunders and open-source contributors from 2006 to 2022.

MikeOS was selected as the architectural base for this university Operating Systems Project-Based Learning curriculum because:
1. It provides a complete, understandable x86 real-mode kernel under 25 KB.
2. It implements a fully functioning FAT12 floppy disk driver directly in assembly.
3. It features an established jump-table system call ABI (`0x0000 - 0x0063`).
4. It is distributed under a permissive BSD 3-Clause open-source license that encourages educational derivation and study.

---

## 2. Upstream License Grant

The original MikeOS license is preserved in full in [`LICENSE-ATTRIBUTION.md`](../LICENSE-ATTRIBUTION.md) and [`doc/LICENSE.TXT`](../doc/LICENSE.TXT):

```
Copyright (C) 2006 - 2022 MikeOS Developers -- http://mikeos.sourceforge.net
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name MikeOS nor the names of any MikeOS contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.
```

---

## 3. Clear Demarcation of Work

To ensure absolute academic integrity and open-source compliance, the boundary between upstream MikeOS and GMU OS 0.1 is clearly delineated:

### Upstream Foundation (MikeOS 4.7.0):
* MBR Bootloader (`source/bootload/bootload.asm`)
* Core Real-Mode Jump Table (`source/kernel.asm` vectors `0x0000 - 0x0063`)
* FAT12 Cluster Management & Sector I/O (`source/features/disk.asm`)
* Real-Mode Keyboard, Sound, and String Primitives (`keyboard.asm`, `sound.asm`, `string.asm`)
* Built-in BASIC Interpreter (`source/features/basic.asm`)
* Legacy Userland Programs (`viewer.asm`, `vedit.asm`, `calc.asm`, `forth.asm`)

### Original Contributions in GMU OS 0.1:
* **Freestanding C Runtime Layer**:
  - `c_src/include/gmuos.h`: System call wrappers and `GMU_C_ENTRY` startup macro.
  - `c_src/gmu16.ld`: Custom GNU LD real-mode linker script mapping `.text` at `0x8000`.
  - `c_src/build-c-linux.sh`: Dedicated compilation pipeline for 16-bit freestanding C.
* **C Application Suite**:
  - `GRADES.BIN`: Static academic grade analyzer with integer-based percentage logic.
  - `GRADES2.BIN`: Interactive student grade calculator with manual BSS zeroing, backspace line editing, and overflow protection.
  - `GMUINFO.BIN`: Hardware telemetry utility querying BIOS RAM (INT 12h), CMOS RTC time/date, and segment registers.
  - `SCICALC.BIN`: Modular scientific calculator with 7th-order Taylor series trigonometry and exact radical formatting.
  - `c_src/scientific_calc/preview_calc.py`: Standalone Python emulator for rapid desktop testing.
* **Kernel & Shell Enhancements**:
  - Custom shell prompt: `GMUOS> `.
  - Categorized `HELP` command (Files, System, Launch).
  - Built-in `ABOUT` command showing kernel segment, physical address, and course information.
  - Enhanced `DIR` command: single-burst FAT12 root-directory traversal, balanced 2-column display with 10-digit file sizes and total file summary.
  - Automated master build pipeline (`scripts/build-gmu-linux.sh`).

