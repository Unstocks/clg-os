#!/bin/sh
# Build GMU OS C applications with a GCC toolchain that supports -m16.
# This builds ONLY the C applications. The base OS is still built by the
# original MikeOS NASM scripts.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CC=${CC:-gcc}
LD=${LD:-ld}
CFLAGS="-m16 -march=i386 -ffreestanding -fno-pic -fno-pie -fno-stack-protector -fno-asynchronous-unwind-tables -fomit-frame-pointer -Os -nostdlib -Wall -Wextra"
mkdir -p "$ROOT/c_src/build"
for src in "$ROOT"/c_src/examples/*.c; do
    name=$(basename "$src" .c)
    obj="$ROOT/c_src/build/$name.o"
    bin="$ROOT/c_src/build/$(echo "$name" | tr '[:lower:]' '[:upper:]').BIN"
    echo ">>> C compile: $(basename "$src")"
    "$CC" $CFLAGS -I"$ROOT/c_src/include" -c "$src" -o "$obj"
    "$LD" -m elf_i386 -T "$ROOT/c_src/gmu16.ld" -o "$bin" "$obj"
    cp "$bin" "$ROOT/programs/"
    echo "    created: $bin"
done

CALC_DIR="$ROOT/c_src/scientific_calc"
CALC_UI_OBJ="$ROOT/c_src/build/scientific_calc.o"
CALC_MATH_OBJ="$ROOT/c_src/build/math.o"
CALC_BIN="$ROOT/c_src/build/SCICALC.BIN"
echo '>>> C compile: scientific_calc.c'
"$CC" $CFLAGS -I"$ROOT/c_src/include" -I"$CALC_DIR" \
    -c "$CALC_DIR/scientific_calc.c" -o "$CALC_UI_OBJ"
echo '>>> C compile: math.c'
"$CC" $CFLAGS -I"$ROOT/c_src/include" -I"$CALC_DIR" \
    -c "$CALC_DIR/math.c" -o "$CALC_MATH_OBJ"
"$LD" -m elf_i386 -T "$ROOT/c_src/gmu16.ld" -o "$CALC_BIN" \
    "$CALC_UI_OBJ" "$CALC_MATH_OBJ"
cp "$CALC_BIN" "$ROOT/programs/"
cp "$CALC_BIN" "$ROOT/c_src/prebuilt/SCICALC.BIN" 2>/dev/null || true
cp "$CALC_BIN" "$ROOT/programs/SCIENTIFIC_CALC.BIN" 2>/dev/null || true
echo "    created: $CALC_BIN (and programs/SCICALC.BIN)"
printf '%s\n' '>>> GMU OS C applications built and copied to programs/'
