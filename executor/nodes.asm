; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

macro check_node_type node*, type* {
  debug_start "check_node_type"
  enter node, type

  call f_check_node_type

  return
  debug_end "check_node_type"
}

macro access_node variable*, keys* {
  enter variable, keys

  call f_access_node

  return
}

macro assign_node variable*, keys*, value* {
  enter variable, keys, value

  call f_assign_node

  return
}

macro binary_operation_node left_node*, operator*, right_node* {
  enter left_node, operator, right_node

  call f_binary_operation_node

  return
}

macro list_node elements* {
  enter elements

  call f_list_node

  return
}

macro null_node {
  enter

  call f_null_node

  return
}

macro integer_node token* {
  enter token

  call f_integer_node

  return
}

macro float_node token* {
  enter token

  call f_float_node

  return
}

macro boolean_node token* {
  enter token

  call f_boolean_node

  return
}

macro string_node token* {
  enter token

  call f_string_node

  return
}

macro call_node variable*, arguments*, named_arguments* {
  enter variable, arguments, named_arguments

  call f_call_node

  return
}

macro unary_operation_node operator*, operand* {
  enter operator, operand

  call f_unary_operation_node

  return
}

macro dictionary_node elements* {
  enter elements

  call f_dictionary_node

  return
}

macro check_node cases*, else_case* {
  enter cases, else_case

  call f_check_node

  return
}

macro if_node cases*, else_case* {
  enter cases, else_case

  call f_if_node

  return
}

macro for_node variable*, start*, end*, step*, body*, else_case* {
  enter variable, start, end, step, body, else_case

  call f_for_node

  return
}

macro while_node condition*, body*, else_case* {
  enter condition, body, else_case

  call f_while_node

  return
}

macro method_node variable*, arguments*, body*, autoreturn*, class_name, object_name {
  enter variable, arguments, body, autoreturn, class_name, object_name

  call f_method_node

  return
}

macro function_node variable*, arguments*, body*, autoreturn* {
  enter variable, arguments, body, autoreturn

  call f_function_node

  return
}

macro class_node variable*, body*, parents* {
  enter variable, body, parents

  call f_class_node

  return
}

macro delete_node variable* {
  enter variable

  call f_delete_node

  return
}

macro include_node path* {
  enter path

  call f_include_node

  return
}

macro return_node value* {
  enter value

  call f_return_node

  return
}

macro skip_node {
  enter

  call f_skip_node

  return
}

macro break_node {
  enter

  call f_break_node

  return
}

; @function check_node_type
; @debug
; @description Проверяет тип узла AST
; @param node - узел для проверки
; @param type - ожидаемый тип узла
; @return Логическое значение (true/false)
; @example
;   check_node_type node, [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
f_check_node_type:
  get_arg 1
  mov rbx, rax
  get_arg 0
  mov rcx, rax

  string "узел"
  dictionary_get rcx, rax
  is_equal rax, rbx
  boolean_value rax

  ret

; @function access_node
; @description Создает узел доступа к переменной
; @param variable - переменная для доступа
; @param keys - ключи доступа
; @return Узел доступа к переменной
; @example
;   access_node variable, keys
f_access_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [ключи], rax

  ret

; @function assign_node
; @description Создает узел присваивания переменной
; @param variable - переменная для присваивания
; @param keys - ключи доступа
; @param value - значение для присваивания
; @return Узел присваивания
; @example
;   assign_node variable, keys, value
f_assign_node:
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
f_binary_operation_node:
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
f_list_node:
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
f_null_node:
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
f_integer_node:
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
f_float_node:
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
f_boolean_node:
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
f_string_node:
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
f_call_node:
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
f_unary_operation_node:
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
f_dictionary_node:
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
f_check_node:
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
f_if_node:
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
f_for_node:
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
f_while_node:
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
f_method_node:
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
f_function_node:
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
f_class_node:
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
f_delete_node:
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
f_include_node:
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
f_return_node:
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
f_skip_node:
  dictionary
  dictionary_set_link rax, [узел], [УЗЕЛ_ПРОПУСКА]

  ret

; @function break_node
; @description Создает узел оператора break
; @return Узел break
; @example
;   break_node
f_break_node:
  dictionary
  dictionary_set_link rax, [узел], [УЗЕЛ_ПРЕРЫВАНИЯ]

  ret
