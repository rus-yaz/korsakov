; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

macro push [arg] {
  push arg
}

macro pushsd [arg] {
  sub rsp, 8
  movsd [rsp], xmm#arg
}

macro pop [arg] {
  pop arg
}

macro popsd [arg] {
  movsd xmm#arg, [rsp]
  add rsp, 8
}

macro enter [arg] {
  common
    push rbp, rax, rbx, rcx, rdx, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15
    count = 0

  reverse
    if arg eqtype
    else
      mov rbp, arg
      push rbp
      count = count + 1
    end if

  common
    push count
    mov rbp, rsp
}

macro get_arg index {
  mov rax, index
  cmp rax, 0
  jge @f

    exit 100
  @@:

  mov rax, [rbp]
  cmp rax, index
  jg @f

    exit 100
  @@:

  mov rax, index
  mov rax, [rbp + (1 + index) * 8]
}

macro leave {
  pop rax
  imul rax, 8
  add rsp, rax
  pop r15, r14, r13, r12, r11, r10, r9, r8, rdi, rsi, rdx, rcx, rbx, rax, rbp
}

macro return {
  mov rbp, rax
  pop rax

  imul rax, 8
  add rsp, rax

  pop r15, r14, r13, r12, r11, r10, r9, r8, rdi, rsi, rdx, rcx, rbx, rax
  mov rax, rbp

  pop rbp
}

macro mem_mov dst*, src* {
  push r15
  mov r15, src
  mov dst, r15
  pop r15
}

macro mem_movsd dst*, src* {
  pushsd 0

  movsd xmm0, src
  movsd dst, xmm0

  popsd 0
}

macro exit code*, buffer = 0 {
  if buffer eq 0
  else
    if code eq 0
      print_raw buffer
      raw_string 10
      print_raw rax
    else
      error_raw buffer
      raw_string 10
      error_raw rax
    end if
  end if

  sys_exit code
}

macro raw_string [str*] {
  common
    jmp @f
      a = $
      db str, 0
    @@:
    mov rax, a
}

macro binary_string [str*] {
  common
    raw_string str
    buffer_to_binary rax
}

macro string [str*] {
  common
    raw_string str
    buffer_to_string rax
}

macro raw_float value = 0.0 {
  jmp @f
    a = $
    dq value
  @@:
  mov rax, a
}

macro float value {
  raw_float value
  buffer_to_float rax
}

macro init [module_name] {
  common
    if NOSTD eqtype
    else
      _include
    end if

  forward
    if module_name eq ""
    else
      _include module_name
    end if

  common
    start:
    if NOSTD eqtype
    else
      _init
    end if
}

macro _include name {
  include "modules/"#`name#".asm"
}

macro _init name {
  init_#name
}

macro program_exit code = 0 {
  enter code

  call f_program_exit
}

macro buffer_length buffer_ptr* {
  enter buffer_ptr

  call f_buffer_length

  return
}

macro sys_print ptr*, size* {
  enter ptr, size

  call f_sys_print

  leave
}

macro sys_error ptr*, size* {
  enter ptr, size

  call f_sys_error

  leave
}

macro mem_copy source*, destination*, size* {
  enter source, destination, size

  call f_mem_copy

  leave
}

macro check_error operation*, message* {
  push rax

  raw_string message, 10
  operation f_check_error

  pop rax
}

macro type_to_string type* {
  enter type

  call f_type_to_string

  return
}

macro type_header_size type* {
  enter type

  call f_type_header_size

  return
}

macro type_full_size type* {
  enter type

  call f_type_full_size

  return
}

macro check_type variable_ptr*, type* {
  enter variable_ptr, type

  call f_check_type

  leave
}

macro addition first*, second* {
  enter first, second

  call f_addition

  return
}

macro subtraction first*, second* {
  enter first, second

  call f_subtraction

  return
}

macro multiplication first*, second* {
  enter first, second

  call f_multiplication

  return
}

macro division first*, second* {
  enter first, second

  call f_division

  return
}

macro negate value* {
  enter value

  call f_negate

  return
}

macro boolean value* {
  enter value

  call f_boolean

  return
}

macro boolean_copy boolean* {
  enter boolean

  call f_boolean_copy

  return
}

