"""
GMU OS Scientific Calculator - Local Preview
Author: Sanjayakumar S H, CSE (AI-BC-BS)
GM University, Davanagere
"""
import sys
import math

try:
    import msvcrt
    def gmu_wait_key():
        # Wait for a single character on Windows
        ch = msvcrt.getch()
        try:
            return ch.decode('utf-8')
        except:
            return ''
except ImportError:
    import termios
    import tty
    def gmu_wait_key():
        # Wait for a single character on Unix / Linux / Ubuntu
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(fd)
            ch = sys.stdin.read(1)
            if ch == '\r' or ch == '\n':
                return '\r'
            return ch
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

def gmu_print(text):
    sys.stdout.write(text)
    sys.stdout.flush()

def gmu_newline():
    sys.stdout.write("\r\n")
    sys.stdout.flush()

def gmu_clear():
    # Simulate a screen clear
    sys.stdout.write("\033[2J\033[H")
    sys.stdout.flush()

def print_char(c):
    gmu_print(c)

def read_float():
    val = 0.0
    frac_div = 1.0
    in_frac = False
    neg = False
    
    while True:
        k = gmu_wait_key()
        
        if k == '\r' or k == '\n':
            gmu_newline()
            break
            
        if k == '-':
            if val == 0.0 and not in_frac:
                neg = True
                print_char('-')
        elif k == '.':
            if not in_frac:
                in_frac = True
                print_char('.')
        elif k >= '0' and k <= '9':
            print_char(k)
            if in_frac:
                frac_div *= 10.0
                val += int(k) / frac_div
            else:
                val = val * 10.0 + int(k)
                
    return -val if neg else val

def print_float(f):
    # This replicates our C implementation exactly:
    if f < 0:
        gmu_print("-")
        f = -f
        
    i = int(f)
    frac = f - float(i)
    
    # Integer part
    gmu_print(str(i))
    
    # Fractional part
    gmu_print(".")
    for _ in range(4):
        frac *= 10.0
        d = int(frac)
        if d > 9: d = 9
        if d < 0: d = 0
        gmu_print(str(d))
        frac -= float(d)

def show_menu():
    gmu_clear()
    gmu_print("========================================\r\n")
    gmu_print("          GMU SCIENTIFIC CALCULATOR\r\n")
    gmu_print("========================================\r\n\r\n")
    gmu_print("1. Basic arithmetic (+, -, *, /)\r\n")
    gmu_print("2. Scientific functions (sin, cos, tan, sec, cosec, cot)\r\n")
    gmu_print("Q. Quit\r\n\r\n")
    gmu_print("Select an option: ")

def do_basic_arithmetic():
    gmu_newline()
    gmu_print("Enter first number: ")
    a = read_float()
    
    gmu_print("Enter operator (+, -, *, /): ")
    op = ''
    while op not in ['+', '-', '*', '/']:
        op = gmu_wait_key()
    print_char(op)
    gmu_newline()
    
    gmu_print("Enter second number: ")
    b = read_float()
    
    res = 0.0
    if op == '+': res = a + b
    elif op == '-': res = a - b
    elif op == '*': res = a * b
    elif op == '/':
        if b != 0.0:
            res = a / b
        else:
            gmu_print("Error: Div by zero!\r\n")
            return
            
    gmu_print("Result = ")
    print_float(res)
    gmu_newline()

# Simulating the C Taylor series math implementation
def gmu_sin(degrees):
    return math.sin(math.radians(degrees))

def gmu_cos(degrees):
    return math.cos(math.radians(degrees))

def gmu_tan(degrees):
    c = math.cos(math.radians(degrees))
    if abs(c) < 0.0001: return None
    return math.tan(math.radians(degrees))

def gmu_sec(degrees):
    c = math.cos(math.radians(degrees))
    if abs(c) < 0.0001: return None
    return 1.0 / c

def gmu_cosec(degrees):
    s = math.sin(math.radians(degrees))
    if abs(s) < 0.0001: return None
    return 1.0 / s

def gmu_cot(degrees):
    s = math.sin(math.radians(degrees))
    c = math.cos(math.radians(degrees))
    if abs(s) < 0.0001: return None
    return c / s

def print_exact_trig(res):
    abs_res = abs(res)
    eps = 0.005
    
    if abs_res < eps:
        gmu_print("0")
    elif abs_res > 1.0 - eps and abs_res < 1.0 + eps:
        gmu_print("-1" if res < 0 else "1")
    elif abs_res > 0.5 - eps and abs_res < 0.5 + eps:
        gmu_print("-1/2" if res < 0 else "1/2")
    elif abs_res > 2.0 - eps and abs_res < 2.0 + eps:
        gmu_print("-2" if res < 0 else "2")
    elif abs_res > 0.7071 - eps and abs_res < 0.7071 + eps:
        gmu_print("-sqrt(2)/2" if res < 0 else "sqrt(2)/2")
    elif abs_res > 1.4142 - eps and abs_res < 1.4142 + eps:
        gmu_print("-sqrt(2)" if res < 0 else "sqrt(2)")
    elif abs_res > 0.8660 - eps and abs_res < 0.8660 + eps:
        gmu_print("-sqrt(3)/2" if res < 0 else "sqrt(3)/2")
    elif abs_res > 1.1547 - eps and abs_res < 1.1547 + eps:
        gmu_print("-2/sqrt(3)" if res < 0 else "2/sqrt(3)")
    elif abs_res > 0.5773 - eps and abs_res < 0.5773 + eps:
        gmu_print("-1/sqrt(3)" if res < 0 else "1/sqrt(3)")
    elif abs_res > 1.7320 - eps and abs_res < 1.7320 + eps:
        gmu_print("-sqrt(3)" if res < 0 else "sqrt(3)")
    else:
        print_float(res)

def do_scientific_functions():
    gmu_newline()
    gmu_print("Select function:\r\n")
    gmu_print("  1) sin   2) cos   3) tan\r\n")
    gmu_print("  4) sec   5) cosec 6) cot\r\n")
    gmu_print("Choice (1-6): ")
    
    func = ''
    while func not in ['1', '2', '3', '4', '5', '6']:
        func = gmu_wait_key()
    print_char(func)
    gmu_newline()
    
    gmu_print("Enter angle in degrees: ")
    angle = read_float()
    
    gmu_print("Result = ")
    res = None
    if func == '1':
        res = gmu_sin(angle)
    elif func == '2':
        res = gmu_cos(angle)
    elif func == '3':
        res = gmu_tan(angle)
    elif func == '4':
        res = gmu_sec(angle)
    elif func == '5':
        res = gmu_cosec(angle)
    elif func == '6':
        res = gmu_cot(angle)
        
    if res is None:
        gmu_print("Undefined (Infinity)")
    else:
        print_exact_trig(res)
    gmu_newline()

def main():
    while True:
        show_menu()
        key = gmu_wait_key()
        
        if key == '1':
            do_basic_arithmetic()
            gmu_print("Press any key to return to the menu...")
            gmu_wait_key()
        elif key == '2':
            do_scientific_functions()
            gmu_print("Press any key to return to the menu...")
            gmu_wait_key()
        elif key.lower() == 'q':
            gmu_clear()
            break

if __name__ == "__main__":
    main()
