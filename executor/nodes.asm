; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function check_node_type
; @debug
; @description Проверяет тип узла AST
; @param node - узел для проверки
; @param type - ожидаемый тип узла
; @return Логическое значение (true/false)
; @example
;   check_node_type node, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
_function check_node_type, rbx, rcx
  get_arg 1
  mov rbx, rax
  get_arg 0
  mov rcx, rax

  string "узел"
  dictionary_get rcx, rax
  is_equal rax, rbx
  boolean_value rax

  ret

; @function access_link_node
; @description Создает узел доступа к переменной
; @param variable - переменная для доступа
; @param keys - ключи доступа
; @return Узел доступа к переменной
; @example
;   access_link_node variable, keys
_function access_link_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ДОСТУПА_К_ССЫЛКЕ_ПЕРЕМЕННОЙ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [ключи], rax

  ret

; @function access_node
; @description Создает узел доступа к переменной
; @param variable - переменная для доступа
; @param keys - ключи доступа
; @return Узел доступа к переменной
; @example
;   access_node variable, keys
_function access_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [ключи], rax

  ret

; @function assign_link_node
; @description Создает узел присваивания ссылки переменной
; @param variable - переменная для присваивания
; @param keys - ключи доступа
; @param value - значение для присваивания
; @return Узел присваивания
; @example
;   assign_link_node variable, keys, value
_function assign_link_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ПРИСВАИВАНИЯ_ССЫЛКИ_ПЕРЕМЕННОЙ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [ключи], rax
  get_arg 2
  dictionary_set_link rbx, [значение], rax

  ret

; @function assign_node
; @description Создает узел присваивания переменной
; @param variable - переменная для присваивания
; @param keys - ключи доступа
; @param value - значение для присваивания
; @return Узел присваивания
; @example
;   assign_node variable, keys, value
_function assign_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [ключи], rax
  get_arg 2
  dictionary_set_link rbx, [значение], rax

  ret

; @function binary_operation_node
; @description Создает узел бинарной операции
; @param left_node - левый операнд
; @param operator - оператор
; @param right_node - правый операнд
; @return Узел бинарной операции
; @example
;   binary_operation_node left, "+", right
_function binary_operation_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ]
  get_arg 0
  dictionary_set_link rbx, [левый_узел], rax
  get_arg 1
  dictionary_set_link rbx, [оператор], rax
  get_arg 2
  dictionary_set_link rbx, [правый_узел], rax

  ret

; @function list_node
; @description Создает узел списка
; @param elements - элементы списка
; @return Узел списка
; @example
;   list_node elements
_function list_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_СПИСКА]
  get_arg 0
  dictionary_set_link rbx, [элементы], rax

  ret

; @function null_node
; @description Создает узел null
; @return Узел null
; @example
;   null_node
_function null_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_НУЛЬ]

  ret

; @function integer_node
; @description Создает узел целого числа
; @param token - токен с числовым значением
; @return Узел целого числа
; @example
;   integer_node token
_function integer_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ЦЕЛОГО_ЧИСЛА]
  get_arg 0
  dictionary_set_link rbx, [значение], rax

  ret

; @function float_node
; @description Создает узел вещественного числа
; @param token - токен с числовым значением
; @return Узел вещественного числа
; @example
;   float_node token
_function float_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ВЕЩЕСТВЕННОГО_ЧИСЛА]
  get_arg 0
  dictionary_set_link rbx, [значение], rax

  ret

; @function boolean_node
; @description Создает узел логического значения
; @param token - токен с логическим значением
; @return Узел логического значения
; @example
;   boolean_node token
_function boolean_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ЛОГИЧЕСКОГО_ЗНАЧЕНИЯ]
  get_arg 0
  dictionary_set_link rbx, [значение], rax

  ret

; @function string_node
; @description Создает узел строки
; @param token - токен со строковым значением
; @return Узел строки
; @example
;   string_node token
_function string_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_СТРОКИ]
  get_arg 0
  dictionary_set_link rbx, [значение], rax

  ret

; @function call_node
; @description Создает узел вызова функции
; @param variable - вызываемая функция
; @param arguments - позиционные аргументы
; @param named_arguments - именованные аргументы
; @return Узел вызова функции
; @example
;   call_node function, args, named_args
_function call_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ВЫЗОВА]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [аргументы], rax
  get_arg 2
  dictionary_set_link rbx, [именованные_аргументы], rax

  ret

; @function unary_operation_node
; @description Создает узел унарной операции
; @param operator - унарный оператор
; @param operand - операнд
; @return Узел унарной операции
; @example
;   unary_operation_node "-", operand
_function unary_operation_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_УНАРНОЙ_ОПЕРАЦИИ]
  get_arg 0
  dictionary_set_link rbx, [оператор], rax
  get_arg 1
  dictionary_set_link rbx, [операнд], rax

  ret

; @function dictionary_node
; @description Создает узел словаря
; @param elements - элементы словаря
; @return Узел словаря
; @example
;   dictionary_node elements
_function dictionary_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_СЛОВАРЯ]
  get_arg 0
  dictionary_set_link rbx, [элементы], rax

  ret

