; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; Методы бинарных последовательностей и буферов
;   Буфер к бинарной последовательности
;   Бинарная последовательность к строке
;   Буфер к строке
;   Строка к бинарной последовательности
;   Длина бинарной последовательности
;
; Методы коллекций
;   Конструктор
;   Длина
;   Вместимость
;   Расширить вместимость
;   Установить ссылку на символ по индексу
;   Установить копию символа по индексу
;   Получить ссылку на символ по индексу
;   Получить копию символа по индексу
;   Копировать ссылки
;   Копировать элементы
;
; Методы строки
;   Изъять ссылку на символ по индексу
;   Изъять копии символа по индексу
;   Получить индекс символа
;   Проверить, входит ли подстрока в строку
;   Расширить строку ссылками на символами строки
;   Расширить строку копиями символов строки
;   ! Получить развёрнутую строку из ссылок на символы
;   ! Получить развёрнутую строку из копий символов
;   Получить срез ссылок на символы
;   Получить срез копий символы
;   Сложить строки из ссылок на символы
;   Сложить строки из копий символов
;   Повторить строки из ссылок на символы
;   Повторить строки из копий симоволов

; @function string_from_capacity
; @description Создает новую строку с указанной начальной вместимостью
; @param capacity=2 - начальная вместимость строки
; @return Объект строки
; @example
;   string_from_capacity  ; создает строку с вместимостью 2
;   string_from_capacity 10  ; создает строку с вместимостью 10
_function string_from_capacity, rbx, rcx, rdi, rsi
  get_arg 0
  mov rbx, rax

  mov rcx, rbx
  imul rcx, 8

  create_block rcx ; Аллокация места для элементов

  mov      rdi, rax ; Источник копирования
  mov byte [rdi], 0 ; Значение, которое будет раскопировано

  mov rsi, rdi ; Место назначения
  inc rsi      ; Смещение от уже назначенного

  rep movsb ; Побайтовое копирование
  mov rcx, rax

  create_block STRING_HEADER*8
  mem_mov [rax + 8*0], STRING ; Тип
  mem_mov [rax + 8*1], 0      ; Длина
  mem_mov [rax + 8*2], rbx    ; Вместимость
  mem_mov [rax + 8*3], rcx    ; Указатель на элементы

  ret

; @function string_length
; @description Возвращает текущую длину строки
; @param string - строка для измерения длины
; @return Количество символов в строке
; @example
;   string "Hello, World!"
;   string_length rax  ; вернет 13
_function string_length
  get_arg 0
  check_type rax, STRING

  mov rax, [rax + 8*1]
  ret

; @function string_capacity
; @description Возвращает текущую вместимость строки
; @param string - строка для получения вместимости
; @return Вместимость строки
; @example
;   string "Hello"
;   string_capacity rax  ; возвращает вместимость строки
_function string_capacity
  get_arg 0
  check_type rax, STRING

  mov rax, [rax + 8*2]
  ret

; @function string_expand_capacity
; @description Увеличивает вместимость строки в два раза
; @param string - строка для расширения вместимости
; @example
;   string "Hi"
;   string_expand_capacity rax  ; увеличивает вместимость до 4
_function string_expand_capacity, rax, rbx, rcx
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_capacity rbx

  imul rax, 2
  mov [rbx + 8*2], rax

  imul rax, 8
  create_block rax
  mov rcx, rax

  string_length rbx
  mem_copy [rbx + 8*3], rcx, rax

  delete_block [rbx + 8*3]
  mov [rbx + 8*3], rcx

  ret

