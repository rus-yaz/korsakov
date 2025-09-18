match =1, LINUX {
  ; Куча
  define HEAP_FORWARD 1
}
match =1, WINDOWS {
  ; Куча
  define HEAP_FORWARD 0
  define WINDOWS_HEAP_SIZE 0x1000 * 1000 * 100
}

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
