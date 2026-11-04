# GMU OS 0.1 — Command Reference

> **Shell Interface**: 80x25 Real-Mode Teletype CLI  
> **Prompt**: `GMUOS> `  
> **Command Parsing**: Case-insensitive 256-byte buffer tokenized by whitespace  

---

## 1. Built-in CLI Commands

### 1.1 Help & Information Commands

#### `HELP`
* **Syntax**: `HELP`
* **Description**: Displays a categorized overview of built-in commands and application execution guidelines.
* **Output Example**:
  ```text
  GMU OS 0.1 Commands:
    Files:  DIR, LS, CAT, COPY, REN, DEL, SIZE
    System: CLS, HELP, ABOUT, VER, TIME, DATE, EXIT
    Launch: Type a program name (.BIN or .BAS)
  ```

#### `ABOUT`
* **Syntax**: `ABOUT`
* **Description**: Displays architectural metadata, execution addresses, and university course information.
* **Output Example**:
  ```text
  GMU OS 0.1 -- C-Oriented Learning Derivative
  Base Kernel: MikeOS 4.7.0 (16-bit x86 Real Mode)
  Kernel Load: 0x2000:0000 (Physical 0x20000)
  Course: UE25CS2304 -- Operating System with Practice
  ```

#### `VER`
* **Syntax**: `VER`
* **Description**: Displays the kernel version string.
* **Output**: `GMU OS 0.1 (Base: MikeOS 4.7.0)`

#### `TIME`
* **Syntax**: `TIME`
* **Description**: Queries the CMOS Real-Time Clock (RTC) via kernel vector `0x0054` and prints current time in `HH:MM:SS` format.

#### `DATE`
* **Syntax**: `DATE`
* **Description**: Queries the CMOS RTC via kernel vector `0x005D` and prints current date in `YYYY/MM/DD` format.

---

### 1.2 File Management Commands

#### `DIR` (Enhanced 2-Column Listing)
* **Syntax**: `DIR`
* **Description**: Parses the FAT12 root directory (sectors 19–32) directly into `disk_buffer` (`0x6000`), filtering out system entries, subdirectories, volume labels, and deleted records. Renders an aligned two-column table with 10-digit decimal file sizes and a total file count summary.
* **Output Example**:
  ```text
    Filename            Size (B)   |   Filename            Size (B)
  ------------------------------   +   ----------------------------
    KERNEL.BIN           21149 B   |   SCICALC.BIN          3890 B
    GRADES2.BIN           2410 B   |   GMUINFO.BIN           548 B
  -----------------------------------------------------------------
  Total: 4 file(s) found.
  ```

#### `LS`
* **Syntax**: `LS`
* **Description**: Compact multi-column filename listing (legacy MikeOS directory display).

#### `CAT <filename>`
* **Syntax**: `CAT <filename>`
* **Description**: Displays the text contents of the specified file on the console screen.
* **Example**: `CAT GMU_OS.TXT`

#### `COPY <source> <dest>`
* **Syntax**: `COPY <source> <dest>`
* **Description**: Duplicates a file on the floppy disk.

#### `REN <oldname> <newname>`
* **Syntax**: `REN <oldname> <newname>`
* **Description**: Renames an existing file in the FAT12 root directory.

#### `DEL <filename>`
* **Syntax**: `DEL <filename>`
* **Description**: Deletes a file by setting its first directory byte to `0xE5` and freeing clusters in the FAT.

#### `SIZE <filename>`
* **Syntax**: `SIZE <filename>`
* **Description**: Reports the exact byte size of a specified file.

---

### 1.3 System Control Commands

#### `CLS`
* **Syntax**: `CLS`
* **Description**: Clears the 80x25 text screen and moves the hardware cursor to (0,0).

#### `EXIT`
* **Syntax**: `EXIT`
* **Description**: Reboots the machine via BIOS warm restart (jumping to `0xFFFF:0000`).

---

## 2. Executable Applications

Programs in GMU OS are executed by typing their full 8.3 filename at the `GMUOS> ` prompt.

### 2.1 C Applications (`0x8000`)

| Executable | Source Path | Description | Interactive Controls |
| :--- | :--- | :--- | :--- |
| `SCICALC.BIN` | `c_src/scientific_calc/` | Scientific calculator with Taylor series trig | Keypad commands (`+`, `-`, `*`, `/`, `sin`, `cos`, etc.) |
| `GRADES2.BIN` | `c_src/examples/grades2.c` | Interactive grade calculator with manual BSS zeroing | Name entry, subject count (1–10), marks validation |
| `GRADES.BIN` | `c_src/examples/grades.c` | Static academic grade analyzer demo | Any key to return to shell |
| `GMUINFO.BIN` | `c_src/examples/gmuinfo.c` | Hardware telemetry & CMOS RTC display | Any key to return to shell |

### 2.2 Assembly & BASIC Programs

| Executable | Description |
| :--- | :--- |
| `CALC.BIN` | Real-mode assembly calculator |
| `VEDIT.BIN` | Full-screen text editor with keyboard shortcuts |
| `VIEWER.BIN` | File viewer for text documents |
| `MONITOR.BIN` | Machine-language monitor and memory inspector |
| `SUDOKU.BAS` | BASIC-language Sudoku game |
| `MUNCHER.BAS` | Arcade game executed via built-in BASIC interpreter |