; @function string_set_link
; @description Устанавливает символ по индексу в строку (без копирования)
; @param string - строка для установки символа
; @param index - индекс для установки символа
; @param char - символ для установки (строка длиной 1)
; @return Строка с установленным символом
; @example
;   string "Hello"
;   string "X"
;   string_set_link rax, 0, rbx  ; заменяет первый символ на X
_function string_set_link, rbx, rcx, rdx, r8
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, STRING
  check_type rcx, INTEGER
  check_type rdx, STRING

  string_length rdx
  cmp rax, 1
  je .correct_length
    raw_string "string_set: Ожидалась строка с длиной 1"
    error_raw rax
    exit -1
  .correct_length:

  mov rdx, [rdx + 8*3]
  mov rdx, [rdx]

  ; Запись длины строки
  string_length rbx
  mov r8, rax

  ; Если индекс меньше нуля, то увеличить его на длину строки
  mov rcx, [rcx + 8*1]
  cmp rcx, 0
  jge @f
    add rcx, r8
  @@:

  ; Проверка, входит ли индекс в строке
  cmp rcx, r8
  check_error jge, "string_set: Индекс выходит за пределы строки"
  cmp rcx, 0
  check_error jl, "string_set: Индекс выходит за пределы строки"

  mov rax, rbx
  mov rbx, [rbx + 8*3]

  imul rcx, 8
  add rbx, rcx

  mov [rbx], rdx
  ret

; @function string_set
; @description Устанавливает символ по индексу в строку (с копированием)
; @param string - строка для установки символа
; @param index - индекс для установки символа
; @param char - символ для установки (строка длиной 1)
; @return Строка с установленным символом
; @example
;   string "Hello"
;   string "X"
;   string_set rax, 0, rbx  ; заменяет первый символ на X
_function string_set, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  string_copy rdx
  string_set_link rbx, rcx, rax

  ret

; @function string_get_link
; @description Получает символ по индексу из строки (без копирования)
; @param string - строка для получения символа
; @param index - индекс символа для получения
; @return Символ по указанному индексу (строка длиной 1)
; @example
;   string "Hello"
;   string_get_link rax, 0  ; возвращает "H"
_function string_get_link, rbx, rcx, r8
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, INTEGER

  ; Запись длины строки
  string_length rbx
  mov r8, rax

  ; Если индекс меньше нуля, то увеличить его на длину строки
  mov rcx, [rcx + 8*1]
  cmp rcx, 0
  jge @f
    add rcx, r8
  @@:

  ; Проверка, входит ли индекс в строке
  cmp rcx, r8
  check_error jge, "string_get: Индекс выходит за пределы строки"
  cmp rcx, 0
  check_error jl, "string_get: Индекс выходит за пределы строки"

  mov rax, rbx
  mov rbx, [rbx + 8*3]

  imul rcx, 8
  add rbx, rcx

  mov rbx, [rbx]

  string_from_capacity 1
  mov r8, rax

  mov rax, [r8 + 8*3]
  mov [rax], rbx

  mov qword [r8 + 8*1], 1

  mov rax, r8
  ret

; @function string_get
; @description Получает символ по индексу из строки (с копированием)
; @param string - строка для получения символа
; @param index - индекс символа для получения
; @return Копия символа по указанному индексу (строка длиной 1)
; @example
;   string "Hello"
;   string_get rax, 0  ; возвращает копию "H"
_function string_get, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_get_link rbx, rcx
  string_copy rax

  ret

; @function string_copy_links
; @description Создает копию строки со ссылками на символы
; @param string - строка для копирования
; @return Копия строки со ссылками
; @example
;   string "Hello"
;   string_copy_links rax  ; создает копию со ссылками
_function string_copy_links, rbx, rcx
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_capacity rbx
  string_from_capacity rax
  mov rcx, rax

  mem_mov [rcx + 8*0], [rbx + 8*0]
  mem_mov [rcx + 8*1], [rbx + 8*1]
  mem_copy [rbx + 8*3], [rcx + 8*3], [rcx + 8*1]

  mov rax, rcx
  ret

; @function string_copy
; @description Создает полную копию строки с копированием всех символов
; @param string - строка для копирования
; @return Полная копия строки
; @example
;   string "Hello"
;   string_copy rax  ; создает полную копию
_function string_copy, rbx, rcx, rdx, r8, r9, r10,
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_capacity rbx
  string_from_capacity rax
  mov rcx, rax

  mem_mov [rcx + 8*0], [rbx + 8*0]
  mem_mov [rcx + 8*1], [rbx + 8*1]

  mov r8, [rbx + 8*3]
  mov r9, [rcx + 8*3]

  mov rdx, [rcx + 8*1]
  @@:
    cmp rdx, 0
    je @f

    copy [r8]
    mov [r9], rax

    add r8, 8
    add r9, 8

    dec rdx
    jmp @b
  @@:

  mov rax, rcx
  ret

