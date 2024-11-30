section "data" writable
  ; Сообщения об ошибках
  EXPECTED_INTEGER_TYPE_ERROR         db "Ожидался тип Целое число", 10, 0
  EXPECTED_LIST_TYPE_ERROR            db "Ожидался тип Список", 10, 0
  EXPECTED_STRING_TYPE_ERROR          db "Ожидался тип Строка", 10, 0
  EXPECTED_INTEGER_LIST_TYPE_ERROR    db "Ожидался тип Целое число или Список", 10, 0
  EXPECTED_BINARY_TYPE_ERROR          db "Ожидался тип Бинарная последовательность", 10, 0
  EXPECTED_FILE_DESCRIPTOR_TYPE_ERROR db "Ожидался тип Файловый дескриптор", 10, 0
  EXPECTED_HEAP_BLOCK_ERROR           db "Ожидался блок кучи", 10, 0
  INDEX_OUT_OF_LIST_ERROR             db "Индекс выходит за пределы списка", 10, 0
  OPENING_FILE_ERROR                  db "Не удалось открыть файл", 10, 0
  FILE_WAS_NOT_READ_ERROR             db "Файл не был прочитан", 10, 0
  UNEXPECTED_BIT_SEQUENCE_ERROR       db "Неизвестная битовая последовательность", 10, 0
  EXECVE_WAS_NOT_EXECUTED             db "Не удалось выполнить системный вызов `execve`", 10
