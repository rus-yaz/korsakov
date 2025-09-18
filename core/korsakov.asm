; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

match =1, LINUX {
  format ELF64
  public _start

  define WINDOWS 0

  include "linux/syscalls.asm"
}
match =1, WINDOWS {
  format PE64 console

  define LINUX 0

  include "windows/syscalls.asm"
  purge .while, .else
}

include "debug.asm"
include "macro.asm"

match =1, LINUX   { section ".data" writable }
match =1, WINDOWS { .data }

  WINDOWS_HEAP_START    rq 1 ; Указатель на кучу
  HEAP_START            rq 1 ; Указатель на начало кучи
  HEAP_END              rq 1 ; Указатель на конец кучи
  FIRST_FREE_HEAP_BLOCK rq 1 ; Указатель на первый в цепочке свободный блок

  CLI_ARGUMENTS_COUNT   dq 0 ; Количество аргументов командной строки
  CLI_ARGUMENTS         dq 0 ; Аргументы командной строки
  ENVIRONMENT_VARIABLES dq 0 ; Переменные среды

  PROGRAM_START_POINTER rq 1

  GLOBAL_CONTEXT  rq 1
  DEBUG_TIME      rq 1

  RANDOM_SEED  rq 1

  EULER_NUMBER rq 1
  E            rq 1


match =1, WINDOWS {
  CRYPTO_CONTEXT dq 1

  PROC_INFO  PROCESS_INFORMATION
  START_INFO STARTUPINFO
}

match =1, LINUX   { section ".text" executable }
match =1, WINDOWS { .code }

include "constants.asm"
include "utils.asm"

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

include "../config.inc"

_start:
  match =1, LINUX {
    mov rbp, rsp

    mov rax, rbp
    set_program_start_pointer rax
  }
  match =1, WINDOWS {
    and rsp, -0x10

    invoke SetConsoleOutputCP, CP_UTF8
    invoke SetConsoleCP, CP_UTF8
  }

  init_heap

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