; @function string_pop_link
; @description Удаляет и возвращает символ по индексу (без копирования)
; @param string - строка для удаления символа
; @param index=-1 - индекс символа для удаления
; @return Удаленный символ (строка длиной 1)
; @example
;   string "Hello"
;   string_pop_link rax, -1  ; удаляет и возвращает последний символ
_function string_pop_link, rbx, rcx, rdx, r8, r9
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rcx, -1
  jne @f
    integer -1
    mov rcx, rax
  @@:

  check_type rbx, STRING
  check_type rcx, INTEGER

  string_length rbx
  mov rdx, rax

  mov rcx, [rcx + INTEGER_HEADER*8]
  cmp rcx, 0
  jge @f
    add rcx, rdx
  @@:

  cmp rcx, rdx
  check_error jge, "string_pop: Индекс выходит за пределы строки"
  cmp rcx, 0
  check_error jl, "string_pop: Индекс выходит за пределы строки"

  ; Декрементация длины
  dec rdx
  mov [rbx + 8*1], rdx

  mov r8, rdx
  sub r8, rcx

  ; Смещение до элемента
  imul rcx, 8
  mov rbx, [rbx + 8*3]

  add rbx, rcx
  mov rax, [rbx]

  mov r9, rbx
  add r9, 8

  mem_copy r9, rbx, r8

  ; Затирание последнего элемента
  imul r8, 8
  add rbx, r8
  mem_mov [rbx], 0

  mov rbx, rax

  string_from_capacity 1
  mov rcx, rax

  mov qword [rcx + 8*1], 1

  mov rax, [rcx + 8*3]
  mov [rax], rbx

  mov rax, rcx
  ret

; @function string_pop
; @description Удаляет и возвращает символ по индексу (с копированием)
; @param string - строка для удаления символа
; @param index=-1 - индекс символа для удаления
; @return Копия удаленного символа (строка длиной 1)
; @example
;   string "Hello"
;   string_pop rax, -1  ; удаляет и возвращает копию последнего символа
_function string_pop, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_pop_link rbx, rcx
  string_copy rax

  ret

; @function string_index
; @description Возвращает индекс первого вхождения символа в строку
; @param string - строка для поиска символа
; @param char - символ для поиска (строка длиной 1)
; @return Индекс символа или -1, если не найден
; @example
;   string "Hello"
;   string "l"
;   string_index rax, rbx  ; возвращает 2
_function string_index, rbx, rcx, rdx, r8
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  string_length rcx
  cmp rax, 1
  je .correct_length
    raw_string "string_index: Ожидалась строка с длиной 1"
    error_raw rax
    exit -1
  .correct_length:

  integer 0
  mov rdx, rax

  string_length rbx
  mov r8, rax

  @@:
    cmp [rdx + INTEGER_HEADER*8], r8
    je @f

    string_get_link rbx, rdx
    is_equal rax, rcx
    boolean_value rax
    cmp rax, 1
    je .return_index

    integer_inc rdx
    jmp @b
  @@:

  delete rdx
  integer -1
  ret

  .return_index:
  mov rax, rdx
  ret

; @function string_include
; @description Проверяет, содержится ли подстрока в строке
; @param string - строка для проверки
; @param substring - подстрока для поиска
; @return Булево значение (true если подстрока найдена)
; @example
;   string "Hello World"
;   string "World"
;   string_include rax, rbx  ; возвращает true
_function string_include, rbx, rcx, rdx, r8, r9, r10, r11
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  mov rdx, 0 ; Итератор
  mov r8,  0 ; Счётчик схождение

  string_length rbx
  mov r9, rax
  string_length rcx
  mov r10, rax

  sub r9, r10
  inc r9

  cmp r9, 0
  jle .return_false

  @@:
    cmp rdx, r9
    je @f

    ; Количество схождений совпало с количеством символом в подстроке
    cmp r8, r10
    je .return_true

    integer rdx
    string_get_link rbx, rax
    mov r11, rax

    integer r8
    string_get_link rcx, rax

    is_equal r11, rax
    boolean_value rax
    cmp rax, 1
    jne .not_equal
      inc r8
      jmp .continue
    .not_equal:
      sub rdx, r8
      mov r8, 0
    .continue:

    inc rdx
    jmp @b
  @@:

  .return_false:
    boolean 0
    ret

  .return_true:
    boolean 1
    ret

