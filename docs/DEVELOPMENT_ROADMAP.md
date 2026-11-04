# GMU OS 0.1 — Development Roadmap & Milestone Dashboard

> **Curriculum**: UE25CS2304 — Operating System with Practice  
> **Format**: Progressive Individual Project-Based Learning (PBL)  
> **Three-Stage Lifecycle**: Stage A (Modular Dev) ➔ Stage B (Build Integration) ➔ Stage C (Evidence & QEMU Validation)  

---

## 1. Overall Progress Dashboard

| Week | Milestone Description | Primary Source Area | Implementation Status | Verification Status | Evidence Folder |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **00** | Initial Read-Only Audit & Setup | Entire Repository | **COMPLETED** | Verified (104/104 Baseline Hashed) | `backups/week-01-before` |
| **01** | Identity & Welcome Screen Customization | `source/kernel.asm` | **COMPLETED** | **QEMU Screen Verified** | [`evidence/week-01/`](../evidence/week-01/) |
| **02** | Custom Command Prompt (`GMUOS> `) | `source/features/cli.asm` | **COMPLETED** | **QEMU Screen Verified** | [`evidence/week-02/`](../evidence/week-02/) |
| **03** | Interactive HELP System Enhancement | `source/features/cli.asm` | **COMPLETED** | **QEMU Screen Verified** | [`evidence/week-03/`](../evidence/week-03/) |
| **04** | New Internal CLI Command (`ABOUT`) | `source/features/cli.asm` | **COMPLETED** | **QEMU Screen Verified** | [`evidence/week-04/`](../evidence/week-04/) |
| **05** | 16-bit Freestanding C App (`GRADES.BIN`) | `c_src/examples/grades.c` | **COMPLETED** | **QEMU Screen Verified** | [`evidence/week-05/`](../evidence/week-05/) |
| **06** | Richer SYSINFO Display in C (`GMUINFO.BIN`) | `c_src/examples/gmuinfo.c` | **STAGE A IMPLEMENTED** | Source Validated | [`evidence/week-06/`](../evidence/week-06/) |
| **07** | Enhanced FAT12 File Listing (`DIR`) | `source/features/cli.asm` | **COMPLETED** | **QEMU Screen Verified** | [`evidence/week-07/`](../evidence/week-07/) |
| **08** | OS Service / System Call & C Wrapper | `source/kernel.asm`, `gmuos.h`| **IN PROGRESS** | Pending Integration | [`evidence/week-08/`](../evidence/week-08/) |
| **09** | Disk Subsystem & File Management Behavior | `source/features/disk.asm` | **SCHEDULED** | Pending Integration | [`evidence/week-09/`](../evidence/week-09/) |
| **10** | Capstone OS Extension & Final Synthesis | Full System | **SCHEDULED** | Pending Integration | [`evidence/week-10/`](../evidence/week-10/) |

---

## 2. Milestone Deep-Dive & Engineering Audit

### Milestone 00: Baseline Integrity & Environment Setup
- **Objective**: Establish immutable reference baseline of MikeOS 4.7.0, recursive SHA-256 manifest, and risk register.
- **Outcome**: 104 files verified and locked in read-only archive. Zero regressions allowed.

### Milestone 01: Welcome Screen Branding
- **Objective**: Brand operating system banners and version strings while maintaining binary compatibility.
- **Source Modified**: `source/kernel.asm` (`os_init_msg`, `os_version_msg`, `dialog_string_1`).
- **Validation**: Verified in QEMU; captured screenshot `assets/screenshots/01_welcome_screen.jpg`.

### Milestone 02: Custom Shell Prompt (`GMUOS> `)
- **Objective**: Update default command-line prompt string.
- **Source Modified**: `source/features/cli.asm` (line 956: `prompt db 'GMUOS> ', 0`).
- **Validation**: Verified in QEMU; captured screenshot `assets/screenshots/02_custom_prompt.png`.

### Milestone 03: Categorized Help System
- **Objective**: Restructure flat command list into organized functional groups (Files, System, Launch).
- **Source Modified**: `source/features/cli.asm` (`help_text`, `print_help`).
- **Validation**: Verified in QEMU; captured screenshot `assets/screenshots/03_help_system.png`.

### Milestone 04: Internal CLI Command (`ABOUT`)
- **Objective**: Implement command token comparison, dispatch table registration, and output handler.
- **Source Modified**: `source/features/cli.asm` (`about_cmd`, `print_about`, `about_string`).
- **Validation**: Verified in QEMU; captured screenshot `assets/screenshots/04_about_command.png`.

### Milestone 05: 16-Bit Freestanding C Application Integration
- **Objective**: Compile freestanding C binary linked at `0x8000` executing real-mode integer calculations.
- **Source Added**: `c_src/examples/grades.c` -> `programs/GRADES.BIN`.
- **Validation**: Verified in QEMU; captured screenshot `assets/screenshots/05_grades_c_app.png`.

### Milestone 06: Rich System Information Display in C
- **Objective**: Query hardware and operating system parameters from C via system call vectors and BIOS interrupts.
- **Source Modified**: `c_src/examples/gmuinfo.c` (queries BIOS RAM INT 12h, CMOS RTC time/date, segment registers).
- **Validation**: Source validated; GCC `-m16` compile validated; pending integrated multi-binary QEMU capture.

### Milestone 07: Enhanced FAT12 File Listing (`DIR`)
- **Objective**: Direct FAT12 root-directory parser with balanced 2-column display, 10-digit size alignment, and file count summary.
- **Source Modified**: `source/features/cli.asm` (direct traversal of sectors 19–32, 61-col maximum width).
- **Validation**: Verified in QEMU; captured screenshot `assets/screenshots/07_dir_listing.png`.

### Milestones 08–10: In Progress & Upcoming
- **Milestone 08**: Implement extended system call vectors in `source/kernel.asm` and map corresponding C ABI wrappers in `c_src/include/gmuos.h`.
- **Milestone 09**: Disk subsystem optimizations and boundary-checked sector streaming.
- **Milestone 10**: Capstone individual OS extension, integrated testing, and formal PBL submission.

