/*
 * GMU OS 0.1 - Interactive Student Grade Calculator 2.0
 *
 * Course: UE25CS2304 -- Operating System with Practice (PBL)
 * Target: 16-bit Freestanding x86 Real Mode
 * File:   c_src/examples/grades2.c
 *
 * Description:
 *   Interactive academic performance calculator allowing user entry of
 *   student name, subject count (1-10), subject names, maximum marks,
 *   and obtained marks. Computes total marks, overall percentage,
 *   individual subject percentages, individual grades, overall grade,
 *   and academic result (PASS/FAIL) using pure integer arithmetic.
 */

#include "gmuos.h"

#define MAX_SUBJECTS 10
#define NAME_SIZE    32
#define SUBJECT_SIZE 28
#define INPUT_SIZE   32

struct Subject {
    char name[SUBJECT_SIZE];
    int obtained;
    int maximum;
};

/* Global BSS variables (must be explicitly cleared because loader does not clear BSS) */
static struct Subject subjects[MAX_SUBJECTS];
static char student[NAME_SIZE];
static char input[INPUT_SIZE];

/* Explicit BSS initialization function */
static void initialize_data(void)
{
    int i;

    for (i = 0; i < MAX_SUBJECTS; i++) {
        subjects[i].name[0] = '\0';
        subjects[i].obtained = 0;
        subjects[i].maximum = 0;
    }

    for (i = 0; i < NAME_SIZE; i++)
        student[i] = '\0';

    for (i = 0; i < INPUT_SIZE; i++)
        input[i] = '\0';
}

/* Print a positive or zero long integer without hosted libraries */
static void print_int(long n)
{
    char buffer[12];
    int i = 0;

    if (n == 0) {
        gmu_print_char('0');
        return;
    }

    if (n < 0) {
        gmu_print_char('-');
        n = -n;
    }

    while (n > 0 && i < 11) {
        buffer[i++] = (char)('0' + (n % 10));
        n /= 10;
    }

    while (i > 0)
        gmu_print_char(buffer[--i]);
}

/* Read a line from keyboard with Enter (13) and Backspace (8/127) support */
static void read_line(char *buffer, int limit)
{
    int length = 0;

    while (1) {
        gmu_u16 key = gmu_wait_key();
        char c = (char)(key & 0xFF);

        if (c == 13) {
            buffer[length] = '\0';
            gmu_newline();
            return;
        }

        if (c == 8 || c == 127) {
            if (length > 0) {
                length--;
                gmu_print_char(8);
                gmu_print_char(' ');
                gmu_print_char(8);
            }
            continue;
        }

        if (c >= 32 && c <= 126 && length < limit - 1) {
            buffer[length++] = c;
            gmu_print_char(c);
        }
    }
}

/* Read an integer with validation: rejects empty, alphabetic, negative, out-of-range */
static long read_number(const char *prompt, long minimum, long maximum)
{
    while (1) {
        long value = 0;
        int valid = 1;
        int i;

        gmu_print(prompt);
        read_line(input, INPUT_SIZE);

        if (input[0] == '\0') {
            valid = 0;
        } else {
            for (i = 0; input[i] != '\0'; i++) {
                if (input[i] < '0' || input[i] > '9') {
                    valid = 0;
                    break;
                }

                long digit = (long)(input[i] - '0');

                /* Safe overflow check before multiplication */
                if (value > (maximum - digit) / 10) {
                    valid = 0;
                    break;
                }

                value = value * 10 + digit;
            }
        }

        if (valid && value >= minimum && value <= maximum)
            return value;

        gmu_print("  Invalid input. Enter a value between ");
        print_int(minimum);
        gmu_print(" and ");
        print_int(maximum);
        gmu_print(".");
        gmu_newline();
    }
}

static void wait_return(void)
{
    gmu_newline();
    gmu_print("Press any key to continue...");
    (void)gmu_wait_key();
    gmu_newline();
}

/* Illustrative grading thresholds */
static const char *get_grade(int percentage)
{
    if (percentage >= 90) return "A+ (Outstanding)";
    if (percentage >= 80) return "A  (Excellent)";
    if (percentage >= 70) return "B+ (Very Good)";
    if (percentage >= 60) return "B  (Good)";
    if (percentage >= 50) return "C  (Pass)";
    return "F  (Fail)";
}

