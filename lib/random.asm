; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function get_pseudorandom
; @description Генерирует псевдослучайное целое число в заданном диапазоне
; @param start=0 - нижняя граница диапазона
; @param end=0 - верхняя граница диапазона
; @return Псевдослучайное целое число в диапазоне [start, end]
; @example
;   get_pseudorandom  ; генерирует псевдослучайное число в диапазоне [0, MAX_INT/2]
;   get_pseudorandom 1, 10  ; генерирует псевдослучайное число от 1 до 10
_function get_pseudorandom, rbx, rcx, rdx, r8
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


; @function set_seed
; @description Устанавливает начальное значение для генератора псевдослучайных чисел
; @param seed - начальное значение для генератора
; @example
;   integer 12345
;   set_seed rax  ; устанавливает начальное значение 12345
_function set_seed, rax
  get_arg 0
  check_type rax, INTEGER
  mov [RANDOM_SEED], rax
  ret

; @function reset_seed
; @description Сбрасывает начальное значение генератора псевдослучайных чисел к значению по умолчанию
; @example
;   reset_seed  ; сбрасывает начальное значение к 2108
_function reset_seed, rax
  integer 2108
  mov [RANDOM_SEED], rax
  ret
