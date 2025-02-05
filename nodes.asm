; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

section "nodes" executable

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

macro number_node token* {
  enter token

  call f_number_node

  return
}

macro string_node token* {
  enter token

  call f_string_node

  return
}

macro call_node variable*, arguments* {
  enter variable, arguments

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

  call f_delete_node

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

f_access_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [ключи], rax

  ret

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

f_list_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_СПИСКА]
  get_arg 0
  dictionary_set_link rbx, [элементы], rax

  ret

f_number_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ЧИСЛА]
  get_arg 0
  dictionary_set_link rbx, [значение], rax

  ret

f_string_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_СТРОКИ]
  get_arg 0
  dictionary_set_link rbx, [значение], rax

  ret

f_call_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ВЫЗОВА]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax
  get_arg 1
  dictionary_set_link rbx, [аргументы], rax

  ret

f_unary_operation_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_УНАРНОЙ_ОПЕРАЦИИ]
  get_arg 0
  dictionary_set_link rbx, [оператор], rax
  get_arg 1
  dictionary_set_link rbx, [операнд], rax

  ret

f_dictionary_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_СЛОВАРЯ]
  get_arg 0
  dictionary_set_link rbx, [элементы], rax

  ret

f_check_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ПРОВЕРКИ]
  get_arg 0
  dictionary_set_link rbx, [случаи], rax
  get_arg 1
  dictionary_set_link rbx, [случай_иначе], rax

  ret

f_if_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ЕСЛИ]
  get_arg 0
  dictionary_set_link rbx, [случаи], rax
  get_arg 1
  dictionary_set_link rbx, [случай_иначе], rax

  ret

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
  dictionary_set_link rbx, [автовозвращение], rax ; Уточнить название

  ret

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

f_delete_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_УДАЛЕНИЯ]
  get_arg 0
  dictionary_set_link rbx, [переменная], rax

  ret

f_include_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_ВКЛЮЧЕНИЯ]
  get_arg 0
  dictionary_set_link rbx, [путь], rax

  ret

f_return_node:
  dictionary
  mov rbx, rax

  dictionary_set_link rbx, [узел], [УЗЕЛ_УДАЛЕНИЯ]
  get_arg 0
  dictionary_set_link rbx, [значение], rax

  ret

f_skip_node:
  dictionary
  dictionary_set_link rax, [узел], [УЗЕЛ_ПРОПУСКА]

  ret

f_break_node:
  dictionary
  dictionary_set_link rax, [узел], [УЗЕЛ_ПРЕРЫВАНИЯ]

  ret
