; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_assign_link:
  get_arg 0
  mov r8, rax
  get_arg 1
  mov rbx, rax
  get_arg 2
  mov rcx, rax
  get_arg 3
  mov rdx, rax

  ; RBX — keys
  ; RCX — value
  ; RDX — context
  ; R8  — variable

  check_type r8, STRING
  check_type rbx, LIST
  check_type rdx, DICTIONARY

  list_length rbx
  cmp rax, 0
  je .empty_keys

    ; R9 — item
    dictionary_get_link rdx, r8, 0
    mov r9, rax
    cmp r9, 0
    jne .correct_variable
      string "Переменная `"
      string_extend_links rax, r8
      mov rbx, rax
      string "` не найдена"
      string_extend_links rbx, rax
      list
      list_append_link rax, rbx
      error rax
      exit -1

    .correct_variable:

    ; R10 — items
    list
    mov r10, rax
    list_append_link r10, r9

    ; R11 — key_index
    integer 0
    mov r11, rax

    .get_while:

      list_length rbx
      dec rax
      integer rax
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      je .get_end_while

      ; R12 — key
      list_get_link rbx, r11
      mov r12, rax

      ; R13 — item
      integer 0
      list_get_link r10, rax
      mov r13, rax

      mov rax, [r13]

      cmp rax, LIST
      jne .get_not_list

        list_get_link r13, r12
        jmp .get_continue

      .get_not_list:

      cmp rax, STRING
      jne .get_not_string

        string_get_link r13, r12
        jmp .get_continue

      .get_not_string:

      cmp rax, DICTIONARY
      jne .get_not_dictionary

        dictionary_get_link r13, r12
        jmp .get_continue

      .get_not_dictionary:

        type_to_string rax
        mov rbx, rax
        string "Тип `"
        string_extend_links rax, rbx
        mov rbx, rax
        string "` не является коллекцией"
        string_extend_links rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .get_continue:

      mov r13, rax

      integer 0
      list_insert_link r10, rax, r13

      integer_inc r11
      jmp .get_while

    .get_end_while:

    integer 0
    list_insert_link r10, rax, rcx

    ; R11 — key_index
    list_length rbx
    integer rax
    mov r11, rax

    .set_while:
      integer 0
      is_equal r11, rax
      boolean_value rax
      cmp rax, 1
      je .set_end_while

      integer_dec r11

      integer 0
      list_pop_link r10, rax
      mov rcx, rax

      ; R12 — item
      integer 0
      list_get_link r10, rax
      mov r12, rax

      ; R13 — key
      list_get_link rbx, r11
      mov r13, rax

      mov rax, [r12]

      cmp rax, LIST
      jne .set_not_list

        list_set_link r12, r13, rcx
        jmp .set_continue

      .set_not_list:

      cmp rax, STRING
      jne .set_not_string

        string_set_link r12, r13, rcx
        jmp .set_continue

      .set_not_string:

      cmp rax, DICTIONARY
      jne .set_not_dictionary

        dictionary_set_link r12, r13, rcx
        jmp .set_continue

      .set_not_dictionary:

        type_to_string rax
        mov rbx, rax
        string "Тип `"
        string_extend_links rax, rbx
        mov rbx, rax
        string "` не является коллекцией"
        string_extend_links rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .set_continue:

      mov rcx, rax

      integer 0
      list_set_link r10, rax, rcx

      jmp .set_while

    .set_end_while:

    integer 0
    list_get_link r10, rax
    mov rcx, rax

  .empty_keys:

  dictionary_set_link rdx, r8, rcx
  mov rax, rcx

  ret

f_assign:
  get_arg 0
  mov r8, rax
  get_arg 1
  mov rbx, rax
  get_arg 2
  mov rcx, rax
  get_arg 3
  mov rdx, rax

  ; RBX — keys
  ; RCX — value
  ; RDX — context
  ; R8  — variable

  check_type r8, STRING
  check_type rbx, LIST
  check_type rdx, DICTIONARY

  copy rcx
  assign_link r8, rbx, rax, rdx

  ret

f_access_link:
  get_arg 0
  mov rdx, rax
  get_arg 1
  mov rbx, rax
  get_arg 2
  mov rcx, rax

  ; RBX — keys
  ; RCX — context
  ; RDX — variable

  check_type rbx, LIST
  check_type rcx, DICTIONARY
  check_type rdx, STRING

  dictionary_keys_links rcx
  list_include rax, rdx
  mov rax, [rax + BOOLEAN_HEADER*8]
  cmp rax, 1
  je .correct_variable
    string "Переменная `"
    string_extend_links rax, rdx
    mov rbx, rax
    string "` не найдена"
    string_extend_links rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct_variable:

  dictionary_get_link rcx, rdx
  mov rdx, rax

  list_length rbx
  cmp rax, 0
  je .empty_keys

    .while:

      list_length rbx
      cmp rax, 0
      je .end_while

      mov r8, [rdx]

      cmp r8, STRING
      je .correct_type
      cmp r8, DICTIONARY
      je .correct_type
      cmp r8, LIST
      je .correct_type

        string "Тип `"
        mov rbx, rax
        type_to_string r8
        string_extend_links rbx, rax
        string "` не является коллекцией"
        string_extend_links rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .correct_type:

      integer 0
      list_pop_link rbx, rax
      mov r8, rax

      mov rax, [rdx]

      cmp rax, LIST
      je .list

      cmp rax, STRING
      je .string

      cmp rax, DICTIONARY
      je .dictionary

        string "Не поддерживаемый тип: "
        mov rbx, rax
        type_to_string rax
        string_extend_links rbx, rax
        list
        list_append_link rax, rbx
        error rax
        exit -1

      .list:
        list_get_link rdx, r8
        jmp .continue

      .string:
        string_get_link rdx, r8
        jmp .continue

      .dictionary:
        dictionary_get_link rdx, r8
        jmp .continue

      .continue:

      mov rdx, rax
      jmp .while

    .end_while:
  .empty_keys:

  mov rax, rdx
  ret

f_access:
  get_arg 0
  mov rdx, rax
  get_arg 1
  mov rbx, rax
  get_arg 2
  mov rcx, rax

  ; RBX — keys
  ; RCX — context
  ; RDX — variable

  check_type rbx, LIST
  check_type rcx, DICTIONARY
  check_type rdx, STRING

  access_link rdx, rbx, rcx
  copy rax

  ret
