/*
 * Scientific calculator for GMU OS.
 *
 * Implements basic arithmetic and scientific math functions.
 * Author: Sanjayakumar S H, CSE (AI-BC-BS)
 * GM University, Davanagere.
 */
#include "gmuos.h"
#include "math.h"

/* Helper to print a single character using direct BIOS teletype */
static void print_char(char c)
{
	gmu_print_char(c);
}

/* Helper to print a float number */
static void print_float(float f)
{
	if (f < 0.0f) {
		gmu_print_char('-');
		f = -f;
	}
	
	/* Integer part */
	int i = (int)f;
	float frac = f - (float)i;
	
	char buf[16];
	int pos = 0;
	if (i == 0) {
		buf[pos++] = '0';
	} else {
		while (i > 0) {
			buf[pos++] = '0' + (i % 10);
			i /= 10;
		}
	}
	
	/* Print integer part digits in correct order */
	for (int j = pos - 1; j >= 0; j--) {
		gmu_print_char(buf[j]);
	}
	
	/* Fractional part */
	gmu_print_char('.');
	for (int j = 0; j < 4; j++) {
		frac *= 10.0f;
		int d = (int)frac;
		if (d > 9) d = 9;
		if (d < 0) d = 0;
		gmu_print_char('0' + d);
		frac -= (float)d;
	}
}

/* Helper to read a float number from keyboard with immediate screen echo */
static float read_float(void)
{
	float val = 0.0f;
	float frac_div = 1.0f;
	int in_frac = 0;
	int neg = 0;
	
	for (;;) {
		gmu_u16 k = gmu_wait_key() & 0x00FFu;
		
		/* Enter key (MikeOS returns 13 for Enter, 10 for newline) */
		if (k == 13 || k == 10) {
			gmu_newline();
			break;
		}
		
		if (k == '-') {
			if (val == 0.0f && !in_frac) {
				neg = 1;
				print_char('-');
			}
		} else if (k == '.') {
			if (!in_frac) {
				in_frac = 1;
				print_char('.');
			}
		} else if (k >= '0' && k <= '9') {
			print_char((char)k);
			if (in_frac) {
				frac_div *= 10.0f;
				val += (float)(k - '0') / frac_div;
			} else {
				val = val * 10.0f + (float)(k - '0');
			}
		}
	}
	
	return neg ? -val : val;
}

static void show_menu(void)
{
	gmu_clear();
	gmu_print("========================================");
	gmu_newline();
	gmu_print("          GMU SCIENTIFIC CALCULATOR");
	gmu_newline();
	gmu_print("========================================");
	gmu_newline();
	gmu_newline();
	gmu_print("1. Basic arithmetic (+, -, *, /)");
	gmu_newline();
	gmu_print("2. Scientific functions (sin, cos, tan, sec, cosec, cot)");
	gmu_newline();
	gmu_print("Q. Quit");
	gmu_newline();
	gmu_newline();
	gmu_print("Select an option: ");
}

static void do_basic_arithmetic(void)
{
	gmu_newline();
	gmu_print("Enter first number: ");
	float a = read_float();
	
	gmu_print("Enter operator (+, -, *, /): ");
	char op = '\0';
	while (op != '+' && op != '-' && op != '*' && op != '/') {
		op = (char)(gmu_wait_key() & 0xFF);
	}
	print_char(op);
	gmu_newline();
	
	gmu_print("Enter second number: ");
	float b = read_float();
	
	float res = 0.0f;
	if (op == '+') res = a + b;
	else if (op == '-') res = a - b;
	else if (op == '*') res = a * b;
	else if (op == '/') {
		if (b != 0.0f) res = a / b;
		else {
			gmu_print("Error: Div by zero!");
			gmu_newline();
			return;
		}
	}
	
	gmu_print("Result = ");
	print_float(res);
	gmu_newline();
}

