# Licensing & Upstream Attribution

**Project**: GMU OS 0.1  
**Upstream Foundation**: MikeOS 4.7.0  
**Upstream Author**: Mike Saunders and the MikeOS Developers  
**Upstream Website**: [https://mikeos.sourceforge.net/](https://mikeos.sourceforge.net/)  
**License**: BSD 3-Clause License (Preserved in full below)

---

## 1. Upstream License Grant (MikeOS 4.7.0)

```
==================================================================
MikeOS -- License
==================================================================

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

THIS SOFTWARE IS PROVIDED BY MIKEOS DEVELOPERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL MIKEOS DEVELOPERS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

==================================================================
```

---

## 2. Derivative Notice & Work Identification

**GMU OS 0.1** is an educational, non-commercial derivative of MikeOS 4.7.0 created for Project-Based Learning in Operating Systems at GM University, Davanagere, Karnataka, India.

In accordance with the 3-Clause BSD License terms:
1. The original copyright notices and license text are preserved verbatim in all source headers and documentation.
2. The names "MikeOS" and "Mike Saunders" are used solely for provenance, attribution, and architectural description, not to endorse or promote this derivative.
3. Original unmodified upstream source files remain accessible in the project archives for historical auditing.

### Summary of New and Modified Subsystems in GMU OS 0.1

| Component | Provenance | Modifications / Contributions |
| :--- | :---: | :--- |
| `source/kernel.asm` | Modified Upstream | Branded welcome dialogs and version constants customized to GMU OS 0.1; system call vector table preserved intact. |
| `source/features/cli.asm` | Modified Upstream | Replaced default prompt with `GMUOS> `; restructured `HELP` into categorized groups; added `ABOUT` internal command; replaced `list_directory` with enhanced 2-column direct FAT12 directory traversal with 10-digit file sizes and total file summary. Legacy `LS` command preserved. |
| `c_src/include/gmuos.h` | **Original GMU OS** | Freestanding C header providing inline assembly ABI wrappers for MikeOS system call vectors, video teletype, and keyboard routines. |
| `c_src/gmu16.ld` | **Original GMU OS** | Custom GNU LD linker script mapping 16-bit real-mode segments (`.text`, `.rodata`, `.data`, `.bss`) to execution address `0x8000`. |
| `c_src/examples/grades.c` | **Original GMU OS** | Freestanding academic grade analyzer with programmatic 32-bit integer arithmetic. |
| `c_src/examples/grades2.c` | **Original GMU OS** | Interactive student grade calculator featuring manual BSS zeroing, backspace-aware string buffer, integer overflow protection, and pass/fail evaluation. |
| `c_src/examples/gmuinfo.c` | **Original GMU OS** | Rich hardware telemetry application querying BIOS RAM (INT 12h), CMOS RTC time/date, and segment registers (CS, DS, SS). |
| `c_src/scientific_calc/` | **Original GMU OS** | Modular mathematical engine and scientific calculator (`scientific_calc.c`, `math.c`, `math.h`, `preview_calc.py`) with 7th-order Taylor series trigonometry and exact radical formatting. |
| `scripts/build-gmu-linux.sh` | **Original GMU OS** | Master automated pipeline combining freestanding 16-bit GCC compilation with NASM kernel assembly and FAT12 floppy image generation. |

---

## 3. Academic Attribution

* **Developer**: Sanjayakumar S H  
* **Department**: Department of Computer Science & Engineering (AI-BC-BS)  
* **Institution**: GM University, Davanagere, Karnataka, India  
* **Course**: UE25CS2304 — Operating System with Practice (PBL)  
* **Project Organization**: [Unstocks](https://github.com/Unstocks)