macro boolean_value boolean* {
  enter boolean

  call f_boolean_value

  return
}

macro boolean_not boolean {
  enter boolean

  call f_boolean_not

  return
}

macro boolean_and boolean_1*, boolean_2* {
  enter boolean_1, boolean_2

  call f_boolean_and

  return
}

macro boolean_or boolean_1*, boolean_2* {
  enter boolean_1, boolean_2

  call f_boolean_or

  return
}

macro delete [variable*] {
  enter variable

  call f_delete

  leave
}

macro dictionary keys = 0, values = 0 {
  enter keys, values

  call f_dictionary

  return
}

macro dictionary_from_lists keys = 0, values = 0 {
  enter keys, values

  call f_dictionary_from_lists

  return
}

macro dictionary_from_pairs pairs = 0 {
  enter pairs

  call f_dictionary_from_pairs

  return
}

macro dictionary_length dictionary* {
  enter dictionary

  call f_dictionary_length

  return
}

macro dictionary_capacity dictionary* {
  enter dictionary

  call f_dictionary_capacity

  return
}

macro dictionary_copy_links dictionary* {
  enter dictionary

  call f_dictionary_copy_links

  return
}

macro dictionary_copy dictionary* {
  enter dictionary

  call f_dictionary_copy

  return
}

macro dictionary_items_links dictionary* {
  enter dictionary

  call f_dictionary_items_links

  return
}

macro dictionary_items dictionary* {
  enter dictionary

  call f_dictionary_items

  return
}

macro dictionary_keys_links dictionary* {
  enter dictionary

  call f_dictionary_keys_links

  return
}

macro dictionary_keys dictionary* {
  enter dictionary

  call f_dictionary_keys

  return
}

macro dictionary_values_links dictionary* {
  enter dictionary

  call f_dictionary_values_links

  return
}

macro dictionary_values dictionary* {
  enter dictionary

  call f_dictionary_values

  return
}

macro dictionary_get_link dictionary*, key*, default_value = 0 {
  enter dictionary, key, default_value

  call f_dictionary_get_link

  return
}

macro dictionary_get dictionary*, key*, default_value = 0 {
  enter dictionary, key, default_value

  call f_dictionary_get

  return
}

macro dictionary_set_link dictionary*, key*, value* {
  enter dictionary, key, value

  call f_dictionary_set_link

  return
}

macro dictionary_set dictionary*, key*, value* {
  enter dictionary, key, value

  call f_dictionary_set

  return
}

macro dictionary_add_links dictionary1*, dictionary2* {
  enter  dictionary1, dictionary2

  call f_dictionary_add_links

  return
}

macro dictionary_add dictionary1*, dictionary2* {
  enter  dictionary1, dictionary2

  call f_dictionary_add

  return
}

macro run command*, env*, wait = 1 {
  enter command, env, wait

  call f_run

  leave
}

macro get_file_stat_buffer filename* {
  enter filename

  call f_get_file_stat_buffer

  return
}

macro get_file_size filename* {
  enter filename

  call f_get_file_size

  return
}

macro open_file filename*, flags = O_RDONLY, mode = 444o {
  enter filename, flags, mode

  call f_open_file

  return
}

macro close_file file* {
  enter file

  call f_close_file

  leave
}

macro read_file file* {
  enter file

  call f_read_file

  return
}

macro write_file file*, string* {
  enter file, string

  call f_write_file

  leave
}

macro get_absolute_path path* {
  enter path

  call f_get_absolute_path

  return
}

macro is_equal val_1*, val_2* {
  enter val_1, val_2

  call f_is_equal

  return
}

macro is_not_equal val_1*, val_2* {
  enter val_1, val_2

  call f_is_not_equal

  return
}

macro is_lower val_1*, val_2* {
  enter val_1, val_2

  call f_is_lower

  return
}

macro is_greater val_1*, val_2* {
  enter val_1, val_2

  call f_is_greater

  return
}

macro is_lower_or_equal val_1*, val_2* {
  enter val_1, val_2

  call f_is_lower_or_equal

  return
}

macro is_greater_or_equal val_1*, val_2* {
  enter val_1, val_2

  call f_is_greater_or_equal

  return
}

macro copy value {
  enter value

  call f_copy

  return
}

macro allocate_heap {
  enter

  call f_allocate_heap

  leave
}

