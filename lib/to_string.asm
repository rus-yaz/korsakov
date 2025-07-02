; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_to_string:
  get_arg 0
  mov rbx, [rax]

  cmp rbx, NULL
  jne .not_null
    string "Нуль"
    ret

  .not_null:

  cmp rbx, INTEGER
  jne .not_integer
    mov rax, [rax + INTEGER_HEADER*8]

    mov r8, rsp ; Сохранение указателя на конец стека

    dec rsp
    mov rcx, 1  ; Количество байт в последовательности (1 — ноль-терминатор)

    mov [rsp], cl
    dec rsp

    mov r9, 0

    cmp rax, 0
    jge .integer_continue
      mov r9, 1
      neg rax
    .integer_continue:

    mov rbx, 10 ; Мощность системы счисления
    mov rdx, 0  ; Обнуление регистра, хранящего остаток от деления

    .integer_while:
      idiv rbx    ; Деление на мощность системы счисления
      add rdx, 48 ; Приведение числа к значению по ASCII

      dec rsp
      inc rcx

      mov [rsp], dl   ; Сохранение числа на стеке
      mov rdx, 0 ; Обнуление регистра, хранящего остаток от деления

    cmp rax, 0
    jne .integer_while

    cmp r9, 1
    jne .not_negate
      dec rsp
      inc rcx

      mov rax, "-"
      mov [rsp], al
    .not_negate:

    mov rdx, 0
    mov rbx, 8

    mov rax, rcx
    idiv rbx

    cmp rdx, 0
    je @f
      inc rax
    @@:

    push rax, BINARY

    mov rax, rsp
    binary_to_string rax

    mov rsp, r8 ; Восстановление конца стека
    ret

  .not_integer:

  cmp rbx, FLOAT
  jne .not_float

    pushsd 0, 1, 2, 3

    movsd xmm0, [rax + FLOAT_HEADER*8]
    cvttsd2si rcx, xmm0

    string ""
    mov rbx, rax

    raw_float 10.0
    movsd xmm2, [rax]

    raw_float 0.0
    movsd xmm3, [rax]

    comisd xmm0, xmm3
    jae .skip_minus

    raw_float -1.0
    comisd xmm0, [rax]
    jna .skip_minus

      string "-"
      string_extend_links rbx, rax

    .skip_minus:

    cvtsi2sd xmm1, rcx
    subsd xmm0, xmm1

    integer rcx
    to_string rax
    string_extend_links rbx, rax

    string ","
    string_extend_links rbx, rax

    ucomisd xmm0, xmm3
    jne .not_empty_mantissa
      string "0"
      string_extend_links rbx, rax

      jmp .end
    .not_empty_mantissa:

    integer 0
    mov rdx, rax
    @@:
      ucomisd xmm0, xmm3
      je .end

      mulsd xmm0, xmm2
      cvttsd2si rax, xmm0

      cvtsi2sd xmm1, rax
      subsd xmm0, xmm1

      integer rax
      mov rcx, rax

      is_greater rcx, rdx
      boolean_value rax
      cmp rax, 1
      je .positive
        integer_neg rcx
        mov rcx, rax
      .positive:

      to_string rcx
      string_extend_links rbx, rax

      jmp @b
    .end:

    popsd 3, 2, 1, 0

    mov rax, rbx
    ret

  .not_float:

  cmp rbx, BOOLEAN
  jne .not_boolean
    mov rax, [rax + BOOLEAN_HEADER*8]

    cmp rax, 1
    jne .false
      string "Истина"
      ret

    .false:
      string "Ложь"
      ret

  .not_boolean:

  cmp rbx, LIST
  jne .not_list
    mov rbx, rax

    list_length rbx
    integer rax
    mov rcx, rax

    integer 0
    mov rdx, rax

    list
    mov r8, rax

    .list_while:
      is_equal rdx, rcx
      boolean_value rax
      cmp rax, 1
      je .list_end_while

      list_get_link rbx, rdx
      to_string rax
      list_append_link r8, rax

      integer_inc rdx
      jmp .list_while

    .list_end_while:

    join_links r8
    mov rbx, rax

    string "%("
    string_extend_links rax, rbx
    mov rbx, rax

    string ")"
    string_extend_links rbx, rax

    ret

  .not_list:

  cmp rbx, STRING
  jne .not_string
    mov rbx, rax

    string '"'
    mov rcx, rax

    integer 0
    mov rdx, rax

    string_length rbx
    integer rax
    mov r8, rax

    .while_string:

      is_equal rdx, r8
      boolean_value rax
      cmp rax, 1
      je .while_string_end

      string_get_link rbx, rdx
      mov r9, rax

      string 9
      is_equal r9, rax
      boolean_value rax
      cmp rax, 1
      jne .not_tab

        string "\т"
        mov r9, rax

        jmp .next_char

      .not_tab:

      string 10
      is_equal r9, rax
      boolean_value rax
      cmp rax, 1
      jne .not_newline

        string "\н"
        mov r9, rax

        jmp .next_char

      .not_newline:

      .next_char:
      string_extend_links rcx, r9

      integer_inc rdx
      jmp .while_string

    .while_string_end:

    string '"'
    string_extend_links rcx, rax

    ret

  .not_string:

  cmp rbx, DICTIONARY
  jne .not_dictionary
    dictionary_items rax
    mov rbx, rax

    list_length rbx
    cmp rax, 0
    jne .not_empty
      string "%(:)"
      ret

    .not_empty:

    integer rax
    mov rcx, rax

    integer 0
    mov rdx, rax

    list
    mov r10, rax

    .dictionary_while:

      is_equal rdx, rcx
      boolean_value rax
      cmp rax, 1
      je .dictionary_end_while

      string ""
      mov r8, rax

      list_get_link rbx, rdx
      mov r9, rax

      integer 0
      list_get_link r9, rax
      to_string rax
      string_extend_links r8, rax

      string ": "
      string_extend_links r8, rax

      integer 1
      list_get_link r9, rax
      to_string rax
      string_extend_links r8, rax

      list_append_link r10, r8

      integer_inc rdx
      jmp .dictionary_while

    .dictionary_end_while:

    join_links r10
    mov rbx, rax

    string "%("
    string_extend_links rax, rbx
    mov rbx, rax

    string ")"
    string_extend_links rbx, rax

    ret

  .not_dictionary:

  cmp rbx, FUNCTION
  jne .not_function
    mov rbx, rax

    string "функция("
    mov rcx, rax

    mov rdx, 0

    list_length [rbx + 8*3]
    mov r8, rax

    cmp r8, 0
    je .end_while_function

    .while_function:
      integer rdx
      list_get_link [rbx + 8*3], rax
      mov r9, rax

      null
      dictionary_get_link [rbx + 8*4], r9, rax
      mov r10, rax
      null
      is_equal rax, r10
      boolean_value rax
      cmp rax, 1
      je .not_named

        string " = "
        string_extend_links r9, rax

        to_string r10
        string_extend_links r9, rax

      .not_named:

      string_extend_links rcx, r9
      inc rdx

      cmp rdx, r8
      je .end_while_function

      string ", "
      string_extend_links rcx, rax

      jmp .while_function

    .end_while_function:

    string ")"
    string_extend_links rcx, rax

    ret

  .not_function:

  type_to_string rbx
  mov rbx, rax
  string "to_string: Не поддерживается тип"
  mov rcx, rax
  list
  list_append_link rax, rcx
  list_append_link rax, rbx
  error rax
  exit -1