; @function string_extend_links
; @description Добавляет все символы из другой строки как ссылки
; @param string - целевая строка для расширения
; @param other - строка с символами для добавления
; @return Расширенная строка
; @example
;   string "Hello"
;   string " World"
;   string_extend_links rax, rbx
_function string_extend_links, rbx, rcx, rdx, rdi, rsi
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  string_length rbx
  mov rdx, rax
  string_length rcx
  add rdx, rax

  @@:
    string_capacity rbx
    cmp rax, rdx
    jge @f

    string_expand_capacity rbx
    jmp @b
  @@:

  mov rdi, [rbx + 8*3]

  string_length rbx
  imul rax, 8
  add rdi, rax

  mov [rbx + 8*1], rdx
  mov rsi, [rcx + 8*3]

  string_length rcx
  mov rcx, rax

  rep movsq
  mov rax, rbx

  ret

; @function string_extend
; @description Добавляет все символы из другой строки как копии
; @param string - целевая строка для расширения
; @param other - строка с символами для добавления
; @return Расширенная строка
; @example
;   string "Hello"
;   string " World"
;   string_extend rax, rbx
_function string_extend, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_copy rcx
  string_extend_links rbx, rax

  ret

; @function split_links
; @description Разделяет строку на части по разделителю (ссылки)
; @param string - строка для разделения
; @param separator=" " - разделитель
; @param max_parts=-1 - максимальное количество частей
; @return Список частей строки как ссылки
; @example
;   string "Hello World Test"
;   string " "
;   split_links rax, rbx  ; возвращает ["Hello", "World", "Test"]
_function split_links, rbx, rcx, rdx, r8, r9, r10, r11, r12
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  cmp rcx, " "
  jne .not_default_separator
    string " "
    mov rcx, rax
  .not_default_separator:

  cmp rdx, -1
  jne .not_default_parts_count
    integer -1
    mov rdx, rax
  .not_default_parts_count:

  check_type rbx, STRING
  check_type rcx, STRING
  check_type rdx, INTEGER

  list
  mov r8, rax

  integer 0
  mov r9, rax

  string_length rbx
  integer rax
  mov r10, rax

  string ""
  mov r11, rax

  .while:
    is_equal r9, r10
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_get_link rbx, r9
    mov r12, rax

    list_length r8
    integer rax
    is_equal rax, rdx
    boolean_value rax
    cmp rax, 1
    je .join

    is_equal r12, rcx
    boolean_value rax
    cmp rax, 1
    je .split

    .join:

      string_extend_links r11, r12

      jmp .continue

    .split:
      list_append_link r8, r11

      string ""
      mov r11, rax

    .continue:

    integer_inc r9
    jmp .while

  .end_while:
  list_append_link r8, r11

  mov rax, r8
  ret

; @function split
; @description Разделяет строку на части по разделителю (копии)
; @param string - строка для разделения
; @param separator=" " - разделитель
; @param max_parts=-1 - максимальное количество частей
; @return Список частей строки как копии
; @example
;   string "Hello World Test"
;   string " "
;   split rax, rbx  ; возвращает копии ["Hello", "World", "Test"]
_function split, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  split_links rbx, rcx, rdx
  copy rax
  ret

