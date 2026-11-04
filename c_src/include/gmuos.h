/*
 * GMU OS - small C interface for the MikeOS 4.7.0 execution environment
 *
 * GMU modifications: 2026, GM University, Davanagere.
 * Base OS: MikeOS 4.7.0 (Copyright 2006-2022 MikeOS Developers).
 * The original MikeOS license is retained in doc/LICENSE.TXT.
 *
 * Why there is a tiny amount of inline assembly here:
 * MikeOS exposes kernel services at fixed 16-bit offsets. C code can use
 * those services, but a few machine instructions are required to place
 * arguments in the exact registers expected by the original ABI.
 * Student-facing applications can otherwise remain in C.
 */
#ifndef GMUOS_H
#define GMUOS_H

typedef unsigned char  gmu_u8;
typedef unsigned short gmu_u16;
typedef unsigned int   gmu_u32;

/* MikeOS API vector offsets (API v18). */
#define GMU_OS_PRINT_STRING   0x0003u
#define GMU_OS_CLEAR_SCREEN   0x0009u
#define GMU_OS_PRINT_NEWLINE  0x000Fu
#define GMU_OS_WAIT_FOR_KEY   0x0012u
#define GMU_OS_GET_API_VER    0x0057u
#define GMU_OS_GET_TIME_STR   0x0054u
#define GMU_OS_GET_DATE_STR   0x005Du

/* Convert a linked C pointer (programs are linked at 0x8000) to the
 * 16-bit offset used inside the common MikeOS/GMU OS segment. */
static inline gmu_u16 gmu_offset(const void *p)
{
    return (gmu_u16)((gmu_u32)p & 0xFFFFu);
}

/* Print a single character directly to the active screen using BIOS teletype */
static inline void gmu_print_char(char c)
{
    gmu_u16 ax_val = (gmu_u16)(0x0e00u | (gmu_u8)c);
    __asm__ volatile (
        "int $0x10"
        :
        : "a" (ax_val), "b" ((gmu_u16)0x0007u)
        : "cc"
    );
}

static inline void gmu_print(const char *text)
{
    gmu_u16 off = gmu_offset(text);
    __asm__ volatile (
        "movw $0x0003, %%bx\n\t"
        "callw *%%bx"
        :
        : "S" (off)
        : "ax", "bx", "cx", "dx", "di", "cc", "memory"
    );
}

static inline void gmu_newline(void)
{
    __asm__ volatile (
        "movw $0x000f, %%bx\n\t"
        "callw *%%bx"
        : : : "ax", "bx", "cx", "dx", "si", "di", "cc", "memory"
    );
}

static inline void gmu_clear(void)
{
    __asm__ volatile (
        "movw $0x0009, %%bx\n\t"
        "callw *%%bx"
        : : : "ax", "bx", "cx", "dx", "si", "di", "cc", "memory"
    );
}

static inline gmu_u16 gmu_wait_key(void)
{
    gmu_u16 key;
    __asm__ volatile (
        "movw $0x0012, %%bx\n\t"
        "callw *%%bx"
        : "=a" (key)
        :
        : "bx", "cx", "dx", "si", "di", "cc", "memory"
    );
    return key;
}

/* C program entry helper.
 * MikeOS loads .BIN programs at offset 0x8000 and invokes them with a
 * 16-bit CALL. GCC -m16 generated C functions use a 32-bit stack model.
 * In MikeOS, the kernel runs with SS=0x0000 while DS=0x2000. C programs
 * expect SS == DS (a unified segment) so that pointers to stack variables
 * and pointers to static/string data share the same segment.
 * This entry stub saves the OS stack (SS:SP), initializes SS to match DS,
 * sets ESP to 0xFFF0 (top of segment), calls the C main function with a
 * 32-bit call, restores the OS stack, and returns cleanly with a 16-bit RET.
 */
#define GMU_C_ENTRY(main_function) \
    __attribute__((used)) static gmu_u16 __gmu_saved_sp; \
    __attribute__((used)) static gmu_u16 __gmu_saved_ss; \
    __attribute__((naked, section(".text.start"), used)) \
    void _start(void) { \
        __asm__ volatile ( \
            "movw %%sp, %0\n\t" \
            "movw %%ss, %1\n\t" \
            "movw %%ds, %%ax\n\t" \
            "cli\n\t" \
            "movw %%ax, %%ss\n\t" \
            "movl $0x0000fff0, %%esp\n\t" \
            "sti\n\t" \
            "calll " #main_function "\n\t" \
            "cli\n\t" \
            "movw %1, %%ss\n\t" \
            "movw %0, %%sp\n\t" \
            "sti\n\t" \
            "retw\n\t" \
            : "=m" (__gmu_saved_sp), "=m" (__gmu_saved_ss) \
            : \
            : "ax", "memory" \
        ); \
    }

#endif /* GMUOS_H */
