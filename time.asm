; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

include "core/korsakov.asm"

section "start" executable
start:
  create_block 2*8
  mov rbx, rax
  syscall 228, 0, rbx

  string "Секунды:"
  mov rcx, rax
  integer [rbx + 8*0]
  print <rcx, rax>
  string "Наносекунды:"
  mov rcx, rax
  integer [rbx + 8*1]
  print <rcx, rax>

  print 0

  push rbx
  mov rbx, [rbx + 8*0]

  string "Дни:"
  mov r8, rax

  mov rax, rbx
  mov rcx, 60*60*24
  mov rdx, 0
  idiv rcx
  mov rbx, rdx
  integer rax
  print <r8, rax>

  string "Часы:"
  mov r8, rax

  mov rax, rbx
  mov rcx, 60*60
  mov rdx, 0
  idiv rcx
  mov rbx, rdx
  integer rax
  print <r8, rax>

  string "Минуты:"
  mov r8, rax

  mov rax, rbx
  mov rcx, 60
  mov rdx, 0
  idiv rcx
  mov rbx, rdx
  integer rax
  print <r8, rax>

  string "Секунды:"
  mov r8, rax

  integer rbx
  print <r8, rax>

  ; rcx — секунды
  ; rdx — наносекунды

  pop rbx
  mov rbx, [rbx + 8*1]
  mov rcx, 1000

  mov rax, rbx
  mov rdx, 0
  idiv rcx
  mov rbx, rax
  mov r9, rdx

  mov rax, rbx
  mov rdx, 0
  idiv rcx
  mov rbx, rax
  mov r10, rdx

  mov rax, rbx
  mov rdx, 0
  idiv rcx
  mov rbx, rax
  mov r11, rdx

  string "Миллисекунды:"
  mov rcx, rax

  integer r11
  print <rcx, rax>

  string "Микросекунды:"
  mov rcx, rax

  integer r10
  print <rcx, rax>

  string "Наносекунды:"
  mov rcx, rax

  integer r9
  print <rcx, rax>

  exit 0
