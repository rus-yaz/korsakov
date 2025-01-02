section "parser" executable

macro check_token_type token, type {
  enter token, type

  call f_check_token_type

  return
}

f_check_token_type:
  dictionary_get rax, [тип]
  mov rcx, rax
  integer rbx

  is_equal rax, rcx
  ret

macro check_correct_token_type token, type {
  enter token, type

  call f_check_correct_token_type

  return
}

f_check_correct_token_type:
  mov rcx, rax
  check_token_type rax, rbx

  cmp rax, 1
  je .correct
    dictionary_get rcx, [значение]
    print <INCORRECT_TOKEN_TYPE_ERROR, rax>
    exit -1

  .correct:
  ret

macro parser tokens {
  enter tokens

  call f_parser

  return
}

f_parser:
  check_type rax, LIST

  mov [токены], rax

  list 0
  mov [АСД], rax

  integer 0
  mov [индекс], rax

  .while:
    list_get [токены], [индекс]
    mov [токен], rax
    dictionary_get rax, [тип]
    mov rbx, rax

    integer [ТИП_КОНЕЦ_ФАЙЛА]
    is_equal rbx, rax

    cmp rax, 1
    je .end_while

    check_token_type [токен], [ТИП_ФУНКЦИЯ]
    cmp rax, 1
    jne .not_function
      dictionary_get [токен], [значение]
      mov r8, rax

      integer_inc [индекс]
      list_get [токены], [индекс]

      check_correct_token_type rax, [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]

      integer_inc [индекс]
      list_get [токены], [индекс]
      mov rbx, rax
      list 0
      list_append rax, rbx
      mov rdx, rax

      integer_inc [индекс]
      list_get [токены], [индекс]
      check_correct_token_type rax, [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]

      list 0
      list_append rax, [тип]
      list_append rax, [значение]
      list_append rax, [аргументы]
      mov rbx, rax

      list 0
      mov rcx, rax
      integer [ТИП_ФУНКЦИЯ]
      list_append rcx, rax
      list_append rcx, r8
      list_append rcx, rdx

      dictionary rbx, rcx
      list_append [АСД], rax

      jmp .continue

    .not_function:

    .continue:

    integer_inc [индекс]
    jmp .while

  .end_while:

  mov rax, [АСД]

  ret
