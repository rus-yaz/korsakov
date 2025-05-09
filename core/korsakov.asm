; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

format ELF64
public _start

section "data" writable
  ; Типы данных
  define HEAP_BLOCK  0xFEDCBA9876543210
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
  define BOOLEAN_SIZE 2
  define FILE_SIZE    4

  INDEX_OUT_OF_LIST_ERROR       db "Индекс выходит за пределы списка",              0
  INDEX_OUT_OF_STRING_ERROR     db "Индекс выходит за пределы строки",              0
  OPENING_FILE_ERROR            db "Не удалось открыть файл",                       0
  FILE_WAS_NOT_READ_ERROR       db "Файл не был прочитан",                          0
  UNEXPECTED_TYPE_ERROR         db "Неизвестный тип",                               0
  UNEXPECTED_BIT_SEQUENCE_ERROR db "Неизвестная битовая последовательность",        0
  UNEXPECTED_TOKEN_ERROR        db "Неизвестный токен: ",                           0
  EXECVE_WAS_NOT_EXECUTED       db "Не удалось выполнить системный вызов `execve`", 0
  HEAP_ALLOCATION_ERROR         db "Ошибка аллокации кучи",                         0
  DIFFERENT_LISTS_LENGTH_ERROR  db "Списки имеют разную длину",                     0
  KEY_DOESNT_EXISTS             db "Ключа не существует",                           0
  INVALID_INDENTIFIER           db "Неизвестный идентификатор",                     0

  PAGE_SIZE             dq 0x1000 ; Начальный размер кучи
  HEAP_START            rq 1      ; Указатель на начало кучи
  HEAP_END              rq 1      ; Указатель на конец кучи
  FIRST_FREE_HEAP_BLOCK rq 1      ; Указатель на первый в цепочке свободный блок

  ENVIRONMENT_VARIABLES rq 1
  ARGUMENTS_COUNT       rq 1
  ARGUMENTS             rq 1

  GLOBAL_CONTEXT  rq 1
  DEBUG_TIME      rq 1

include "./debug.asm"
include "./macro.asm"
include "./syscalls_amd64.asm"
include "./utils.asm"

include "../lib/arithmetical.asm"
include "../lib/boolean.asm"
include "../lib/collection.asm"
include "../lib/comparisons.asm"
include "../lib/copy.asm"
include "../lib/delete.asm"
include "../lib/dictionary.asm"
include "../lib/exec.asm"
include "../lib/file.asm"
include "../lib/function.asm"
include "../lib/heap.asm"
include "../lib/integer.asm"
include "../lib/list.asm"
include "../lib/null.asm"
include "../lib/print.asm"
include "../lib/string.asm"
include "../lib/to_string.asm"
include "../lib/variables.asm"
include "../lib/getcwd.asm"
include "../lib/getrandom.asm"

section "_start" executable
_start:
  mov rbp, rsp

  allocate_heap

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
  string "args*"
  list_append_link rdx, rax
  string "separator"
  list_append_link rdx, rax
  string "end_of_string"
  list_append_link rdx, rax

  dictionary
  mov rcx, rax
  string "separator"
  mov rbx, rax
  string " "
  dictionary_set_link rcx, rbx, rax
  string "end_of_string"
  mov rbx, rax
  string 10
  dictionary_set_link rcx, rbx, rax

  string "print"
  mov rbx, rax
  function rbx, f_print, rdx, rcx, 1, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax
  string "аргументы*"
  list_append_link rdx, rax
  string "разделитель"
  list_append_link rdx, rax
  string "конец_строки"
  list_append_link rdx, rax

  dictionary
  mov rcx, rax
  string "разделитель"
  mov rbx, rax
  string " "
  dictionary_set_link rcx, rbx, rax
  string "конец_строки"
  mov rbx, rax
  string 10
  dictionary_set_link rcx, rbx, rax

  string "показать"
  mov rbx, rax
  function rbx, f_print, rdx, rcx, 1, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax
  string "список*"
  list_append_link rdx, rax
  string "объединитель"
  list_append_link rdx, rax

  dictionary
  mov rcx, rax
  string "объединитель"
  mov rbx, rax
  string " "
  dictionary_set_link rcx, rbx, rax

  string "объединить"
  mov rbx, rax
  function rbx, f_join, rdx, rcx, 1, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax
  string "строка"
  list_append_link rdx, rax
  string "разделитель"
  list_append_link rdx, rax
  string "количество_частей"
  list_append_link rdx, rax

  dictionary
  mov rcx, rax
  string "разделитель"
  mov rbx, rax
  string " "
  dictionary_set_link rcx, rbx, rax
  string "количество_частей"
  mov rbx, rax
  integer -1
  dictionary_set_link rcx, rbx, rax

  string "разделить"
  mov rbx, rax
  function rbx, f_split, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax
  string "нижний_порог"
  list_append_link rdx, rax
  string "верхний_порог"
  list_append_link rdx, rax

  dictionary
  mov rcx, rax
  string "нижний_порог"
  mov rbx, rax
  integer 0
  dictionary_set_link rcx, rbx, rax
  string "верхний_порог"
  mov rbx, rax
  push rbx, rdx
  mov rax, -1
  mov rbx, 2
  mov rdx, 0
  idiv rbx
  integer rax
  pop rdx, rbx
  dictionary_set_link rcx, rbx, rax

  string "получить_случайное_число"
  mov rbx, rax
  function rbx, f_getrandom, rdx, rcx, 1, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  call start
