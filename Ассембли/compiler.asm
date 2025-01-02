section "compiler" executable

macro string_to_data string {
  enter string

  call f_string_to_data

  return
}

f_string_to_data:
  mov rcx, rax

  string_copy [пустая_строка]
  mov rbx, rax

  buffer_to_string префикс_строки
  string_append rbx, rax

  integer_inc [КОЛИЧЕСТВО_СТРОК]
  to_string rax
  string_append rbx, rax

  buffer_to_string суффикс_строки
  string_append rbx, rax

  string_append rbx, rcx

  buffer_to_string постфикс_строки
  string_append rbx, rax

  ret

macro check_statement_type statement, type {
  enter statement, type

  call f_check_statement_type

  return
}

f_check_statement_type:
  dictionary_get rax, [тип]
  mov rcx, rax
  integer rbx

  is_equal rax, rcx
  ret

macro compiler ast {
  enter ast

  call f_compiler

  return
}

f_compiler:
  mov [АСД], rax

  integer 0
  mov [индекс], rax

  string_copy [пустая_строка]
  mov [код], rax

  string_copy [пустая_строка]
  mov [данные], rax

  .while:
    list_length [АСД]
    integer rax
    is_equal rax, [индекс]

    cmp rax, 1
    je .end_while

    list_get [АСД], [индекс]
    mov rbx, rax
    check_statement_type rax, [ТИП_ФУНКЦИЯ]
    cmp rax, 1
    jne .not_function
      dictionary_get rbx, [значение]
      string_append [код], rax

      dictionary_get rbx, [аргументы]
      mov rbx, rax

      string_copy [пустая_строка]
      mov rcx, rax

      integer 0
      list_get rbx, rax
      dictionary_get rax, [значение]

      string_to_data rax
      string_append [данные], rax

      mov rbx, rsp
      push 0, 10
      mov rax, rsp
      buffer_to_string rax
      mov rsp, rbx
      string_append [данные], rax

      buffer_to_string префикс_строки
      mov rbx, rax
      to_string [КОЛИЧЕСТВО_СТРОК]
      string_append rbx, rax
      string_append rcx, rax

      mov rbx, rsp
      push 0, " "
      mov rax, rsp
      buffer_to_string rax
      mov rsp, rbx

      string_append [код], rax
      string_append [код], rcx

      jmp .continue

    .not_function:

    .continue:

    integer_inc [индекс]
    jmp .while

  .end_while:
  mov rax, [код]

  ret