; @function split_from_right_links
; @description Разделяет строку на части по разделителю справа налево (ссылки)
; @param string - строка для разделения
; @param separator=0 - разделитель (по умолчанию пробел)
; @param max_parts=0 - максимальное количество частей (0 - без ограничений)
; @return Список частей строки как ссылки
; @example
;   string "Hello World Test"
;   string " "
;   split_from_right_links rax, rbx  ; возвращает ["Hello World", "Test"]
_function split_from_right_links, rbx, rcx, rdx, r8, r9, r10, r11, r12
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  cmp rcx, 0
  jne .not_default_separator
    string " "
    mov rcx, rax
  .not_default_separator:

  cmp rdx, 0
  jne .not_default_parts_count
    integer -1
    mov rdx, rax
  .not_default_parts_count:

  check_type rbx, STRING
  check_type rcx, STRING
  check_type rdx, INTEGER

  integer_inc rdx

  list
  mov r8, rax
  null
  list_append_link r8, rax

  integer 1
  mov r9, rax

  string_length rbx
  inc rax
  integer rax
  mov r10, rax

  string ""
  mov r11, rax

  .while:
    is_equal r9, r10
    boolean_value rax
    cmp rax, 1
    je .end_while

    negate r9
    string_get_link rbx, rax
    mov r12, rax

    list_length r8
    integer rax
    is_equal rax, rdx
    boolean_value rax
    cmp rax, 1
    je .join

    is_equal r12, rcx
    boolean_value rax
    cmp rax, 1
    je .split

    .join:

      string_add_links r12, r11
      mov r11, rax

      jmp .continue

    .split:
      integer 0
      list_insert_link r8, rax, r11

      string ""
      mov r11, rax

    .continue:

    integer_inc r9
    jmp .while

  .end_while:
  integer 0
  list_insert_link r8, rax, r11

  list_pop_link r8

  mov rax, r8
  ret

; @function split_from_right
; @description Разделяет строку на части по разделителю справа налево (копии)
; @param string - строка для разделения
; @param separator=0 - разделитель (по умолчанию пробел)
; @param max_parts=0 - максимальное количество частей (0 - без ограничений)
; @return Список частей строки как копии
; @example
;   string "Hello World Test"
;   string " "
;   split_from_right rax, rbx  ; возвращает копии ["Hello World", "Test"]
_function split_from_right, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  split_from_right_links rbx, rcx, rdx
  copy rax
  ret

; @function join_links
; @description Объединяет список строк в одну строку с разделителем (ссылки)
; @param list - список строк для объединения
; @param separator=0 - разделитель (по умолчанию пробел)
; @return Объединенная строка
; @example
;   list
;   list_append rax, "Hello"
;   list_append rax, "World"
;   string " "
;   join_links rax, rbx  ; возвращает "Hello World"
_function join_links, rbx, rcx, rdx, r8, r9
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rcx, 0
  jne .not_default_separator
    string " "
    mov rcx, rax
  .not_default_separator:

  check_type rbx, LIST
  check_type rcx, STRING

  string ""
  mov rdx, rax

  integer 0
  mov r8, rax

  list_length rbx
  integer rax
  mov r9, rax

  .while:

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .end_while

    list_get rbx, r8
    check_type rax, STRING
    string_extend_links rdx, rax

    integer_inc r8

    is_equal r8, r9
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_extend_links rdx, rcx

    jmp .while

  .end_while:

  mov rax, rdx

  ret

; @function join
; @description Объединяет список строк в одну строку с разделителем (копии)
; @param list - список строк для объединения
; @param separator=0 - разделитель (по умолчанию пробел)
; @return Объединенная строка
; @example
;   list
;   list_append rax, "Hello"
;   list_append rax, "World"
;   string " "
;   join rax, rbx  ; возвращает "Hello World"
_function join, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  join_links rbx, rcx
  string_copy rax

  ret

; @function is_alpha
; @description Проверяет, состоит ли строка только из букв
; @param string - строка для проверки
; @return Булево значение (true если строка состоит только из букв)
; @example
;   string "Hello"
;   is_alpha rax  ; возвращает true
_function is_alpha, rbx, rcx, rdx
  get_arg 0
  check_type rax, STRING
  mov rbx, rax

  string_length rax
  integer rax
  mov rcx, rax

  integer 0
  mov rdx, rax

  .while:
    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_get rbx, rdx

    mov rax, [rbx + 8*3]
    mov rax, [rax]
    mov rax, [rax + INTEGER_HEADER*8]

    cmp rax, 65
    jl .check_lowercase
    cmp rax, 90
    jle .continue

    .check_lowercase:

    cmp rax, 97
    jl .check_cyrillic
    cmp rax, 122
    jle .continue

    .check_cyrillic:

    cmp rax, 53377
    jl .return_false
    cmp rax, 53649
    jg .return_false

    .continue:

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, 1
  ret

  .return_false:

  mov rax, 0
  ret

