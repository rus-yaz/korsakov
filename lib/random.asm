; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_get_random:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rbx, 0
  jne @f
    mov rax, -1
    mov rbx, 2
    mov rdx, 0
    idiv rbx
    integer rax
    mov rbx, rax
  @@:

  cmp rcx, 0
  jne @f
    mov rcx, rbx
    integer 0
    mov rbx, rax
  @@:

  check_type rbx, INTEGER
  check_type rcx, INTEGER

  mov rbx, [rbx + 8*INTEGER_HEADER]
  mov rcx, [rcx + 8*INTEGER_HEADER]

  cmp rbx, rcx
  jl .correct_range
    string "Нижний предел должен быть строго меньше верхнего (нижний предел по умолчанию — 0)"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1
  .correct_range:

  mov r8, rcx
  sub r8, rbx
  inc r8

  push rcx, 0
  mov rax, rsp

  sys_getrandom rax, 8
  pop rax, rcx

  mov rdx, 0
  idiv r8

  add rdx, rbx
  integer rdx

  ret

f_get_pseudorandom:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rbx, 0
  jne @f
    mov rax, -1
    mov rbx, 2
    mov rdx, 0
    idiv rbx
    integer rax
    mov rbx, rax
  @@:

  cmp rcx, 0
  jne @f
    mov rcx, rbx
    integer 0
    mov rbx, rax
  @@:

  check_type rbx, INTEGER
  check_type rcx, INTEGER

  mov rbx, [rbx + 8*INTEGER_HEADER]
  mov rcx, [rcx + 8*INTEGER_HEADER]

  cmp rbx, rcx
  jl .correct_range
    string "Нижний предел должен быть строго меньше верхнего (нижний предел по умолчанию — 0)"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1
  .correct_range:

  mov rax, [RANDOM_SEED]
  mov rax, [rax + INTEGER_HEADER*8]

  imul rax, 21
  add rax, 8

  mov r8, rcx
  sub r8, rbx
  inc r8

  mov rdx, 0
  idiv r8

  add rdx, rbx

  integer rdx
  mov [RANDOM_SEED], rax
  ret


f_set_seed:
  get_arg 0
  check_type rax, INTEGER
  mov [RANDOM_SEED], rax
  ret

f_reset_seed:
  integer 2108
  mov [RANDOM_SEED], rax
  ret
