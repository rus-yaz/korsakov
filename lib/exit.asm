; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_program_exit:
  get_arg 0
  cmp rax, 0
  jne @f
    integer 0
  @@:

  check_type rax, INTEGER

  mov rax, [rax + INTEGER_HEADER*8]
  sys_exit rax
