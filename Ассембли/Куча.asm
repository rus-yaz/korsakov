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
  EXPECTED_CHAR_TYPE_ERROR            db "Ожидался тип Символ", 10, 0
  EXPECTED_STRING_CHAR_TYPE_ERROR     db "Ожидался тип Строка или Символ", 10, 0
  EXPECTED_INTEGER_LIST_TYPE_ERROR    db "Ожидался тип Целое число или Список", 10, 0
  EXPECTED_FILE_DESCRIPTOR_TYPE_ERROR db "Ожидался тип Файловый дескриптор", 10, 0
  EXPECTED_HEAP_BLOCK_ERROR           db "Ожидался блок кучи", 10, 0
  INDEX_OUT_OF_LIST_ERROR             db "Индекс выходит за пределы списка", 10, 0
  OPENING_FILE_ERROR                  db "Не удалось открыть файл", 10, 0
  FILE_WAS_NOT_READ_ERROR             db "Файл не был прочитан", 10, 0
  UNEXPECTED_BIT_SEQUENCE_ERROR       db "Неизвестная битовая последовательность", 10, 0

  FILE_SIZE       db "Размер файла: ", 0
  STRING_SIZE     db "Размер строки (учитывается переноса): ", 0
  STRING_CONTENT  db "Содержимое строки:", 0
  CHAR_BY_INDEX   db 10, "Символ по индексу: ", 0
  ITEM_BY_INDEX   db 10, "Элемент по индексу: ", 0

  имя_файла_для_чтения db "привет.корс", 0
  имя_файла_для_записи db "пока.корс", 0

  список rq 1
  индекс rq 1
  файл_для_чтения rq 1
  файл_для_записи rq 1
  содержимое_файла rq 1
  символ rq 1

section "_start" executable
_start:
  allocate_heap

  ; Открытие файла
  open_file имя_файла_для_чтения
  mov [файл_для_чтения], rax

  ; Чтение файла
  read_file [файл_для_чтения]
  mov [содержимое_файла], rax

  ; Закрытие файла, дальше он не нужен
  close_file [файл_для_чтения]
	print_string [содержимое_файла]

	; Открытие файла в режиме записи
	open_file имя_файла_для_записи, O_WRONLY
	mov [файл_для_записи], rax

	; Запись в файл из строки
	write_file [файл_для_записи], [содержимое_файла]

	; Закрытие файла
	close_file [файл_для_записи]

  ; Открытие файла
  open_file имя_файла_для_записи
  mov [файл_для_записи], rax

  ; Чтение файла
  read_file [файл_для_записи]
  mov [содержимое_файла], rax

  ; Закрытие файла, дальше он не нужен
  close_file [файл_для_записи]
	print_string [содержимое_файла]

	; ---------

  ; Открытие файла
  open_file имя_файла_для_чтения
  mov [файл_для_чтения], rax

  ; Чтение файла
  read_file [файл_для_чтения]
  mov [содержимое_файла], rax

	; Закрытие файла, дальше он не нужен
	close_file [файл_для_чтения]

	; Получение длины строки
	print_buffer STRING_SIZE
	get_string_length [содержимое_файла]
	print_int rax

	; Вывод содержимого файла
	print_buffer STRING_CONTENT
	print_string [содержимое_файла]

	; Взятие символа по индексу
	integer -2
	mov [индекс], rsp
	get_string [содержимое_файла], [индекс]

	print_buffer CHAR_BY_INDEX
	mov [символ], rax
	print_string [символ]

	; Расширение кучи
	expand_heap 0x1000

	integer 1
	integer 2
	integer 3
	integer 4

	mov rax, rsp      ; Указатель на начало списка
	list rax, 4       ; Количество элементов
	mov [список], rax

	; индекс = 999
	integer -1
	mov [индекс], rsp

	; список.индекс
	list_get [список], [индекс]
	mov rax, [rax + 8*1]

	; показать(список.индекс)
	print_buffer ITEM_BY_INDEX
	print_int rax

  exit 0
