; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function get_random
; @description Генерирует случайное целое число в заданном диапазоне
; @param start=0 - нижняя граница диапазона
; @param end=0 - верхняя граница диапазона
; @return Случайное целое число в диапазоне [start, end]
; @example
;   get_random  ; генерирует случайное число в диапазоне [0, MAX_INT/2]
;   get_random 1, 10  ; генерирует случайное число от 1 до 10
_function get_random, rbx, rcx, rdx, r8
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