static void print_exact_trig(float res)
{
	float abs_res = res < 0.0f ? -res : res;
	float eps = 0.005f; /* Tolerance for Taylor series approximation */

	if (abs_res < eps) {
		gmu_print("0");
	} else if (abs_res > 1.0f - eps && abs_res < 1.0f + eps) {
		gmu_print(res < 0.0f ? "-1" : "1");
	} else if (abs_res > 0.5f - eps && abs_res < 0.5f + eps) {
		gmu_print(res < 0.0f ? "-1/2" : "1/2");
	} else if (abs_res > 2.0f - eps && abs_res < 2.0f + eps) {
		gmu_print(res < 0.0f ? "-2" : "2");
	} else if (abs_res > 0.7071f - eps && abs_res < 0.7071f + eps) {
		gmu_print(res < 0.0f ? "-sqrt(2)/2" : "sqrt(2)/2");
	} else if (abs_res > 1.4142f - eps && abs_res < 1.4142f + eps) {
		gmu_print(res < 0.0f ? "-sqrt(2)" : "sqrt(2)");
	} else if (abs_res > 0.8660f - eps && abs_res < 0.8660f + eps) {
		gmu_print(res < 0.0f ? "-sqrt(3)/2" : "sqrt(3)/2");
	} else if (abs_res > 1.1547f - eps && abs_res < 1.1547f + eps) {
		gmu_print(res < 0.0f ? "-2/sqrt(3)" : "2/sqrt(3)");
	} else if (abs_res > 0.5773f - eps && abs_res < 0.5773f + eps) {
		gmu_print(res < 0.0f ? "-1/sqrt(3)" : "1/sqrt(3)");
	} else if (abs_res > 1.7320f - eps && abs_res < 1.7320f + eps) {
		gmu_print(res < 0.0f ? "-sqrt(3)" : "sqrt(3)");
	} else {
		print_float(res);
	}
}

static void do_scientific_functions(void)
{
	gmu_newline();
	gmu_print("Select function:");
	gmu_newline();
	gmu_print("  1) sin   2) cos   3) tan");
	gmu_newline();
	gmu_print("  4) sec   5) cosec 6) cot");
	gmu_newline();
	gmu_print("Choice (1-6): ");
	
	char func = '\0';
	while (func < '1' || func > '6') {
		func = (char)(gmu_wait_key() & 0xFF);
	}
	print_char(func);
	gmu_newline();
	
	gmu_print("Enter angle in degrees: ");
	float angle = read_float();
	float res = 0.0f;
	
	gmu_print("Result = ");
	if (func == '1') {
		res = gmu_sin(angle);
		print_exact_trig(res);
	} else if (func == '2') {
		res = gmu_cos(angle);
		print_exact_trig(res);
	} else if (func == '3') {
		res = gmu_tan(angle);
		if (res == GMU_TRIG_UNDEFINED) {
			gmu_print("Undefined (Infinity)");
		} else {
			print_exact_trig(res);
		}
	} else if (func == '4') {
		res = gmu_sec(angle);
		if (res == GMU_TRIG_UNDEFINED) {
			gmu_print("Undefined (Infinity)");
		} else {
			print_exact_trig(res);
		}
	} else if (func == '5') {
		res = gmu_cosec(angle);
		if (res == GMU_TRIG_UNDEFINED) {
			gmu_print("Undefined (Infinity)");
		} else {
			print_exact_trig(res);
		}
	} else if (func == '6') {
		res = gmu_cot(angle);
		if (res == GMU_TRIG_UNDEFINED) {
			gmu_print("Undefined (Infinity)");
		} else {
			print_exact_trig(res);
		}
	}
	gmu_newline();
}

__attribute__((used, noinline))
void gmu_main(void)
{
	gmu_u16 key;

	for (;;) {
		show_menu();
		key = gmu_wait_key() & 0x00FFu;

		if (key == '1') {
			do_basic_arithmetic();
			gmu_print("Press any key to return to the menu...");
			(void)gmu_wait_key();
		} else if (key == '2') {
			do_scientific_functions();
			gmu_print("Press any key to return to the menu...");
			(void)gmu_wait_key();
		} else if (key == 'q' || key == 'Q') {
			gmu_clear();
			break;
		}
	}
}

GMU_C_ENTRY(gmu_main)
