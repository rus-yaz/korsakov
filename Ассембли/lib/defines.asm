section "defines" writable
  ; Типы данных
  define HEAP_BLOCK  0xFEDCBA9876543210
  define NULL        0
  define INTEGER     1
  define FLOAT       2
  define LIST        3
  define STRING      4
  define BINARY      5
  define DICTIONARY  6
  define CLASS       8
  define FILE        9

  ; Размер заголовка
  define HEAP_BLOCK_HEADER 4
  define FILE_HEADER       4
  define NULL_HEADER       1
  define INTEGER_HEADER    1
  define BINARY_HEADER     2
  define STRING_HEADER     3
  define LIST_HEADER       3
  define DICTIONARY_HEADER 3

  ; Полные размеры типа (для неизменяемых по длине)
  define NULL_SIZE    1
  define INTEGER_SIZE 2
  define FILE_SIZE    4

section "errors" writable
  EXPECTED_TYPE_ERROR db "Ожидался тип: ", 0
  INTEGER_TYPE        db "Целое число", 0
  LIST_TYPE           db "Список", 0
  STRING_TYPE         db "Строка", 0
  BINARY_TYPE         db "Бинарная последовательность", 0
  FILE_TYPE           db "Файл", 0
  DICTIONARY_TYPE     db "Словарь", 0
  HEAP_BLOCK_TYPE     db "Блок кучи", 0

  INDEX_OUT_OF_LIST_ERROR       db "Индекс выходит за пределы списка", 0
  INDEX_OUT_OF_STRING_ERROR     db "Индекс выходит за пределы строки", 0
  OPENING_FILE_ERROR            db "Не удалось открыть файл", 0
  FILE_WAS_NOT_READ_ERROR       db "Файл не был прочитан", 0
  UNEXPECTED_TYPE_ERROR         db "Неизвестный тип", 0
  UNEXPECTED_BIT_SEQUENCE_ERROR db "Неизвестная битовая последовательность", 0
  EXECVE_WAS_NOT_EXECUTED       db "Не удалось выполнить системный вызов `execve`", 0
  HEAP_ALLOCATION_ERROR         db "Ошибка аллокации кучи", 0
  DIFFERENT_LISTS_LENGTH_ERROR  db "Списки имеют разную длину", 0
  KEY_DOESNT_EXISTS             db "Ключа не существует", 0

section "heap" writable
  PAGE_SIZE   dq 0x1000             ; Начальный размер кучи
  HEAP_START  rq 1                  ; Указатель на начало кучи
  HEAP_END    rq 1                  ; Указатель на конец кучи

section "dictionary" executable

macro dictionary keys = 0, values = 0 {
  enter keys, values

  call f_dictionary

  return
}

macro dictionary_length dictionary, key {
  enter dictionary, key

  call f_dictionary_length

  return
}

macro dictionary_keys dictionary {
  enter dictionary

  call f_dictionary_keys

  return
}

macro dictionary_values dictionary {
  enter dictionary

  call f_dictionary_values

  return
}

macro dictionary_get dictionary, key {
  enter dictionary, key

  call f_dictionary_get

  return
}

macro dictionary_items dictionary {
  enter dictionary

  call f_dictionary_items

  return
}

macro dictionary_copy dictionary {
  enter dictionary

  call f_dictionary_copy

  return
}

section "exec" executable

macro run command, args, env, wait = 1 {
  enter command, args, env, wait

  call f_run

  leave
}

section "file" executable

macro get_file_size filename {
  enter filename

  call f_get_file_size

  return
}

macro open_file filename, flags = O_RDONLY, mode = 444o {
  enter filename, flags, mode

  call f_open_file

  return
}

macro close_file file {
  enter file

  call f_close_file

  leave
}

macro read_file file {
  enter file

  call f_read_file

  return
}

macro write_file file, string {
  enter file, string

  call f_write_file

  leave
}

section "functions" executable

macro is_equal val_1, val_2 {
  enter val_1, val_2

  call f_is_equal

  return
}

section "heap" executable

macro allocate_heap {
  enter

  call f_allocate_heap

  leave
}

macro delete_block block {
  enter block

  call f_delete_block

  leave
}

macro create_block size {
  enter size

  call f_create_block

  return
}

section "integer" executable

macro integer value {
  enter value

  call f_integer

  return
}

macro integer_copy int {
  enter int

  call f_integer_copy

  return
}

macro integer_inc int {
  enter int

  call f_integer_inc

  return
}

macro integer_dec int {
  enter int

  call f_integer_dec

  return
}

macro integer_add int_1, int_2 {
  enter int_1, int_2

  call f_integer_add

  return
}

section "list" executable

macro list list_start = 0, length = 0 {
  enter list_start, length

  call f_list

  return
}

macro list_length list {
  enter list

  call f_list_length

  return
}

macro list_get list, index {
  enter list, index

  call f_list_get

  return
}

macro join list, separator = " " {
  enter list, separator

  call f_join

  return
}

macro list_copy list {
  enter list

  call f_list_copy

  return
}

macro list_append list, item {
  enter list, item

  call f_list_append

  return
}

macro string_to_list string {
  enter string

  call f_string_to_list

  return
}

macro list_to_string list {
  enter list

  call f_list_to_string

  return
}

section "print" executable

macro print_string string {
  enter string

  call f_print_string

  leave
}

section "string" executable

macro buffer_to_binary buffer_addr {
  enter buffer_addr

  call f_buffer_to_binary

  return
}

macro binary_to_string binary_addr {
  enter binary_addr

  call f_binary_to_string

  return
}

macro buffer_to_string buffer_addr {
  enter buffer_addr

  call f_buffer_to_string

  return
}

macro string_length string {
  enter string

  call f_string_length

  return
}

macro string_copy string {
  enter string

  call f_string_copy

  return
}

macro string_append string_1, string_2 {
  enter string_1, string_2

  call f_string_append

  return
}

macro string_add string_1, string_2 {
  enter string_1, string_2

  call f_string_add

  return
}

macro string_get string, index {
  enter string, index

  call f_string_get

  return
}

section "to_string" executable

macro to_string value {
  enter value

  call f_to_string

  return
}

section "delete" executable

macro delete variable {
  enter variable

  call f_delete

  leave
}