/* Perform interactive data entry, computation, and results display */
static void calculate_result(void)
{
    int count;
    long total_obtained = 0;
    long total_maximum = 0;
    long overall_percentage = 0;
    int passed = 1;
    int i;

    gmu_clear();

    gmu_print("======================================================================");
    gmu_newline();
    gmu_print("                  GMU GRADE CALCULATOR 2.0 (CSE)");
    gmu_newline();
    gmu_print("======================================================================");
    gmu_newline();
    gmu_print("Course: UE25CS2304 -- Operating System with Practice (PBL)");
    gmu_newline();
    gmu_print("Notice: Interactive academic evaluator with illustrative grade scale.");
    gmu_newline();
    gmu_print("----------------------------------------------------------------------");
    gmu_newline();

    /* 1. Enter student name with non-empty validation */
    while (1) {
        gmu_print("Student Name: ");
        read_line(student, NAME_SIZE);
        if (student[0] != '\0')
            break;
        gmu_print("  Student name cannot be empty. Please enter student name.");
        gmu_newline();
    }

    /* 2. Enter number of subjects */
    count = (int)read_number("Number of subjects (1-10): ", 1, MAX_SUBJECTS);
    gmu_newline();

    /* 3. Enter subject details */
    for (i = 0; i < count; i++) {
        gmu_print("--- Subject ");
        print_int(i + 1);
        gmu_print(" of ");
        print_int(count);
        gmu_print(" ---");
        gmu_newline();

        while (1) {
            gmu_print("  Subject Name: ");
            read_line(subjects[i].name, SUBJECT_SIZE);
            if (subjects[i].name[0] != '\0')
                break;
            gmu_print("  Subject name cannot be empty. Please enter name.");
            gmu_newline();
        }

        subjects[i].maximum = (int)read_number("  Maximum marks (1-10000): ", 1, 10000);
        subjects[i].obtained = (int)read_number("  Obtained marks (0-max) : ", 0, subjects[i].maximum);

        total_obtained += subjects[i].obtained;
        total_maximum += subjects[i].maximum;

        /* Individual subject pass threshold: >= 40% */
        if ((long)subjects[i].obtained * 100L < (long)subjects[i].maximum * 40L)
            passed = 0;

        gmu_newline();
    }

    /* 4. Overall percentage calculation with zero-denominator protection */
    if (total_maximum > 0)
        overall_percentage = (total_obtained * 100L) / total_maximum;

    /* 5. Render Results Table */
    gmu_clear();

    gmu_print("======================================================================");
    gmu_newline();
    gmu_print("             STUDENT ACADEMIC PERFORMANCE REPORT");
    gmu_newline();
    gmu_print("======================================================================");
    gmu_newline();
    gmu_print("Student Name : ");
    gmu_print(student);
    gmu_newline();
    gmu_print("Notice       : Illustrative thresholds (Subject pass: >=40%, Overall: >=50%)");
    gmu_newline();
    gmu_print("----------------------------------------------------------------------");
    gmu_newline();
    gmu_print("SUBJECT EVALUATION:");
    gmu_newline();

    for (i = 0; i < count; i++) {
        long subj_pct = 0;
        if (subjects[i].maximum > 0)
            subj_pct = ((long)subjects[i].obtained * 100L) / (long)subjects[i].maximum;

        gmu_print("  [");
        print_int(i + 1);
        gmu_print("] ");
        gmu_print(subjects[i].name);
        gmu_print(": ");
        print_int(subjects[i].obtained);
        gmu_print("/");
        print_int(subjects[i].maximum);
        gmu_print(" (");
        print_int(subj_pct);
        gmu_print("%)  Grade: ");
        gmu_print(get_grade((int)subj_pct));

        if (subj_pct < 40)
            gmu_print("  [FAILED]");
        else
            gmu_print("  [PASSED]");

        gmu_newline();
    }

    gmu_print("----------------------------------------------------------------------");
    gmu_newline();
    gmu_print("PERFORMANCE SUMMARY:");
    gmu_newline();

    gmu_print("  Total Marks : ");
    print_int(total_obtained);
    gmu_print(" / ");
    print_int(total_maximum);
    gmu_newline();

    gmu_print("  Percentage  : ");
    print_int(overall_percentage);
    gmu_print("%");
    gmu_newline();

    gmu_print("  Grade       : ");
    gmu_print(get_grade((int)overall_percentage));
    gmu_newline();

    gmu_print("  Result      : ");
    if (passed && overall_percentage >= 50)
        gmu_print("PASSED");
    else
        gmu_print("FAILED");
    gmu_newline();

    gmu_print("======================================================================");
    gmu_newline();

    wait_return();
}

__attribute__((used, noinline))
void gmu_main(void)
{
    int again = 1;

    while (again) {
        /* Explicitly clear BSS data at start of each calculation session */
        initialize_data();

        calculate_result();

        gmu_newline();
        gmu_print("Calculate another result? (Y/N): ");

        while (1) {
            gmu_u16 key = gmu_wait_key();
            char c = (char)(key & 0xFF);

            if (c == 'Y' || c == 'y') {
                again = 1;
                gmu_print_char(c);
                gmu_newline();
                break;
            }

            if (c == 'N' || c == 'n') {
                again = 0;
                gmu_print_char(c);
                gmu_newline();
                break;
            }
        }
    }

    gmu_newline();
    gmu_print("Returning to GMU OS...");
    gmu_newline();
}

GMU_C_ENTRY(gmu_main)
