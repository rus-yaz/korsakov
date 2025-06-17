; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

raw_string "Сравнение", 10, 10
print_raw rax

include "is_equal.asm"

raw_string 10
print_raw rax

include "is_not_equal.asm"

raw_string 10
print_raw rax

include "is_lower.asm"

raw_string 10
print_raw rax

include "is_greater.asm"

raw_string 10
print_raw rax

include "is_lower_or_equal.asm"

raw_string 10
print_raw rax

include "is_greater_or_equal.asm"
