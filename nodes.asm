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

macro for_node variable*, start*, end*, step*, body*, return_null*, else_case* {
  enter variable, start, end, step, body, return_null, else_case

  call f_for_node

  return
}

macro while_node condition*, body*, return_null*, else_case* {
  enter condition, body, return_null, else_case

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
  mov rcx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ]
  dictionary_set rax, [переменная], rcx
  dictionary_set rax, [ключи], rbx

  ret

f_assign_node:
  mov rdx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ]
  dictionary_set rax, [переменная], rdx
  dictionary_set rax, [ключи], rbx
  dictionary_set rax, [значение], rcx

  ret

f_binary_operation_node:
  mov rdx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ]
  dictionary_set rax, [левый_узел], rdx
  dictionary_set rax, [оператор], rbx
  dictionary_set rax, [правый_узел], rcx

  ret

f_list_node:
  mov rbx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_СПИСКА]
  dictionary_set rax, [элементы], rbx

  ret

f_number_node:
  mov rbx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ЧИСЛА]
  dictionary_set rax, [токен], rbx

  ret

f_string_node:
  mov rbx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_СТРОКИ]
  dictionary_set rax, [токен], rbx

  ret

f_call_node:
  mov rcx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ВЫЗОВА]
  dictionary_set rax, [переменная], rcx
  dictionary_set rax, [аргументы], rbx

  ret

f_unary_operation_node:
  mov rcx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_УНАРНОЙ_ОПЕРАЦИИ]
  dictionary_set rax, [оператор], rcx
  dictionary_set rax, [операнд], rbx

  ret

f_dictionary_node:
  mov rbx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_СЛОВАРЯ]
  dictionary_set rax, [элементы], rbx

  ret

f_check_node:
  mov rcx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ПРОВЕРКИ]
  dictionary_set rax, [случаи], rcx
  dictionary_set rax, [случай_иначе], rbx

  ret

f_if_node:
  mov rcx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ЕСЛИ]
  dictionary_set rax, [случаи], rcx
  dictionary_set rax, [случай_иначе], rbx

  ret

f_for_node:
  mov r11, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ДЛЯ]
  dictionary_set rax, [переменная], r11
  dictionary_set rax, [начало], rbx
  dictionary_set rax, [конец], rcx
  dictionary_set rax, [шаг], rdx
  dictionary_set rax, [тело], r8
  dictionary_set rax, [вернуть_нуль], r9
  dictionary_set rax, [случай_иначе], r10

  ret

f_while_node:
  mov r8, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ПОКА]
  dictionary_set rax, [условие], r8
  dictionary_set rax, [тело], rbx
  dictionary_set rax, [вернуть_нуль], rcx
  dictionary_set rax, [случай_иначе], rdx

  ret

f_method_node:
  mov r10, rax

  cmp r8, 0
  jne .skip_class_name_default
    string_copy [пустая_строка]
    mov r8, rax

  .skip_class_name_default:

  cmp r9, 0
  jne .skip_object_name_default
    string_copy [пустая_строка]
    mov r9, rax

  .skip_object_name_default:

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_МЕТОДА]
  dictionary_set rax, [переменная], r10
  dictionary_set rax, [аргументы], rbx
  dictionary_set rax, [тело], rcx
  dictionary_set rax, [автовозвращение], rdx ; Уточнить название
  dictionary_set rax, [имя_класса], r8
  dictionary_set rax, [имя_объекта], r9

  ret

f_function_node:
  mov r8, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ФУНКЦИИ]
  dictionary_set rax, [переменная], r8
  dictionary_set rax, [аргументы], rbx
  dictionary_set rax, [тело], rcx
  dictionary_set rax, [автовозвращение], rdx ; Уточнить название

  ret

f_class_node:
  mov rdx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_КЛАССА]
  dictionary_set rax, [переменная], rdx
  dictionary_set rax, [тело], rbx
  dictionary_set rax, [родители], rcx

  ret

f_delete_node:
  mov rbx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_УДАЛЕНИЯ]
  dictionary_set rax, [переменная], rbx

  ret

f_include_node:
  mov rbx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ВКЛЮЧЕНИЯ]
  dictionary_set rax, [путь], rbx

  ret

f_return_node:
  mov rbx, rax

  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_УДАЛЕНИЯ]
  dictionary_set rax, [значение], rbx

  ret

f_skip_node:
  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ПРОПУСКА]

  ret

f_break_node:
  dictionary 0
  dictionary_set rax, [узел], [УЗЕЛ_ПРЕРЫВАНИЯ]

  ret
