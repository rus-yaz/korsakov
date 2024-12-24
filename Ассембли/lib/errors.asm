section "errors" writable
  EXPECTED_TYPE_ERROR db "Ожидался тип: ", 0
  INTEGER_TYPE        db "Целое число", 0
  LIST_TYPE           db "Список", 0
  STRING_TYPE         db "Строка", 0
  BINARY_TYPE         db "Бинарная последовательность", 0
  FILE_TYPE           db "Файл", 0
  HEAP_BLOCK_TYPE     db "Блок кучи", 0

  INDEX_OUT_OF_LIST_ERROR       db "Индекс выходит за пределы списка", 0
  INDEX_OUT_OF_STRING_ERROR     db "Индекс выходит за пределы строки", 0
  OPENING_FILE_ERROR            db "Не удалось открыть файл", 0
  FILE_WAS_NOT_READ_ERROR       db "Файл не был прочитан", 0
  UNEXPECTED_TYPE_ERROR         db "Неизвестный тип", 0
  UNEXPECTED_BIT_SEQUENCE_ERROR db "Неизвестная битовая последовательность", 0
  EXECVE_WAS_NOT_EXECUTED       db "Не удалось выполнить системный вызов `execve`", 0
  HEAP_ALLOCATION_ERROR         db "Ошибка аллокации кучи", 0
