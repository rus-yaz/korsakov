; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; Методы коллекций
;   Конструктор
;   Длина
;   Вместимость
;   Расширить вместимость
;   Установить ссылку на элемент по индексу
;   Установить копию элемента по индексу
;   Получить ссылку на элемент по индексу
;   Получить копию элемента по индексу
;   Копировать ссылки
;   Копировать элементы
;
; Методы списка
;   Добавить ссылку на элемент в конец
;   Добавить копии элемента в конец
;   Изъять ссылку на элемент по индексу
;   Изъять копии элемента по индексу
;   Вставить ссылку на элемент по индексу
;   Вставить копии элемента по индексу
;   Получить индекс элемента
;   Проверить, входит ли значения в список
;   Расширить список элементами списка
;   Расширить список копиями элементов списка
;   Получить развёрнутый список ссылок на элементы
;   Получить развёрнутый список копий элементов
;   Получить срез ссылок на элементы
;   Получить срез копий элементов
;   Сложить списки ссылок на элементы
;   Сложить списки копий элементов
;   Повторить список ссылок на элементы
;   Повторить список копий элементов

; @function list
; @description Создает новый список с указанной начальной вместимостью
; @param capacity=2 - начальная вместимость списка
; @return Объект списка
; @example
;   list  ; создает список с вместимостью 2
;   list 10  ; создает список с вместимостью 10
f_list:
  get_arg 0
  mov rbx, rax

  cmp rbx, 0
  jne @f
    mov rbx, 2
  @@:

  mov rcx, rbx
  imul rcx, 8

  create_block rcx ; Аллокация места для элементов

  mov      rdi, rax ; Источник копирования
  mov byte [rdi], 0 ; Значение, которое будет раскопировано

  mov rsi, rdi ; Место назначения
  inc rsi      ; Смещение от уже назначенного

  rep movsb ; Побайтовое копирование

  mov rcx, rax

  create_block LIST_HEADER*8
  mem_mov [rax + 8*0], LIST ; Тип
  mem_mov [rax + 8*1], 0    ; Длина
  mem_mov [rax + 8*2], rbx  ; Вместимость
  mem_mov [rax + 8*3], rcx  ; Указатель на элементы

  ret

; @function list_length
; @description Возвращает количество элементов в списке
; @param list - список для измерения длины
; @return Количество элементов в списке
; @example
;   list
;   list_append rax, value
;   list_length rax  ; возвращает 1
f_list_length:
  get_arg 0
  check_type rax, LIST

  mov rax, [rax + 8*1]
  ret

; @function list_capacity
; @description Возвращает текущую вместимость списка
; @param list - список для получения вместимости
; @return Вместимость списка
; @example
;   list 10
;   list_capacity rax  ; возвращает 10
f_list_capacity:
  get_arg 0
  check_type rax, LIST

  mov rax, [rax + 8*2]
  ret

; @function list_expand_capacity
; @description Увеличивает вместимость списка в два раза
; @param list - список для расширения вместимости
; @example
;   list 2
;   list_expand_capacity rax  ; увеличивает вместимость до 4
f_list_expand_capacity:
  get_arg 0
  mov rbx, rax

  check_type rbx, LIST
  list_capacity rbx

  imul rax, 2
  mov [rbx + 8*2], rax

  imul rax, 8
  create_block rax
  mov rcx, rax

  list_length rbx
  mem_copy [rbx + 8*3], rcx, rax

  delete_block [rbx + 8*3]
  mov [rbx + 8*3], rcx

  ret

; @function list_set_link
; @description Устанавливает элемент по индексу в список (без копирования)
; @param list - список для установки элемента
; @param index - индекс для установки элемента
; @param value - значение для установки
; @return Список с установленным элементом
; @example
;   list
;   list_append rax, value1
;   string "new_value"
;   list_set_link rax, 0, rbx
f_list_set_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, LIST
  check_type rcx, INTEGER

  ; Запись длины списка
  list_length rbx
  mov r8, rax

  ; Если индекс меньше нуля, то увеличить его на длину списка
  mov rcx, [rcx + 8*1]
  cmp rcx, 0
  jge @f
    add rcx, r8
  @@:

  ; Проверка, входит ли индекс в список
  cmp rcx, r8
  check_error jge, "list_set: Индекс выходит за пределы списка"
  cmp rcx, 0
  check_error jl, "list_set: Индекс выходит за пределы списка"

  mov rax, rbx
  mov rbx, [rbx + 8*3]

  imul rcx, 8
  add rbx, rcx

  mov [rbx], rdx

  ret