; @function check_node
; @description Создает узел условной конструкции check
; @param cases - случаи для проверки
; @param else_case - блок else
; @return Узел условной конструкции
; @example
;   check_node cases, else_case
_function check_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ПРОВЕРКИ]
  get_arg 0
  dictionary_set_link rbx, [случаи], rax
  get_arg 1
  dictionary_set_link rbx, [случай_иначе], rax

  ret

; @function if_node
; @description Создает узел условной конструкции if
; @param cases - случаи для проверки
; @param else_case - блок else
; @return Узел условной конструкции
; @example
;   if_node cases, else_case
_function if_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ЕСЛИ]
  get_arg 0
  dictionary_set_link rbx, [случаи], rax
  get_arg 1
  dictionary_set_link rbx, [случай_иначе], rax

  ret

; @function for_node
; @description Создает узел цикла for
; @param variable - переменная цикла
; @param start - начальное значение
; @param end - конечное значение
; @param step - шаг цикла
; @param body - тело цикла
; @param else_case - блок else
; @return Узел цикла for
; @example
;   for_node var, start, end, step, body, else_case
_function for_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ДЛЯ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [начало], rax
  get_arg 2
  dictionary_set_link rbx, [конец], rax
  get_arg 3
  dictionary_set_link rbx, [шаг], rax
  get_arg 4
  dictionary_set_link rbx, [тело], rax
  get_arg 5
  dictionary_set_link rbx, [случай_иначе], rax

  ret

; @function while_node
; @description Создает узел цикла while
; @param condition - условие цикла
; @param body - тело цикла
; @param else_case - блок else
; @return Узел цикла while
; @example
;   while_node condition, body, else_case
_function while_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ПОКА]
  get_arg 0
  dictionary_set_link rbx, [условие], rax
  get_arg 1
  dictionary_set_link rbx, [тело], rax
  get_arg 2
  dictionary_set_link rbx, [случай_иначе], rax

  ret

; @function method_node
; @description Создает узел метода класса
; @param variable - имя метода
; @param arguments - аргументы метода
; @param body - тело метода
; @param autoreturn - флаг автоматического возврата
; @param class_name=0 - имя класса
; @param object_name=0 - имя объекта
; @return Узел метода
; @example
;   method_node name, args, body, autoreturn, class, object
_function method_node, rbx, rcx, rdx, r8, r9, r10
  get_arg 0
  mov r10, rax
  get_arg 1
  mov rbx, rax
  get_arg 2
  mov rcx, rax
  get_arg 3
  mov rdx, rax
  get_arg 4
  mov r8, rax
  get_arg 5
  mov r9, rax

  cmp r8, 0
  jne .skip_class_name_default
    string ""
    mov r8, rax

  .skip_class_name_default:

  cmp r9, 0
  jne .skip_object_name_default
    string ""
    mov r9, rax

  .skip_object_name_default:

  dictionary
  dictionary_set_link rbx, [узел], [УЗЕЛ_МЕТОДА]
  dictionary_set_link rbx, [переменная], r10
  dictionary_set_link rbx, [аргументы], rbx
  dictionary_set_link rbx, [тело], rcx
  dictionary_set_link rbx, [автовозвращение], rdx ; Уточнить название
  dictionary_set_link rbx, [имя_класса], r8
  dictionary_set_link rbx, [имя_объекта], r9

  ret

; @function function_node
; @description Создает узел функции
; @param variable - имя функции
; @param arguments - аргументы функции
; @param body - тело функции
; @param autoreturn - флаг автоматического возврата
; @return Узел функции
; @example
;   function_node name, args, body, autoreturn
_function function_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ФУНКЦИИ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [аргументы], rax
  get_arg 2
  dictionary_set_link rbx, [тело], rax
  get_arg 3
  integer rax
  dictionary_set_link rbx, [автовозвращение], rax ; Уточнить название

  ret

; @function class_node
; @description Создает узел класса
; @param variable - имя класса
; @param body - тело класса
; @param parents - родительские классы
; @return Узел класса
; @example
;   class_node name, body, parents
_function class_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_КЛАССА]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [тело], rax
  get_arg 2
  dictionary_set_link rbx, [родители], rax

  ret

; @function delete_node
; @description Создает узел удаления переменной
; @param variable - переменная для удаления
; @return Узел удаления
; @example
;   delete_node variable
_function delete_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_УДАЛЕНИЯ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax

  ret

; @function include_node
; @description Создает узел включения файла
; @param path - путь к файлу
; @return Узел включения
; @example
;   include_node path
_function include_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ВКЛЮЧЕНИЯ]
  get_arg 0
  dictionary_set_link rbx, [путь], rax

  ret

; @function return_node
; @description Создает узел оператора return
; @param value - возвращаемое значение
; @return Узел return
; @example
;   return_node value
_function return_node, rbx
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ВОЗВРАЩЕНИЯ]
  get_arg 0
  dictionary_set_link rbx, [значение], rax

  ret

; @function skip_node
; @description Создает узел оператора skip
; @return Узел skip
; @example
;   skip_node
_function skip_node
  dictionary
  dictionary_set_link rax, [узел], [УЗЕЛ_ПРОПУСКА]

  ret

; @function break_node
; @description Создает узел оператора break
; @return Узел break
; @example
;   break_node
_function break_node
  dictionary
  dictionary_set_link rax, [узел], [УЗЕЛ_ПРЕРЫВАНИЯ]

  ret
