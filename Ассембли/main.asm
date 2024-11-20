format ELF64
public _start

include "lib/syscalls_amd64.asm"
include "lib/defines.asm"
include "lib/utils.asm"
include "lib/heap.asm"
include "lib/list.asm"
include "lib/integer.asm"
include "lib/file.asm"
include "lib/string.asm"

section "data" writable
  ; Сообщения об ошибках
  EXPECTED_INTEGER_TYPE_ERROR         db "Ожидался тип Целое число", 10, 0
  EXPECTED_LIST_TYPE_ERROR            db "Ожидался тип Список", 10, 0
  EXPECTED_STRING_TYPE_ERROR          db "Ожидался тип Строка", 10, 0
  EXPECTED_INTEGER_LIST_TYPE_ERROR    db "Ожидался тип Целое число или Список", 10, 0
  EXPECTED_FILE_DESCRIPTOR_TYPE_ERROR db "Ожидался тип Файловый дескриптор", 10, 0
  EXPECTED_HEAP_BLOCK_ERROR           db "Ожидался блок кучи", 10, 0
  INDEX_OUT_OF_LIST_ERROR             db "Индекс выходит за пределы списка", 10, 0
  OPENING_FILE_ERROR                  db "Не удалось открыть файл", 10, 0
  FILE_WAS_NOT_READ_ERROR             db "Файл не был прочитан", 10, 0
  UNEXPECTED_BIT_SEQUENCE_ERROR       db "Неизвестная битовая последовательность", 10, 0

  FILE_SIZE       db "Размер файла:", 0
  STRING_SIZE     db "Размер строки:", 0
  STRING_CONTENT  db "Содержимое строки:", 0
  CHAR_BY_INDEX   db "Символ по индексу:", 0
  ITEM_BY_INDEX   db "Элемент по индексу:", 0

  имя_файла_для_чтения db "привет.корс", 0
  имя_файла_для_записи db "пока.корс", 0

  тестовый_блок_1 rq 1
  тестовый_блок_2 rq 1
  тестовый_блок_3 rq 1

  список rq 1
  индекс rq 1
  размер_файла rq 1
  файл_для_чтения rq 1
  файл_для_записи rq 1
  содержимое_файла rq 1
  символ rq 1

section "_start" executable
_start:
  ; Аллокация кучи. Обязательна для любой работы с переменными
  allocate_heap

  ;include "tests/heap.asm"
  include "tests/file.asm"
  ;include "tests/string.asm"
  ;include "tests/list.asm"

  ; Проверка строк (строки, помещённые в кучу)
  print <[содержимое_файла]>

  ; Проверка буфера (строки, захардкоженные в FASM)
  print <STRING_CONTENT>

  ; Проверка чисел
  integer 1024
  mov rax, rsp
  print <rax>

  ; Проверка множественного отображения
  integer 1024
  mov rax, rsp
  print <rax, STRING_CONTENT, [содержимое_файла]>

  integer 1024
  mov rax, rsp
  mov rbx, rsp
  mov rcx, rsp
  print <rax, rbx, rcx>
  print <rax, rbx, rcx>, 38, 95

  exit 0