; @function list_set
; @description Устанавливает элемент по индексу в список (с копированием)
; @param list - список для установки элемента
; @param index - индекс для установки элемента
; @param value - значение для установки
; @return Список с установленным элементом
; @example
;   list
;   list_append rax, value1
;   string "new_value"
;   list_set rax, 0, rbx
f_list_set:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  copy rdx
  list_set_link rbx, rcx, rax

  ret

; @function list_get_link
; @description Получает элемент по индексу из списка (без копирования)
; @param list - список для получения элемента
; @param index - индекс элемента для получения
; @return Элемент по указанному индексу
; @example
;   list
;   list_append rax, value
;   list_get_link rax, 0  ; возвращает value
f_list_get_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  check_type rcx, INTEGER

  list_length rbx
  mov rdx, rax

  ; Если индекс меньше нуля, то увеличить его на длину списка
  mov rcx, [rcx + INTEGER_HEADER*8]
  cmp rcx, 0
  jge @f
    add rcx, rdx
  @@:

  ; Проверка, входит ли индекс в список
  cmp rcx, rdx
  check_error jge, "list_get: Индекс выходит за пределы списка"
  cmp rcx, 0
  check_error jl, "list_get: Индекс выходит за пределы списка"

  imul rcx, 8
  mov rax, [rbx + 8*3]

  add rax, rcx
  mov rax, [rax]

  ret

; @function list_get
; @description Получает элемент по индексу из списка (с копированием)
; @param list - список для получения элемента
; @param index - индекс элемента для получения
; @return Копия элемента по указанному индексу
; @example
;   list
;   list_append rax, value
;   list_get rax, 0  ; возвращает копию value
f_list_get:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list_get_link rbx, rcx
  copy rax

  ret

; @function list_copy_links
; @description Создает копию списка со ссылками на элементы
; @param list - список для копирования
; @return Копия списка со ссылками
; @example
;   list
;   list_append rax, value
;   list_copy_links rax  ; создает копию со ссылками
f_list_copy_links:
  get_arg 0
  mov rbx, rax

  check_type rbx, LIST

  list_capacity rbx
  list rax
  mov rcx, rax

  mem_mov [rcx + 8*0], [rbx + 8*0]
  mem_mov [rcx + 8*1], [rbx + 8*1]
  mem_copy [rbx + 8*3], [rcx + 8*3], [rcx + 8*1]

  mov rax, rcx
  ret

; @function list_copy
; @description Создает полную копию списка с копированием всех элементов
; @param list - список для копирования
; @return Полная копия списка
; @example
;   list
;   list_append rax, value
;   list_copy rax  ; создает полную копию
f_list_copy:
  get_arg 0
  mov rbx, rax

  check_type rbx, LIST

  list_capacity rbx
  list rax
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

; @function list_append_link
; @description Добавляет элемент в конец списка (без копирования)
; @param list - список для добавления элемента
; @param value - значение для добавления
; @return Список с добавленным элементом
; @example
;   list
;   string "value"
;   list_append_link rax, rbx
f_list_append_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST

  list_length rbx
  mov rdx, rax

  list_capacity rbx
  cmp rdx, rax
  jne @f
    list_expand_capacity rbx
  @@:

  mov r8, rdx
  imul r8, 8  ; Отступ до элемента

  inc rdx
  mov [rbx + 8*1], rdx ; Запись новой длины

  mov rax, [rbx + 8*3] ; Взятие указателя на последовательность элементов
  add rax, r8          ; Смещение до места для нового элемента

  mov [rax], rcx
  mov rax, rbx

  ret

; @function list_append
; @description Добавляет элемент в конец списка (с копированием)
; @param list - список для добавления элемента
; @param value - значение для добавления
; @return Список с добавленным элементом
; @example
;   list
;   string "value"
;   list_append rax, rbx
f_list_append:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  copy rcx
  list_append_link rbx, rax

  ret

; @function list_pop_link
; @description Удаляет и возвращает элемент по индексу (без копирования)
; @param list - список для удаления элемента
; @param index=-1 - индекс элемента для удаления
; @return Удаленный элемент
; @example
;   list
;   list_append rax, value1
;   list_append rax, value2
;   list_pop_link rax, -1  ; удаляет и возвращает последний элемент
f_list_pop_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  cmp rcx, 0
  jne @f
    integer -1
    mov rcx, rax
  @@:

  check_type rbx, LIST
  check_type rcx, INTEGER

  list_length rbx
  mov rdx, rax

  mov rcx, [rcx + INTEGER_HEADER*8]
  cmp rcx, 0
  jge @f
    add rcx, rdx
  @@:

  cmp rcx, rdx
  check_error jge, "list_pop: Индекс выходит за пределы списка"
  cmp rcx, 0
  check_error jl, "list_pop: Индекс выходит за пределы списка"

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

  ret