; @function is_digit
; @description Проверяет, состоит ли строка только из цифр
; @param string - строка для проверки
; @return Булево значение (true если строка состоит только из цифр)
; @example
;   string "12345"
;   is_digit rax  ; возвращает true
_function is_digit, rbx, rcx, rdx
  get_arg 0
  check_type rax, STRING
  mov rbx, rax

  string_length rax
  integer rax
  mov rcx, rax

  integer 0
  mov rdx, rax

  .while:
    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_get rbx, rdx
    mov rax, [rbx + 8*3]
    mov rax, [rax]
    mov rax, [rax + INTEGER_HEADER*8]

    cmp rax, 48
    jl .return_false
    cmp rax, 57
    jg .return_false

    .continue:

    integer_inc rdx
    jmp .while

  .end_while:

  mov rax, 1
  ret

  .return_false:

  mov rax, 0
  ret

; @function string_to_list
; @description Преобразует строку в список символов
; @param string - строка для преобразования
; @return Список символов
; @example
;   string "Hello"
;   string_to_list rax  ; возвращает ["H", "e", "l", "l", "o"]
_function string_to_list, rbx, rcx, rdx, r8
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  list
  mov rcx, rax

  string_length rbx
  integer rax
  mov rdx, rax

  integer 0
  mov r8, rax

  .while:
    is_equal rdx, r8
    boolean_value rax
    cmp rax, 1
    je .end_while

    string_get rbx, r8
    list_append rcx, rax

    integer_inc r8
    jmp .while

  .end_while:

  mov rax, rcx
  ret

; @function string_reverse_links
; @description Создает новую строку с символами в обратном порядке (ссылки)
; @param string - строка для разворота
; @return Новая строка с символами в обратном порядке
; @example
;   string "Hello"
;   string_reverse_links rax  ; возвращает "olleH"
_function string_reverse_links, rbx, rcx, rdx, r8, r9
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_capacity rbx
  string_from_capacity rax
  mov r9, rax

  mem_mov [r9 + 8*0], [rbx + 8*0]
  mem_mov [r9 + 8*1], [rbx + 8*1]

  string_length rbx
  mov rdx, rax

  mov rbx, [rbx + 8*3]
  mov rcx, [r9  + 8*3]

  mov r8, rdx
  dec r8
  imul r8, 8
  add rbx, r8

  mov r8, 0
  @@:
    cmp rdx, r8
    je @f

    mem_mov [rcx], [rbx]

    sub rbx, 8
    add rcx, 8

    inc r8
    jmp @b
  @@:

  mov rax, r9
  ret

; @function string_reverse
; @description Создает новую строку с символами в обратном порядке (копии)
; @param string - строка для разворота
; @return Новая строка с символами в обратном порядке
; @example
;   string "Hello"
;   string_reverse rax  ; возвращает "olleH"
_function string_reverse, rbx
  get_arg 0
  mov rbx, rax

  string_reverse_links rbx
  copy rax

  ret

