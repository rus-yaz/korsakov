; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

raw_string "Тест арифметики", 10, 10
print_raw rax

include "addition.asm"

raw_string 10
print_raw rax

include "subtraction.asm"

raw_string 10
print_raw rax

include "multiplication.asm"

raw_string 10
print_raw rax

include "division.asm"

raw_string 10
print_raw rax

include "negate.asm"
