; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

format ELF64
public _start

section "" writable

  HEAP_START            rq 1 ; Указатель на начало кучи
  HEAP_END              rq 1 ; Указатель на конец кучи
  FIRST_FREE_HEAP_BLOCK rq 1 ; Указатель на первый в цепочке свободный блок

  ENVIRONMENT_VARIABLES rq 1
  ARGUMENTS_COUNT       rq 1
  ARGUMENTS             rq 1

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
define COLLECTION  4
define LIST        5
define STRING      6
define BINARY      7
define DICTIONARY  8
define FUNCTION    9
define CLASS       10
define FILE        11

; Размер заголовка
define NULL_HEADER       1
define BOOLEAN_HEADER    1
define INTEGER_HEADER    1
define FLOAT_HEADER      1
define BINARY_HEADER     2
define COLLECTION_HEADER 4
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

  allocate_heap
  reset_seed

  float 2.718281828459045
  mov [E], rax
  mov [EULER_NUMBER], rax

  mov rcx, [rbp] ; Количество переданных аргументов
  integer rcx
  mov [ARGUMENTS_COUNT], rax

  list
  mov [ARGUMENTS], rax

  mov rbx, 0
  .arguments_while:

    cmp rbx, rcx
    je .arguments_end_while

    get_arg rbx
    buffer_to_string rax
    list_append_link [ARGUMENTS], rax

    inc rbx
    jmp .arguments_while

  .arguments_end_while:

  list
  mov [ENVIRONMENT_VARIABLES], rax

  mov rcx, [ARGUMENTS_COUNT]
  mov rcx, [rcx + INTEGER_HEADER*8]
  inc rcx ; Учёт блока с количеством аргументов
  inc rcx ; Учёт нуля-разделителя

  imul rcx, 8

  mov rbx, rbp
  add rbx, rcx

  mov rcx, 0

  .environment_variables_while:

    cmp [rbx], rcx
    je .environment_variables_end_while

    buffer_to_string [rbx]
    list_append_link [ENVIRONMENT_VARIABLES], rax

    add rbx, 8
    jmp .environment_variables_while

  .environment_variables_end_while:

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

  call start
