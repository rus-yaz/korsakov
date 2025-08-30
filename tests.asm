; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

include "core/korsakov.asm"

macro test function*, arguments* {
  enter function, arguments
  call f_test
  return
}

start:
  include "core_tests/.asm"

  exit 0

; @function test
; @param function
; @param arguments
_function test, rax, rbx, rcx, rdx, r8, r9, r10, r14, r11, r12, r13, r15
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  mov rdx, 0

  list_length rcx
  mov r8, rax

  dictionary
  mov r9, rax

  list
  mov r10, rax

  @@:
    cmp r8, rdx
    je @f

    integer rdx
    list_get_link rcx, rax

    function_call rbx, rax, r9
    list_append_link r10, rax

    inc rdx
    jmp @b
  @@:

  list
  mov r14, rax

  integer 0
  list_append_link r14, rax

  integer 0
  list_get_link rcx, rax

  list_length rax
  inc rax

  integer rax
  mov r9, rax

  list_mul r14, r9
  mov r14, rax

  mov r8, 0

  list_length r10
  mov r9, rax

  .lengths_while:
    cmp r8, r9
    je .lengths_while_end

    integer r8
    list_get_link rcx, rax
    mov r11, rax

    mov r12, 0

    list_length r11
    mov r13, rax

    @@:
      cmp r12, r13
      je @f

      integer r12
      list_get_link r11, rax
      to_string rax
      string_length rax
      mov r15, rax

      integer r12
      list_get_link r14, rax
      mov rax, [rax + INTEGER_HEADER*8]

      cmp rax, r15
      jg .greater
        integer r15
        mov r15, rax

        integer r12
        list_set_link r14, rax, r15
      .greater:

      inc r12
      jmp @b
    @@:

    inc r8
    jmp .lengths_while
  .lengths_while_end:

  mov r8, 0

  list_length r10
  mov r9, rax

  @@:
    cmp r8, r9
    je @f

    integer r8
    list_get_link r10, rax
    to_string rax
    string_length rax
    mov r12, rax

    integer -1
    list_get_link r14, rax
    mov rax, [rax + INTEGER_HEADER*8]

    cmp rax, r12
    jg .not_lower_or_equal
      integer r12
      mov r12, rax

      integer -1
      list_set_link r14, rax, r12
    .not_lower_or_equal:

    inc r8
    jmp @b
  @@:

  mov r8, 0

  list_length r10
  mov r9, rax

  .while:
    cmp r8, r9
    je .end_while

    integer r8
    list_get_link rcx, rax
    mov r11, rax

    mov r12, 0
    list_length r11
    mov r13, rax

    string "| "
    mov r15, rax

    push rbx, rcx
    .join:
      cmp r12, r13
      je .join_end

      integer r12
      list_get_link r11, rax

      to_string rax
      mov rbx, rax
      string_extend_links r15, rax

      integer r12
      list_get_link r14, rax
      mov rcx, rax

      string_length rbx
      integer rax
      integer_sub rcx, rax
      integer_inc rax
      mov rbx, rax
      string " "
      string_mul rax, rbx
      string_extend_links r15, rax

      inc r12
      jmp .join
    .join_end:
    pop rcx, rbx

    string "| "
    string_extend_links r15, rax

    integer r8
    list_get_link r10, rax
    to_string rax
    string_extend_links r15, rax

    list
    list_append_link rax, r15
    mov r15, rax
    print rax

    inc r8
    jmp .while
  .end_while:

  ret
