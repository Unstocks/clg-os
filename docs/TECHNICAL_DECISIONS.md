# GMU OS 0.1 — Technical Decisions & Engineering Trade-Offs

> **Engineering Domain**: Low-Level Systems Programming, 16-Bit x86 Real Mode, Freestanding C  
> **Target Platform**: Real-Mode IBM PC Compatible / QEMU  

---

## 1. 16-Bit Real Mode vs Protected Mode

### Context:
Modern operating systems execute in 32-bit protected mode or 64-bit long mode with virtual memory paging. MikeOS and GMU OS execute strictly in 16-bit real mode.

### Decision:
Retain 16-bit real mode for the kernel and application execution environment.

### Rationale:
* **Direct BIOS Hardware Access**: Real mode provides immediate access to BIOS interrupts (`INT 10h` video, `INT 13h` disk, `INT 16h` keyboard) without requiring complex protected-mode device drivers or Global Descriptor Table (GDT) / Task State Segment (TSS) orchestration.
* **Pedagogical Clarity**: Students can trace execution directly from the reset vector (`0xFFFF0`) through the bootloader (`0x7C00`) to the kernel (`0x20000`) without the abstraction layers of paging or virtual memory.
* **Seamless Assembly-to-C Interfacing**: Allows students to understand segment arithmetic (`Segment * 16 + Offset`) and near pointers directly.

---

## 2. Freestanding C Runtime Architecture

### Context:
Compiling C applications for an operating system typically relies on a hosted runtime (glibc, musl, or newlib) providing startup code (`crt0.o`), dynamic memory allocators (`malloc`), and system call dispatchers.

### Decision:
Implement a 100% freestanding C environment using GCC `-m16` with a custom linker script (`c_src/gmu16.ld`) and header (`c_src/include/gmuos.h`).

### Rationale:
* **Zero Dependency Footprint**: Compiled binaries are compact (typically 500 to 4,000 bytes), fitting comfortably within a 1.44 MB floppy disk image.
* **Direct Vector Dispatch**: Rather than routing through POSIX emulation or software interrupts, system calls invoke fixed vector addresses (`call *0x0003`) defined by the kernel jump table.
* **Deterministic Layout**: The linker script specifies exact section placement starting at `0x8000`, matching the kernel's binary loading convention.

---

## 3. The Floppy Loader BSS Hazard & Explicit Zeroing

### Problem:
The floppy loader (`source/features/disk.asm`) reads sectors from disk and places them into memory starting at offset `0x8000`. However, the loader transfers only the sectors occupied by the file; **it does not zero uninitialized data (`.bss`)**. Consequently, global uninitialized variables retain leftover RAM data from previous programs, causing silent, non-deterministic bugs.

### Solution:
In interactive C applications such as `GRADES2.BIN`, an explicit initialization routine is invoked at the start of `gmu_main()` and at each repeat cycle:
```c
static void initialize_data(void) {
    int i;
    for (i = 0; i < MAX_SUBJECTS; i++) {
        subjects[i].name[0] = '\0';
        subjects[i].obtained = 0;
        subjects[i].maximum = 0;
    }
    for (i = 0; i < NAME_SIZE; i++) student[i] = '\0';
    for (i = 0; i < INPUT_SIZE; i++) input[i] = '\0';
}
```
This guarantees deterministic state on every execution regardless of dirty loader memory.

---

## 4. Single-Burst FAT12 Root Directory Traversal

### Problem:
The default directory listing routine in MikeOS iterated through filenames by making individual API calls that required multiple disk reads, resulting in slow execution and disorganized display.

### Solution:
In Milestone 07, `source/features/cli.asm` was re-engineered to perform a direct FAT12 traversal:
1. All 14 root-directory sectors (logical sectors 19 to 32, total 7,168 bytes) are read into `disk_buffer` (`0x6000`) in **a single BIOS `INT 13h` transaction**.
2. The routine iterates through the 224 directory entries (32 bytes per entry) in memory using a bounds-checked stride (`disk_buffer + 7168`).
3. VFAT long-filename entries (`0x0F`), deleted entries (`0xE5`), volume labels (`0x08`), and subdirectories (`0x10`) are filtered.
4. Output is rendered in a balanced two-column format with right-aligned 10-digit file sizes and a verified maximum width of 61 characters, eliminating screen wrap on standard 80-column teletypes.

---

## 5. Integer Overflow Mitigation in 16-Bit Real Mode

### Problem:
In 16-bit x86 C, standard `int` is 16-bit signed, with a maximum value of `+32,767`. In applications like `GRADES2.BIN`, accumulating marks across 10 subjects (up to 10,000 marks each) can reach `100,000`. Calculating percentages using `(marks * 100) / max` generates intermediate products up to `10,000,000`, causing catastrophic signed integer overflow if calculated with 16-bit variables.

### Solution:
1. **32-Bit Arithmetic**: All accumulation and percentage calculations use explicit `long` (32-bit integer) types.
2. **Pre-Multiplication Bounds Checking**: When parsing numeric input character-by-character from keyboard buffers, before multiplying by 10, the parser validates:
   ```c
   if (value > (maximum - digit) / 10) {
       /* Reject digit to prevent overflow */
   }
   ```

---

## 6. BIOS Teletype Register Preservation (DX Correction)

### Problem:
BIOS `INT 10h, AH=0Eh` (teletype output) is documented to modify `BP`, and on several clone BIOS implementations, can corrupt `DX`. In `cli.asm`, the column tracking and character counter for directory filenames relies on `DL`.

### Solution:
In `dir_print_name_12`, `DX` is explicitly preserved around the BIOS invocation:
```nasm
.emit_char:
    mov ah, 0Eh
    push dx
    int 10h
    pop dx
    inc dl
    ret
```
This protects character alignment and prevents corrupted column boundaries during long directory listings.

---

## 7. Taylor-Series Trigonometry & Exact Radical Representation

### Context:
16-bit real-mode x86 processors without an x87 floating-point math coprocessor (or freestanding environments without software floating-point libraries) cannot link standard `<math.h>` functions (`sin`, `cos`, `tan`).

### Solution:
In `c_src/scientific_calc/`:
1. Trigonometric evaluation uses quadrant reduction to $[0, 90^\circ]$ and evaluated with a 7th-order Taylor series approximation:
   $$\sin(x) \approx x - \frac{x^3}{3!} + \frac{x^5}{5!} - \frac{x^7}{7!}$$
2. For common standard angles ($0^\circ, 30^\circ, 45^\circ, 60^\circ, 90^\circ$), the calculator detects special-case values and outputs **exact radical and fraction representations** (e.g. `0`, `1/2`, `sqrt(2)/2`, `sqrt(3)/2`, `1`, `UNDEFINED`) rather than imprecise truncated decimals.

