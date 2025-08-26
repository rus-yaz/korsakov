; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function input
; @description Читает строку из стандартного ввода с возможностью вывода приглашения
; @param string=0 - приглашение для вывода
; @return Прочитанная строка
; @example
;   input  ; читает строку без приглашения
;   string "Введите имя: "
;   input rax  ; выводит приглашение и читает строку
f_input:
  get_arg 0
  mov rbx, rax

  cmp rbx, 0
  jne .not_default_output
    string ""
    mov rbx, rax
  .not_default_output:

  check_type rbx, STRING

  string ""
  mov rcx, rax
  list
  list_append rax, rbx
  print rax, rcx, rcx
  delete rax, rcx

  push 0
  mov rbx, rsp
  sub rbx, 0x1000
  sys_read STDIN, rbx, 0x1000

  buffer_to_string rbx
  mov rbx, rax
  string_pop_link rbx

  add rsp, 8
  mov rax, rbx

  ret
