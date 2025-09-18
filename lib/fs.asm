; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function readlink
; @description Читает содержимое символической ссылки
; @param path - путь к символической ссылке
; @return Содержимое символической ссылки
; @example
;   string "/path/to/link"
;   readlink rax  ; читает содержимое символической ссылки
_function readlink, rbx, r11
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING
  string_to_binary rbx

  add rax, BINARY_HEADER*8
  mov rbx, rax

  sub rsp, MAX_PATH_LENGTH
  mov rax, rsp
  push r11
  sys_readlink rbx, rax, MAX_PATH_LENGTH
  pop r11

  cmp rax, 0
  jg .correct

    string "Не удалось прочитать ссылку"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct:

  add rax, rsp
  mov byte [rax], 0

  mov rax, rsp
  buffer_to_string rax
  add rsp, MAX_PATH_LENGTH

  ret
