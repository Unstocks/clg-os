# GMU OS 0.1 — Repository & Project Structure

> **Repository**: `clg-os`  
> **Target URL**: `https://github.com/Unstocks/clg-os`  
> **Organization**: Professional Open-Source Systems Programming Repository  

---

## 1. Directory Tree Layout

```
clg-os/
│
├── README.md                          <- Primary open-source presentation & quickstart
├── .gitignore                         <- Tailored ignore rules for x86 assembly & C build artifacts
├── .gitattributes                     <- Enforces LF line-endings across ASM, C, LD and scripts
├── LICENSE-ATTRIBUTION.md             <- MikeOS BSD-3 license grant and derivative notice
│
├── assets/                            <- High-resolution visual assets and diagrams
│   ├── banner/                        <- Vector SVG hero banner (gmuos-hero-banner.svg)
│   ├── diagrams/                      <- Architecture (architecture.svg) & Memory Map (memory-map.svg)
│   └── screenshots/                   <- Genuine QEMU terminal execution captures
│
├── source/                            <- Assembly operating system kernel & bootloader
│   ├── bootload/                      <- FAT12 MBR boot sector (bootload.asm)
│   ├── features/                      <- Kernel subsystem drivers (cli, disk, screen, keyboard, etc.)
│   └── kernel.asm                     <- Kernel entry point, vector table & initialization
│
├── c_src/                             <- Freestanding 16-bit C runtime and application suite
│   ├── build-c-linux.sh               <- C application compilation pipeline (gcc -m16 & ld)
│   ├── gmu16.ld                       <- Custom 16-bit real-mode linker script for 0x8000
│   ├── include/
│   │   └── gmuos.h                    <- System call vector wrappers & GMU_C_ENTRY macro
│   ├── examples/                      <- C applications (grades.c, grades2.c, gmuinfo.c)
│   └── scientific_calc/               <- Modular scientific calculator (UI, Taylor math & preview)
│
├── programs/                          <- Executable binaries and userland applications
│   ├── gmu_os.txt                     <- In-OS text document displayed by CAT
│   └── *.asm, *.bas, *.pcx, *.bin     <- Standard userland utilities & assets
│
├── scripts/                           <- Build and test automation
│   ├── build-gmu-linux.sh             <- Master OS image creation script
│   ├── build-linux.sh                 <- Kernel & userland assembly script
│   └── test-linux.sh                  <- QEMU floppy launch script
│
├── build-gmu-linux.sh                 <- Root convenience wrapper for master build
├── build-linux.sh                     <- Root convenience wrapper for kernel build
├── test-linux.sh                      <- Root convenience wrapper for QEMU launch
│
├── disk_images/                       <- Floppy disk image output staging
│   └── .gitkeep                       <- Preserves directory for reproducible build outputs
│
├── docs/                              <- Comprehensive engineering documentation
│   ├── ARCHITECTURE.md                <- Subsystem layering, execution lifecycle & calling conventions
│   ├── BUILD_AND_RUN.md               <- Copy-paste Ubuntu VM setup, build & QEMU guide
│   ├── COMMAND_REFERENCE.md           <- Shell commands, options, and syntax
│   ├── DEVELOPMENT_ROADMAP.md         <- 10-week PBL progress dashboard and validation states
│   ├── MEMORY_MAP.md                  <- 1 MB real-mode memory layout & segment register model
│   ├── PROJECT_STRUCTURE.md           <- Repository anatomy & directory definitions (this file)
│   ├── TECHNICAL_DECISIONS.md         <- Architectural trade-offs & engineering solutions
│   └── UPSTREAM_ATTRIBUTION.md        <- Detailed provenance and upstream attribution
│
├── evidence/                          <- Weekly academic milestone evidence archives
│   ├── README.md                      <- Evidence validation protocol
│   └── week-01/ to week-10/           <- Unified git patches, reports, and screenshots
│
└── .github/                           <- GitHub community & issue templates
    └── ISSUE_TEMPLATE/
        ├── bug_report.md
        └── feature_request.md
```

---

## 2. Directory Roles & Responsibilities

| Directory | Purpose | Modification Guidelines |
| :--- | :--- | :--- |
| `source/` | Houses 16-bit x86 assembly source code for bootloader and kernel. | Maintain vector table layout (`0x0000 - 0x0063`); ensure 32-byte directory entry strides and preserve registers across BIOS calls. |
| `c_src/` | Houses all freestanding 16-bit C source files, headers, and linker scripts. | Must remain freestanding: no standard hosted C library includes (such as `<stdio.h>`); use only `gmuos.h`. |
| `programs/` | Distribution destination for compiled binaries (`.BIN`, `.BAS`, `.PCX`). | Kept clean; transient build objects (`*.o`) belong in `c_src/build/` and are git-ignored. |
| `scripts/` | Shell scripts automating multi-stage compilation, NASM assembly, and disk formatting. | Must be idempotent and verify root privileges when mounting loopback devices. |
| `docs/` | Deep technical specifications, guides, and architectural diagrams. | Keep synchronized with actual code; document limitations transparently. |
| `assets/` | Vector SVG diagrams and genuine QEMU screenshots. | Never fabricate or edit emulator screenshots. |
| `evidence/` | Academic audit trail pairing unified diff patches with weekly reports. | Tamper-proof milestone record for college PBL requirements. |