; @function list_pop
; @description Удаляет и возвращает элемент по индексу (с копированием)
; @param list - список для удаления элемента
; @param index=-1 - индекс элемента для удаления
; @return Копия удаленного элемента
; @example
;   list
;   list_append rax, value1
;   list_append rax, value2
;   list_pop rax, -1  ; удаляет и возвращает копию последнего элемента
f_list_pop:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list_pop_link rbx, rcx
  copy rax

  ret

; @function list_insert_link
; @description Вставляет элемент по индексу в список (без копирования)
; @param list - список для вставки элемента
; @param index - индекс для вставки элемента
; @param value - значение для вставки
; @return Список с вставленным элементом
; @example
;   list
;   list_append rax, value1
;   string "inserted"
;   list_insert_link rax, 0, rbx  ; вставляет в начало
f_list_insert_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, LIST
  check_type rcx, INTEGER

  list_length rbx
  mov r8, rax

  list_capacity rbx

  cmp r8, rax
  jne @f
    list_expand_capacity rbx
  @@:

  mov rcx, [rcx + 8*1]
  cmp rcx, 0
  jge @f
    add rcx, r8
  @@:

  cmp rcx, r8
  check_error jge, "list_insert: Индекс выходит за пределы списка"
  cmp rcx, 0
  check_error jl, "list_insert: Индекс выходит за пределы списка"

  inc r8
  mov [rbx + 8*1], r8

  dec r8
  sub r8, rcx
  mov r10, r8
  imul r8, 8

  mov rax, [rbx + 8*3]
  add rax, r8

  mov r9, rax
  sub r9, 8

  @@:
    cmp r10, 0
    je @f

    mem_mov [rax], [r9]

    sub r9, 8
    sub rax, 8

    dec r10
    jmp @b
  @@:


  mov [rax], rdx

  mov rax, rbx
  ret

; @function list_insert
; @description Вставляет элемент по индексу в список (с копированием)
; @param list - список для вставки элемента
; @param index - индекс для вставки элемента
; @param value - значение для вставки
; @return Список с вставленным элементом
; @example
;   list
;   list_append rax, value1
;   string "inserted"
;   list_insert rax, 0, rbx  ; вставляет в начало
f_list_insert:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  copy rdx
  list_insert_link rbx, rcx, rax

  ret

; @function list_index
; @description Возвращает индекс первого вхождения элемента в список
; @param list - список для поиска элемента
; @param value - значение для поиска
; @return Индекс элемента или -1, если не найден
; @example
;   list
;   list_append rax, value1
;   list_append rax, value2
;   list_index rax, value1  ; возвращает 0
f_list_index:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST

  integer 0
  mov rdx, rax

  list_length rbx
  mov r8, rax

  @@:
    cmp [rdx + INTEGER_HEADER*8], r8
    je @f

    list_get_link rbx, rdx
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

; @function list_include
; @description Проверяет, содержится ли элемент в списке
; @param list - список для проверки
; @param value - значение для проверки
; @return Булево значение (true если элемент найден)
; @example
;   list
;   list_append rax, value1
;   list_include rax, value1  ; возвращает true
f_list_include:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST

  list_index rbx, rcx
  mov rbx, [rax + INTEGER_HEADER*8]
  delete rax

  cmp rbx, -1
  je @f
    boolean 1
    ret

  @@:
    boolean 0
    ret

; @function list_extend_links
; @description Добавляет все элементы из другого списка как ссылки
; @param list - целевой список для расширения
; @param other - список с элементами для добавления
; @return Расширенный список
; @example
;   list
;   list_append rax, value1
;   list
;   list_append rbx, value2
;   list_extend_links rax, rbx
f_list_extend_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  check_type rcx, LIST

  list_length rcx
  mov rdx, rax

  integer 0
  mov r8, rax

  @@:
    cmp rdx, 0
    je @f

    list_get_link rcx, r8
    list_append_link rbx, rax

    integer_inc r8
    dec rdx
    jmp @b
  @@:

  delete r8

  mov rax, rbx
  ret

; @function list_extend
; @description Добавляет все элементы из другого списка как копии
; @param list - целевой список для расширения
; @param other - список с элементами для добавления
; @return Расширенный список
; @example
;   list
;   list_append rax, value1
;   list
;   list_append rbx, value2
;   list_extend rax, rbx
f_list_extend:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  copy rcx
  mov rcx, rax

  list_extend_links rbx, rcx
  delete_block rcx

  ret