; @function string_slice_links
; @description Создает срез строки как ссылки на символы
; @param string - строка для создания среза
; @param start=0 - начальный индекс среза
; @param end=0 - конечный индекс среза (0 означает до конца)
; @param step=1 - шаг среза
; @return Срез строки как ссылки
; @example
;   string "Hello World"
;   string_slice_links rax, 0, 5  ; возвращает "Hello"
_function string_slice_links, rbx, rcx, rdx, r8, r9, r10, r15
  get_arg 0    ; Коллекция
  mov rbx, rax
  get_arg 1    ; Начало
  mov rcx, rax
  get_arg 2    ; Конец
  mov rdx, rax
  get_arg 3    ; Шаг
  mov r8, rax

  cmp rcx, 0
  jne @f
    integer 0
    mov rcx, rax
  @@:

  cmp rdx, 0
  jne @f
    integer -1
    mov rdx, rax
  @@:

  cmp r8, 1
  jne @f
    integer 1
    mov r8, rax
  @@:

  check_type rbx, STRING
  check_type rcx, INTEGER
  check_type rdx, INTEGER
  check_type r8,  INTEGER

  string_length rbx
  integer rax
  mov r15, rax
  is_lower rax, rdx
  boolean_value rax
  delete r15
  cmp rax, 1
  je @f

  integer 0
  mov r15, rax
  is_lower rdx, rax
  boolean_value rax
  delete r15
  cmp rax, 1
  je @f

  jmp .correct_stop

  @@:
    string_length rbx
    integer rax
    mov rdx, rax

  .correct_stop:

  mov r10, 0 ; 0 — прямое направление, 1 — обратное

  integer 0
  mov r15, rax
  is_lower r8, rax
  boolean_value rax
  delete r15
  cmp rax, 1
  jne @f
    negate r8
    mov r8, rax

    mov r10, 1
  @@:

  string ""
  mov r9, rax

  @@:
    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je @f

    string_get_link rbx, rcx
    string_extend_links r9, rax

    integer_add rcx, r8
    mov rcx, rax
    jmp @b
  @@:

  mov rax, r9
  cmp r10, 0
  je @f
    string_reverse_links rax
  @@:

  ret

; @function string_slice
; @description Создает срез строки как копии символов
; @param string - строка для создания среза
; @param start=0 - начальный индекс среза
; @param end=0 - конечный индекс среза (0 означает до конца)
; @param step=1 - шаг среза
; @return Срез строки как копии
; @example
;   string "Hello World"
;   string_slice rax, 0, 5  ; возвращает копию "Hello"
_function string_slice, rbx, rcx, rdx, r8
  get_arg 0    ; Коллекция
  mov rbx, rax
  get_arg 1    ; Начало
  mov rcx, rax
  get_arg 2    ; Конец
  mov rdx, rax
  get_arg 3    ; Шаг
  mov r8, rax

  string_slice_links rbx, rcx, rdx, r8
  copy rax

  ret

; @function string_add_links
; @description Создает новую строку как объединение двух строк со ссылками
; @param string1 - первая строка для объединения
; @param string2 - вторая строка для объединения
; @return Новая строка с объединенными символами
; @example
;   string "Hello"
;   string " World"
;   string_add_links rax, rbx
_function string_add_links, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, STRING

  string_copy_links rbx
  string_extend_links rax, rcx

  ret

; @function string_add
; @description Создает новую строку как объединение двух строк с копиями
; @param string1 - первая строка для объединения
; @param string2 - вторая строка для объединения
; @return Новая строка с объединенными символами
; @example
;   string "Hello"
;   string " World"
;   string_add rax, rbx
_function string_add, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_add_links rbx, rcx
  string_copy rax

  ret

; @function string_mul_links
; @description Создает новую строку как повторение исходной строки (ссылки)
; @param string - строка для повторения
; @param count - количество повторений
; @return Новая строка с повторенными символами
; @example
;   string "Hi"
;   integer 3
;   string_mul_links rax, rbx  ; возвращает "HiHiHi"
_function string_mul_links, rbx, rcx, rdx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, STRING
  check_type rcx, INTEGER

  mov rcx, [rcx + INTEGER_HEADER*8]
  cmp rcx, 0
  jge @f
    neg rcx
    string_reverse_links rbx
    mov rbx, rax
  @@:

  string ""
  mov rdx, rax

  @@:
    cmp rcx, 0
    je @f

    string_extend_links rdx, rbx

    dec rcx
    jmp @b
  @@:

  ret

; @function string_mul
; @description Создает новую строку как повторение исходной строки (копии)
; @param string - строка для повторения
; @param count - количество повторений
; @return Новая строка с повторенными символами
; @example
;   string "Hi"
;   integer 3
;   string_mul rax, rbx  ; возвращает "HiHiHi"
_function string_mul, rbx, rcx
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  string_mul_links rbx, rcx
  copy rax

  ret
