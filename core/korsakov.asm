format ELF64
public _start

section "data" writable
  ; Типы данных
  define HEAP_BLOCK  0xFEDCBA9876543210
  define NULL        0
  define INTEGER     1
  define FLOAT       2
  define BOOLEAN     3
  define LIST        4
  define STRING      5
  define BINARY      6
  define DICTIONARY  7
  define CLASS       9
  define FILE        10

  ; Размер заголовка
  define NULL_HEADER       1
  define BOOLEAN_HEADER    1
  define INTEGER_HEADER    1
  define BINARY_HEADER     2
  define LIST_HEADER       3
  define STRING_HEADER     3
  define DICTIONARY_HEADER 3
  define FILE_HEADER       4
  define HEAP_BLOCK_HEADER 4

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

  PAGE_SIZE            dq 0x1000             ; Начальный размер кучи
  HEAP_START           rq 1                  ; Указатель на начало кучи
  HEAP_END             rq 1                  ; Указатель на конец кучи
  LAST_USED_HEAP_BLOCK rq 1

  GLOBAL_CONTEXT rq 1
  DEBUG_TIME rq 1

include "./debug.asm"
include "./macro.asm"
include "./syscalls_amd64.asm"
include "./utils.asm"

include "../lib/arithmetical.asm"
include "../lib/boolean.asm"
include "../lib/delete.asm"
include "../lib/dictionary.asm"
include "../lib/exec.asm"
include "../lib/file.asm"
include "../lib/functions.asm"
include "../lib/heap.asm"
include "../lib/integer.asm"
include "../lib/list.asm"
include "../lib/print.asm"
include "../lib/string.asm"
include "../lib/to_string.asm"
include "../lib/variables.asm"
include "../lib/null.asm"

section "_start" executable
_start:
  allocate_heap

  dictionary
  mov [GLOBAL_CONTEXT], rax

  list
  mov [DEBUG_TIME], rax

  call start
