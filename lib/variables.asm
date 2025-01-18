f_assign:
  ; RBX — keys
  ; RCX — value
  ; RDX — context
  ; R8  — variable

  mov r8, rax

  dictionary_set rdx, r8, rcx
  mov rax, rcx

  ret

f_access:
  ; RBX — keys
  ; RCX — context
  ; RDX — variable

  mov rdx, rax

  dictionary_keys rcx
  list_include rax, rdx
  cmp rax, 1
  je .correct_variable
    string "Переменная `"
    string_append rax, rdx
    mov rbx, rax
    string "` не найдена"
    string_append rbx, rax
    print rax
    exit -1

  .correct_variable:

  dictionary_get rcx, rdx
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
        string_append rbx, rax
        string "` не является коллекцией"
        string_append rbx, rax
        print rax
        exit -1

      .correct_type:

      integer 0
      list_pop rbx, rax
      mov r8, rax

      mov rax, [rdx]

      cmp rax, LIST
      je .list

      cmp rax, STRING
      je .string

      cmp rax, DICTIONARY
      je .dictionary

        type_to_string rax
        mov rbx, rax
        string "Не поддерживаемый тип: "
        string_append rax, rbx
        print rax
        exit -1

      .list:
        list_get rdx, r8
        jmp .continue

      .string:
        string_get rdx, r8
        jmp .continue

      .dictionary:
        dictionary_get rdx, r8
        jmp .continue

      .continue:

      mov rdx, rax

      jmp .while

    .end_while:

  .empty_keys:

  mov rax, rdx

  ret