macro free_block [block*] {
  enter block

  call f_free_block

  leave
}

macro merge_blocks block_1, block_2 {
  enter block_1, block_2

  call f_merge_blocks

  leave
}

macro delete_block [block*] {
  enter block

  call f_delete_block

  leave
}

macro create_block size* {
  enter size

  call f_create_block

  return
}

macro integer value* {
  enter value

  call f_integer

  return
}

macro string_to_integer integer* {
  enter integer

  call f_string_to_integer

  return
}

macro integer_neg int* {
  enter int

  call f_integer_neg

  return
}

macro integer_copy int* {
  enter int

  call f_integer_copy

  return
}

macro integer_inc int* {
  enter int

  call f_integer_inc

  return
}

macro integer_dec int* {
  enter int

  call f_integer_dec

  return
}

macro integer_add int_1*, int_2* {
  enter int_1, int_2

  call f_integer_add

  return
}

macro integer_sub int_1*, int_2* {
  enter int_1, int_2

  call f_integer_sub

  return
}

macro integer_mul int_1*, int_2* {
  enter int_1, int_2

  call f_integer_mul

  return
}
macro integer_div int_1*, int_2* {
  enter int_1, int_2

  call f_integer_div

  return
}

macro float_to_integer float {
  enter float

  call f_float_to_integer

  return
}

macro buffer_to_float buffer {
  enter buffer

  call f_buffer_to_float

  return
}

macro float_copy float {
  enter float

  call f_float_copy

  return
}

macro float_add float_1, float_2 {
  enter float_1, float_2

  call f_float_add

  return
}

macro float_sub float_1, float_2 {
  enter float_1, float_2

  call f_float_sub

  return
}

macro float_mul float_1, float_2 {
  enter float_1, float_2

  call f_float_mul

  return
}

macro float_div float_1, float_2 {
  enter float_1, float_2

  call f_float_div

  return
}

macro float_neg float {
  enter float

  call f_float_neg

  return
}

macro integer_to_float integer {
  enter integer

  call f_integer_to_float

  return
}

macro string_to_float string {
  enter string

  call f_string_to_float

  return
}

macro collection capacity = 0 {
  enter capacity

  call f_collection

  return
}

macro collection_length collection* {
  enter collection

  call f_collection_length

  return
}

macro collection_capacity collection* {
  enter collection

  call f_collection_capacity

  return
}

macro collection_expand_capacity collection* {
  enter collection

  call f_collection_expand_capacity

  return
}

macro collection_append_link collection*, item* {
  enter collection, item

  call f_collection_append_link

  return
}

macro collection_append collection*, item* {
  enter collection, item

  call f_collection_append

  return
}

macro collection_expand_links collection_1*, collection_2* {
  enter collection_1, collection_2

  call f_collection_expand_links

  return
}

macro collection_expand collection_1*, collection_2* {
  enter collection_1, collection_2

  call f_collection_expand

  return
}

macro collection_get_link collection*, index* {
  enter collection, index

  call f_collection_get_link

  return
}

macro collection_get collection*, index* {
  enter collection, index

  call f_collection_get

  return
}

macro collection_copy_links collection* {
  enter collection

  call f_collection_copy_links

  return
}

macro collection_copy collection* {
  enter collection

  call f_collection_copy

  return
}

macro collection_index collection*, item* {
  enter collection, item

  call f_collection_index

  return
}

macro collection_include collection*, item* {
  enter collection, item

  call f_collection_include

  return
}

macro collection_set_link collection*, index*, item* {
  enter collection, index, item

  call f_collection_set_link

  return
}

macro collection_set collection*, index*, item* {
  enter collection, index, item

  call f_collection_set

  return
}

macro collection_pop_link collection*, index = 0 {
  enter collection, index

  call f_collection_pop_link

  return
}

macro collection_pop collection*, index = 0 {
  enter collection, index

  call f_collection_pop

  return
}

macro collection_insert_link collection*, index*, item* {
  enter collection, index, item

  call f_collection_insert_link

  return
}

macro collection_insert collection*, index*, item* {
  enter collection, index, item

  call f_collection_insert

  return
}

macro collection_add_links collection_1*, collection_2* {
  enter collection_1, collection_2

  call f_collection_add_links

  return
}