; @function list_reverse_links
; @description Создает новый список с элементами в обратном порядке (ссылки)
; @param list - список для разворота
; @return Новый список с элементами в обратном порядке
; @example
;   list
;   list_append rax, value1
;   list_append rax, value2
;   list_reverse_links rax  ; возвращает [value2, value1]
f_list_reverse_links:
  get_arg 0
  mov rbx, rax

  check_type rbx, LIST

  list_capacity rbx
  list rax
  mov r9, rax

  mem_mov [r9 + 8*0], [rbx + 8*0]
  mem_mov [r9 + 8*1], [rbx + 8*1]

  list_length rbx
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

; @function list_reverse
; @description Создает новый список с элементами в обратном порядке (копии)
; @param list - список для разворота
; @return Новый список с элементами в обратном порядке
; @example
;   list
;   list_append rax, value1
;   list_append rax, value2
;   list_reverse rax  ; возвращает копии в обратном порядке
f_list_reverse:
  get_arg 0
  mov rbx, rax

  list_reverse_links rbx
  copy rax

  ret

; @function list_slice_links
; @description Создает срез списка как ссылки на элементы
; @param list - список для создания среза
; @param start=0 - начальный индекс среза
; @param end=-1 - конечный индекс среза
; @param step=1 - шаг среза
; @return Срез списка как ссылки
; @example
;   list
;   list_append rax, value1
;   list_append rax, value2
;   list_append rax, value3
;   list_slice_links rax, 0, 2  ; возвращает [value1, value2]
f_list_slice_links:
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

  cmp r8, 0
  jne @f
    integer 1
    mov r8, rax
  @@:

  check_type rbx, LIST
  check_type rcx, INTEGER
  check_type rdx, INTEGER
  check_type r8,  INTEGER

  list_length rbx
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
    list_length rbx
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

  list
  mov r9, rax

  @@:
    is_equal rcx, rdx
    boolean_value rax
    cmp rax, 1
    je @f

    list_get_link rbx, rcx
    list_append_link r9, rax

    integer_add rcx, r8
    mov rcx, rax
    jmp @b
  @@:

  mov rax, r9
  cmp r10, 0
  je @f
    list_reverse_links rax
  @@:

  ret

; @function list_slice
; @description Создает срез списка как копии элементов
; @param list - список для создания среза
; @param start=0 - начальный индекс среза
; @param end=-1 - конечный индекс среза
; @param step=1 - шаг среза
; @return Срез списка как копии
; @example
;   list
;   list_append rax, value1
;   list_append rax, value2
;   list_append rax, value3
;   list_slice rax, 0, 2  ; возвращает копии [value1, value2]
f_list_slice:
  get_arg 0    ; Коллекция
  mov rbx, rax
  get_arg 1    ; Начало
  mov rcx, rax
  get_arg 2    ; Конец
  mov rdx, rax
  get_arg 3    ; Шаг
  mov r8, rax

  list_slice_links rbx, rcx, rdx, r8
  copy rax

  ret

; @function list_add_links
; @description Создает новый список как объединение двух списков со ссылками
; @param list1 - первый список для объединения
; @param list2 - второй список для объединения
; @return Новый список с объединенными элементами
; @example
;   list
;   list_append rax, value1
;   list
;   list_append rbx, value2
;   list_add_links rax, rbx
f_list_add_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  check_type rcx, LIST

  list_copy_links rbx
  list_extend_links rax, rcx

  ret

; @function list_add
; @description Создает новый список как объединение двух списков с копиями
; @param list1 - первый список для объединения
; @param list2 - второй список для объединения
; @return Новый список с объединенными элементами
; @example
;   list
;   list_append rax, value1
;   list
;   list_append rbx, value2
;   list_add rax, rbx
f_list_add:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list_add_links rbx, rcx
  list_copy rax

  ret

; @function list_mul_links
; @description Создает новый список как повторение исходного списка (ссылки)
; @param list - список для повторения
; @param count - количество повторений
; @return Новый список с повторенными элементами
; @example
;   list
;   list_append rax, value
;   integer 3
;   list_mul_links rax, rbx  ; возвращает [value, value, value]
f_list_mul_links:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  check_type rcx, INTEGER

  mov rcx, [rcx + INTEGER_HEADER*8]
  cmp rcx, 0
  jge @f
    neg rcx
    list_reverse_links rbx
    mov rbx, rax
  @@:

  list
  mov rdx, rax

  @@:
    cmp rcx, 0
    je @f

    list_extend_links rdx, rbx

    dec rcx
    jmp @b
  @@:

  ret

; @function list_mul
; @description Создает новый список как повторение исходного списка (копии)
; @param list - список для повторения
; @param count - количество повторений
; @return Новый список с повторенными элементами
; @example
;   list
;   list_append rax, value
;   integer 3
;   list_mul rax, rbx  ; возвращает копии [value, value, value]
f_list_mul:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  list_mul_links rbx, rcx
  copy rax

  ret
