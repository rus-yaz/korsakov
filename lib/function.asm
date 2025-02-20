; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_function:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax
  get_arg 3
  mov r8, rax

  check_type rdx, LIST
  check_type r8, DICTIONARY

  copy rdx
  mov rdx, rax
  copy r8
  mov r8, rax

  create_block FUNCTION_HEADER*8
  mem_mov [rax + 8*0], FUNCTION ; Тип
  mem_mov [rax + 8*1], rbx      ; Имя
  mem_mov [rax + 8*2], rcx      ; Ссылка на функцию
  mem_mov [rax + 8*3], rdx      ; Аргументы
  mem_mov [rax + 8*4], r8       ; Именованные аргументы

  ret

f_function_copy:
  get_arg 0
  mov rbx, rax

  copy [rbx + 8*1]
  mov rcx, rax
  copy [rbx + 8*3]
  mov rdx, rax
  copy [rbx + 8*4]
  mov r8, rax

  create_block FUNCTION_HEADER*8
  mem_mov [rax + 8*0], FUNCTION
  mem_mov [rax + 8*1], rcx
  mem_mov [rax + 8*2], [rbx + 8*2]
  mem_mov [rax + 8*3], rdx
  mem_mov [rax + 8*4], r8

  ret
