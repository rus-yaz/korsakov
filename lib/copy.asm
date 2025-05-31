; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_copy:
  get_arg 0
  mov rbx, [rax]

  cmp rbx, NULL
  jne .not_null
    null
    ret
  .not_null:

  cmp rbx, INTEGER
  jne .not_integer
    integer_copy rax
    ret
  .not_integer:

  cmp rbx, FLOAT
  jne .not_float
    float_copy rax
    ret
  .not_float:

  cmp rbx, BOOLEAN
  jne .not_boolean
    boolean_copy rax
    ret
  .not_boolean:

  cmp rbx, COLLECTION
  jne .not_collection
    collection_copy rax
    ret
  .not_collection:

  cmp rbx, LIST
  jne .not_list
    list_copy rax
    ret
  .not_list:

  cmp rbx, STRING
  jne .not_string
    string_copy rax
    ret
  .not_string:

  cmp rbx, DICTIONARY
  jne .not_dictionary
    dictionary_copy rax
    ret
  .not_dictionary:

  cmp rbx, FUNCTION
  jne .not_function
    function_copy rax
    ret
  .not_function:

  type_to_string rbx
  mov rbx, rax
  string "copy: Нет функции копирования для типа"
  mov rcx, rax

  list
  list_append_link rax, rcx
  list_append_link rax, rbx
  error rax
  exit -1
