; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function program_exit
; @description Завершает выполнение программы с указанным кодом выхода
; @param code=0 - код выхода
; @example
;   program_exit  ; завершает с кодом 0
;   program_exit 1  ; завершает с кодом 1
f_program_exit:
  get_arg 0
  cmp rax, 0
  jne @f
    integer 0
  @@:

  check_type rax, INTEGER

  mov rax, [rax + INTEGER_HEADER*8]
  sys_exit rax
