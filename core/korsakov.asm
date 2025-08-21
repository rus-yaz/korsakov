; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

format ELF64
public _start

section "" writable

  HEAP_START            rq 1 ; Указатель на начало кучи
  HEAP_END              rq 1 ; Указатель на конец кучи
  FIRST_FREE_HEAP_BLOCK rq 1 ; Указатель на первый в цепочке свободный блок

  PROGRAM_START_POINTER rq 1

  GLOBAL_CONTEXT  rq 1
  DEBUG_TIME      rq 1

  RANDOM_SEED  rq 1

  EULER_NUMBER rq 1
  E            rq 1

section "" executable

; Типы данных
define HEAP_BLOCK  "KORS"
define NULL        0
define INTEGER     1
define FLOAT       2
define BOOLEAN     3
define LIST        4
define STRING      5
define BINARY      6
define DICTIONARY  7
define FUNCTION    8
define CLASS       9
define FILE        10

; Размер заголовка
define NULL_HEADER       1
define BOOLEAN_HEADER    1
define INTEGER_HEADER    1
define FLOAT_HEADER      1
define BINARY_HEADER     2
define LIST_HEADER       4
define STRING_HEADER     4
define DICTIONARY_HEADER 4
define FILE_HEADER       4
define HEAP_BLOCK_HEADER 5
define FUNCTION_HEADER   7

; Полные размеры типа (для неизменяемых по длине)
define NULL_SIZE    1
define INTEGER_SIZE 2
define FLOAT_SIZE   2
define BOOLEAN_SIZE 2
define FILE_SIZE    4

define PAGE_SIZE 0x1000 ; Начальный размер кучи

include "./debug.asm"
include "./macro.asm"
include "./syscalls_amd64.asm"
include "./utils.asm"

include "../lib/.asm"

macro arguments [argument] {
  common
    push rbx
    list
    mov rbx, rax

  forward
    string argument
    list_append_link rbx, rax

  common
    pop rbx
}

_start:
  mov rbp, rsp

  mov rax, rbp
  set_program_start_pointer rax

  allocate_heap

  if NODEFAULT eqtype
  else

  reset_seed

  float 2.718281828459045
  mov [E], rax
  mov [EULER_NUMBER], rax

  dictionary
  mov [GLOBAL_CONTEXT], rax

  list
  mov [DEBUG_TIME], rax

  list
  mov rdx, rax
  string "код_выхода"
  list_append_link rdx, rax

  dictionary
  mov rcx, rax
  string "код_выхода"
  mov rbx, rax
  integer 0
  dictionary_set_link rcx, rbx, rax

  string "выход"
  mov rbx, rax
  function rbx, f_program_exit, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  end if

  call start
