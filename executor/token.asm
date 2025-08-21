; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

macro token_check_type token*, types* {
  debug_start "token_check_type"
  enter token, types

  call f_token_check_type

  return
  debug_end "token_check_type"
}

macro token_check_keyword token*, keywords* {
  debug_start "token_check_keyword"
  enter token, keywords

  call f_token_check_keyword

  return
  debug_end "token_check_keyword"
}

f_token_check_type:
  get_arg 1
  mov rbx, rax
  get_arg 0
  ; RAX — token
  ; RBX — types

  check_type rax, DICTIONARY

  dictionary_get rax, [тип]
  mov rcx, rax

  mov rdx, [rbx]
  cmp rdx, LIST
  je .list

    list
    list_append rax, rbx
    mov rbx, rax

  .list:

  integer 0
  mov r8, rax

  list_length rbx
  integer rax
  mov r9, rax

  .while:
    is_equal r9, r8
    boolean_value rax
    cmp rax, 1
    je .return_false

    list_get rbx, r8
    is_equal rax, rcx
    boolean_value rax
    cmp rax, 1
    je .end_while

    integer_inc r8
    jmp .while

  .return_false:
  mov rax, 0

  .end_while:
  ret

f_token_check_keyword:
  get_arg 1
  mov rbx, rax
  get_arg 0
  ; RAX — token
  ; RBX — keywords

  check_type rax, DICTIONARY
  dictionary_get rax, [значение]
  mov rcx, rax

  mov rdx, [rbx]
  cmp rdx, LIST
  je .list
    list
    list_append rax, rbx
    mov rbx, rax

  .list:

  integer 0
  mov r8, rax

  list_length rbx
  integer rax
  mov r9, rax

  .while:

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get rbx, r8
    is_equal rax, rcx
    boolean_value rax
    cmp rax, 1
    jmp .end_while

    integer_inc r9
    jmp .while

  .end_while:
  ret