macro collection_add collection_1*, collection_2* {
  enter collection_1, collection_1

  call f_collection_add

  return
}

macro collection_reverse_links collection* {
  enter collection

  call f_collection_reverse_links

  return
}

macro collection_reverse collection* {
  enter collection

  call f_collection_reverse

  return
}

macro collection_slice_links collection*, start = 0, stop = 0, step = 0 {
  enter collection, start, stop, step

  call f_collection_slice_links

  return
}

macro collection_slice collection*, start = 0, stop = 0, step = 0 {
  enter collection, start, stop, step

  call f_collection_slice

  return
}

macro is_collection value* {
  enter value

  call f_is_collection

  return
}

macro list capacity = 0 {
  enter capacity

  call f_list

  return
}

macro list_length list* {
  enter list

  call f_list_length

  return
}

macro list_capacity list* {
  enter list

  call f_list_capacity

  return
}

macro list_append_link list*, item* {
  enter list, item

  call f_list_append_link

  return
}

macro list_append list*, item* {
  enter list, item

  call f_list_append

  return
}

macro list_add_links list_1*, list_2* {
  enter list_1, list_2

  call f_list_add_links

  return
}

macro list_add list_1*, list_2* {
  enter list_1, list_2

  call f_list_add

  return
}

macro list_extend_links list_1*, list_2* {
  enter list_1, list_2

  call f_list_extend_links

  return
}

macro list_extend list_1*, list_2* {
  enter list_1, list_2

  call f_list_extend

  return
}

macro list_get_link list*, index* {
  enter list, index

  call f_list_get_link

  return
}

macro list_get list*, index* {
  enter list, index

  call f_list_get

  return
}

macro list_copy_links list* {
  enter list

  call f_list_copy_links

  return
}

macro list_copy list* {
  enter list

  call f_list_copy

  return
}

macro list_index list*, item* {
  enter list, item

  call f_list_index

  return
}

macro list_include list*, item* {
  enter list, item

  call f_list_include

  return
}

macro list_set_link list*, index*, item* {
  enter list, index, item

  call f_list_set_link

  return
}

macro list_set list*, index*, item* {
  enter list, index, item

  call f_list_set

  return
}

macro list_pop_link list*, index = 0 {
  enter list, index

  call f_list_pop_link

  return
}

macro list_pop list*, index = 0 {
  enter list, index

  call f_list_pop

  return
}

macro list_insert_link list*, index*, item* {
  enter list, index, item

  call f_list_insert_link

  return
}

macro list_insert list*, index*, item* {
  enter list, index, item

  call f_list_insert

  return
}

macro list_mul list*, integer* {
  enter list, integer

  call f_list_mul

  return
}

macro list_slice_links list*, start = 0, stop = 0, step = 0 {
  enter list, start, stop, step

  call f_list_slice_links

  return
}

macro list_slice list*, start = 0, stop = 0, step = 0 {
  enter list, start, stop, step

  call f_list_slice

  return
}

macro null {
  enter

  call f_null

  return
}

macro print_raw raw_string_link* {
  enter raw_string_link

  call f_print_raw

  leave
}

macro print_binary binary_string_link* {
  enter binary_string_link

  call f_print_binary

  leave
}

macro print arguments*, separator = 0, end_of_string = 0 {
  enter arguments, separator, end_of_string

  call f_print

  leave
}

macro error_raw raw_string_link* {
  enter raw_string_link

  call f_error_raw

  leave
}

macro error_binary binary_string_link* {
  enter binary_string_link

  call f_error_binary

  leave
}

macro error arguments*, separator = 0, end_of_string = 0 {
  enter arguments, separator, end_of_string

  call f_error

  leave
}

macro buffer_to_binary buffer_addr* {
  enter buffer_addr

  call f_buffer_to_binary

  return
}

macro binary_to_string binary_addr* {
  enter binary_addr

  call f_binary_to_string

  return
}

macro buffer_to_string buffer_addr* {
  enter buffer_addr

  call f_buffer_to_string

  return
}

macro binary_length binary* {
  enter binary

  call f_binary_length

  return
}

macro string_to_binary string* {
  enter string

  call f_string_to_binary

  return
}

macro string_length string* {
  enter string

  call f_string_length

  return
}

