; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_buffer_to_binary:
  get_arg 0
  mov rbx, rax

  buffer_length rbx
  mov rcx, rax

  add rax, BINARY_HEADER*8
  inc rax ; Учёт нуля-терминатора

  mov rdx, rax
  create_block rdx

  mem_mov [rax + 8*0], BINARY
  mem_mov [rax + 8*1], rcx

  mov rdi, rax ; Место назначения
  add rdi, BINARY_HEADER * 8

  mov rsi, rbx ; Источник копирования
  rep movsb    ; Копирование в аллоцированный блок

  add rdx, rax
  @@:
    cmp rdi, rdx
    je @f

    mov byte [rdi], 0

    inc rdi
    jmp @b
  @@:

  ret

f_binary_to_string:
  get_arg 0
  mov rdx, rax

  check_type rdx, BINARY

  mov rbx, [rdx + 8*1]
  cmp rbx, 0
  jne @f
    list
    mem_mov [rax], STRING
    ret
  @@:

  add rdx, BINARY_HEADER*8
  mov rbx, 0 ; Количество символов

  push 0
  mov r9, rsp

  mov [rsp], bl

  .while:
    mov r8, 0
    mov rax, 0

    mov rcx, 0
    mov cl, [rdx]

    cmp cl, 0
    je .end_while

    sub rsp, 4
    inc rbx

    mov al, cl
    mov ah, 10000000b

    and al, ah
    cmp al, ah
    je @f
      mov r8, 0 ; Количество оставшихся байт символа в последовательнсоти
      jmp .correct_start
    @@:

    mov al, cl
    mov ah, 11110000b

    and al, ah
    cmp al, ah
    jne @f
      mov r8, 3 ; Количество оставшихся байт символа в последовательнсоти
      jmp .correct_start
    @@:

    mov al, cl
    mov ah, 11100000b

    and al, ah
    cmp al, ah
    jne @f
      mov r8, 2 ; Количество оставшихся байт символа в последовательнсоти
      jmp .correct_start
    @@:

    mov al, cl
    mov ah, 11000000b

    and al, ah
    cmp al, ah
    jne @f
      mov r8, 1 ; Количество оставшихся байт символа в последовательнсоти
      jmp .correct_start
    @@:

    mov al, cl
    mov ah, 10000000b

    and al, ah
    cmp al, ah
    jne .not_symbol_start
      raw_string "binary_to_string: Неизвестная битовая последовательность: начало символа имеет маску 10000000b"
      error_raw rax
      exit -1
    .not_symbol_start:

    raw_string "binary_to_string: Неизвестная битовая последовательность: начало символа не имеет маску 11000000b, 11100000b или 11110000b"
    error_raw rax
    exit -1

    .correct_start:

    movzx rax, cl
    .while_char:

      cmp r8, 0
      je .end_while_char

      dec r8
      inc rdx

      mov cl, [rdx]
      mov ch, 10000000b

      and cl, ch
      cmp cl, ch
      je .correct_sequence
        raw_string "binary_to_string: Неизвестная битовая последовательность: продолжение символа не имеет маску 10000000₂"
        error_raw rax
        exit -1
      .correct_sequence:

      shl rax, 8
      mov al, [rdx]

      jmp .while_char

    .end_while_char:

    mov [rsp], eax
    inc rdx

    jmp .while

  .end_while:

  list rbx
  mov r8, rax

  mem_mov [r8], STRING
  mem_mov [r8 + 8*1], rbx

  mov rcx, [r8 + 8*3]
  mov rdx, 0

  mov r10, r9
  sub r10, 4

  @@:

    cmp rdx, rbx
    je @f

    mov eax, [r10]
    integer rax
    mov [rcx], rax

    add rcx, 8
    sub r10, 4

    inc rdx
    jmp @b

  @@:

  mov rsp, r9
  pop rax

  mov rax, r8

  ret

f_buffer_to_string:
  get_arg 0

  buffer_to_binary rax
  mov rbx, rax

  binary_to_string rax
  delete_block rbx

  ret

f_string_to_binary:
  get_arg 0
  mov rbx, rax
  check_type rbx, STRING

  string_length rbx
  integer rax
  mov rcx, rax

  integer 0
  mov r8, rax

  mov r9, 0

  mov r15, rsp
  push 0

  .while:
    is_equal r8, rcx
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_get_link rbx, r8

    mov rax, [rax + 8*3]
    mov rax, [rax]

    mov rax, [rax + INTEGER_HEADER*8]
    bswap rax

    @@:
      cmp rax, 0
      je @f

      mov dl, al
      shr rax, 8

      cmp dl, 0
      je @b

      mov [rsp], dl
      dec rsp

      inc r9
      jmp @b
    @@:

    integer_inc r8
    jmp .while

  .end_while:

  dec rsp
  inc r9

  ; Приведение размера к числу, кратному 8
  mov rax, r9

  mov rbx, 8
  mov rdx, 0

  idiv rbx
  mov rcx, rdx

  cmp rcx, 0
  je @f
    inc rax
  @@:

  mov r11, rax
  add rax, BINARY_HEADER
  imul rax, 8

  create_block rax
  mem_mov [rax + 8*0], BINARY
  mem_mov [rax + 8*1], r9

  mov r12, rax
  add rax, BINARY_HEADER*8

  mov rbx, rsp
  add rbx, r9

  @@:
    cmp r9, 0
    je @f

    mov rcx, [rbx]
    mov [rax], cl

    dec rbx
    inc rax

    dec r9
    jmp @b
  @@:

  mov rax, r12
  mov rsp, r15

  ret

f_binary_length:
  get_arg 0
  check_type rax, BINARY

  mov rax, [rax + 8*1]
  ret
