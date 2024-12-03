section "defines" writable
  ; Типы данных
  define HEADER_SIGN 0xFEDCBA9876543210
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
  define NULL_HEADER       1
  define INTEGER_HEADER    1
  define STRING_HEADER     2
  define BINARY_HEADER     2
  define LIST_HEADER       3

  ; Полные размеры типа (для неизменяемых по длине)
  define NULL_SIZE    1
  define INTEGER_SIZE 2
  define FILE_SIZE    4