macro string_capacity string* {
  enter string

  call f_string_capacity

  return
}

macro string_copy_links string* {
  enter string

  call f_string_copy_links

  return
}

macro string_copy string* {
  enter string

  call f_string_copy

  return
}

macro string_add_links string_1*, string_2* {
  enter string_1, string_2

  call f_string_add_links

  return
}

macro string_add string_1*, string_2* {
  enter string_1, string_2

  call f_string_add

  return
}

macro string_extend_links string_1*, string_2* {
  enter string_1, string_2

  call f_string_extend_links

  return
}

macro string_extend string_1*, string_2* {
  enter string_1, string_2

  call f_string_extend

  return
}

macro string_get_link string*, index* {
  enter string, index

  call f_string_get_link

  return
}

macro string_get string*, index* {
  enter string, index

  call f_string_get

  return
}

macro string_set_link string*, index*, value* {
  enter string, index, value

  call f_string_set_link

  return
}

macro string_set string*, index*, value* {
  enter string, index, value

  call f_string_set

  return
}

macro split_links string*, separator = 0, parts_count = 0 {
  enter string, separator, parts_count

  call f_split_links

  return
}

macro split string*, separator = 0, parts_count = 0 {
  enter string, separator, parts_count

  call f_split

  return
}

macro split_from_right_links string*, separator = 0, parts_count = 0 {
  enter string, separator, parts_count

  call f_split_from_right_links

  return
}

macro split_from_right string*, separator = 0, parts_count = 0 {
  enter string, separator, parts_count

  call f_split_from_right

  return
}

macro join_links list*, separator = 0 {
  enter list, separator

  call f_join_links

  return
}

macro join list*, separator = 0 {
  enter list, separator

  call f_join

  return
}

macro is_alpha string* {
  enter string

  call f_is_alpha

  return
}

macro is_digit string* {
  enter string

  call f_is_digit

  return
}

macro string_to_list string* {
  enter string

  call f_string_to_list

  return
}

macro string_pop_link string*, integer = 0 {
  enter string, integer

  call f_string_pop_link

  return
}

macro string_pop string*, integer = 0 {
  enter string, integer

  call f_string_pop

  return
}

macro string_mul string*, integer* {
  enter string, integer

  call f_string_mul

  return
}

macro string_include string*, value* {
  enter string, value

  call f_string_include

  return
}

macro string_index string*, value* {
  enter string, value

  call f_string_index

  return
}

macro to_string value* {
  enter value

  call f_to_string

  return
}

macro assign_link variable*, keys*, value*, context = [GLOBAL_CONTEXT] {
  enter variable, keys, value, context

  call f_assign_link

  return
}

macro assign variable*, keys*, value*, context = [GLOBAL_CONTEXT] {
  enter variable, keys, value, context

  call f_assign

  return
}

macro access_link variable*, keys*, context = [GLOBAL_CONTEXT] {
  enter variable, keys, context

  call f_access_link

  return
}

macro access variable*, keys*, context = [GLOBAL_CONTEXT] {
  enter variable, keys, context

  call f_access

  return
}

macro function name*, link*, arguments*, named_arguments*, accumulators = 0, is_internal = 0 {
  enter name, link, arguments, named_arguments, accumulators, is_internal

  call f_function

  return
}

macro function_copy function {
  enter function

  call f_function_copy

  return
}

macro function_call function*, arguments*, named_arguments* {
  enter function, arguments, named_arguments

  call f_function_call

  return
}

macro getcwd {
  enter

  call f_getcwd

  return
}

macro get_random start = 0, end = 0 {
  enter start, end

  call f_get_random

  return
}

macro get_pseudorandom start = 0, end = 0 {
  enter start, end

  call f_get_pseudorandom

  return
}

macro set_seed seed* {
  enter seed

  call f_set_seed

  leave
}

macro reset_seed {
  enter

  call f_reset_seed

  leave
}

macro input string = 0 {
  enter string

  call f_input

  return
}

macro factorial integer* {
  enter integer

  call f_factorial

  return
}

macro euler_power_taylor exponent* {
  enter exponent

  call f_euler_power_taylor

  return
}

macro euler_power exponent* {
  enter exponent

  call f_euler_power

  return
}
