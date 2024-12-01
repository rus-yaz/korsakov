format ELF64
public _start

include "lib/syscalls_amd64.asm"
include "lib/defines.asm"
include "lib/utils.asm"
include "lib/heap.asm"
include "lib/list.asm"
include "lib/integer.asm"
include "lib/string.asm"
include "lib/file.asm"
include "lib/exec.asm"
include "lib/errors.asm"
include "lib/functions.asm"

include "tests/const_buffers.asm"

тестовый_файл db "привет, мир.корс", 0
текст_функции db 'показать("привет, мир!")', 10, 0
привет_мир db "привет, мир!", 0

файловый_дескриптор rq 1
содержимое rq 1
тестовая_функция rq 1

section "_start" executable
_start:
  ; Аллокация кучи. Обязательна для любой работы с переменными
  allocate_heap

  ;include "tests/heap.asm"
  ;include "tests/file.asm"
  ;include "tests/string.asm"
  ;include "tests/list.asm"
  ;include "tests/print.asm"
  ;include "tests/exec.asm"
  ;include "tests/functions.asm"

  open_file тестовый_файл
  mov [файловый_дескриптор], rax

  read_file rax
  mov [содержимое_файла], rax

  close_file [файловый_дескриптор]

  buffer_to_string текст_функции
  mov [тестовая_функция], rax

  ;print <[содержимое_файла], [тестовая_функция]>

  is_equal [содержимое_файла], [тестовая_функция]
  cmp rax, 1
  je .continue
    exit -1

  .continue:
  print привет_мир

  exit 0
