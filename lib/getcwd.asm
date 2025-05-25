; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_getcwd:
  sub rsp, MAX_PATH_LENGTH
  mov rax, rsp
  sys_getcwd rax, MAX_PATH_LENGTH

  cmp rax, 0
  jg .correct

    string "Не удалось получить рабочую директорию"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct:

  mov rax, rsp
  buffer_to_string rax
  add rsp, MAX_PATH_LENGTH

  ret
