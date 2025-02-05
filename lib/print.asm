; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_print:
  mov rbx, 0

  list
  mov rcx, rax

  .while:
    get_arg rbx
    cmp rax, 0
    je .end_while

    mov rdx, [rax]
    cmp rdx, STRING
    je .string
      to_string rax

    .string:

    list_append_link rcx, rax

    inc rbx
    jmp .while

  .end_while:

  inc rbx
  get_arg rbx

  cmp rax, 0
  jne .not_default_separator

    mov rax, " "

  .not_default_separator:

  join rcx, rax
  delete_block [rcx + 8*3], rcx
  mov rcx, rax

  inc rbx
  get_arg rbx

  cmp rax, 0
  jne .not_default_end_of_string

    string 10

  .not_default_end_of_string:

  string_extend_links rcx, rax
  mov rdx, rax

  string_to_binary rcx
  mov rcx, rax

  binary_length rcx

  mov rbx, rcx
  add rbx, 8*2

  sys_print rbx, rax
  delete rcx, rdx

  ret
