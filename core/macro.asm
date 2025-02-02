section "macro" executable

macro push [arg] {
  push arg
}

macro pop [arg] {
  pop arg
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

    exit -1
  @@:

  mov rax, [rbp]
  cmp rax, index
  jg @f

    exit -1
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

macro exit code*, buffer = 0 {
  if buffer eq 0
  else
    push rax

    print_buffer buffer

    push 10
    mov rax, rsp
    sys_print rax, 8
    pop rax

    pop rax
  end if

  sys_exit code
}

macro string str {
  jmp @f
    a = $
    db str, 0
  @@:
  buffer_to_string a
}

section "utils" executable

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

macro print_buffer buffer* {
  enter buffer

  call f_print_buffer

  leave
}

macro mem_copy source*, destination*, size* {
  enter source, destination, size

  call f_mem_copy

  leave
}

macro check_error operation*, message* {
  push rax

  mov rax, message
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

section "arithmetical" executable

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

section "boolean" executable

macro boolean value {
  enter value

  call f_boolean

  return
}

macro boolean_value boolean {
  enter boolean

  call f_boolean_value

  return
}

macro boolean_copy boolean {
  enter boolean

  call f_boolean_copy

  return
}

section "delete" executable

macro delete [variable*] {
  enter variable

  call f_delete

  leave
}

section "dictionary" executable

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

macro dictionary_from_items keys = 0, values = 0 {
  enter keys, values

  call f_dictionary_from_items

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

section "exec" executable

macro run command*, args*, env*, wait = 1 {
  enter command, args, env, wait

  call f_run

  leave
}

section "file" executable

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

section "functions" executable

macro is_equal val_1*, val_2* {
  enter val_1, val_2

  call f_is_equal

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

section "heap" executable

macro allocate_heap {
  enter

  call f_allocate_heap

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

section "integer" executable

macro integer value* {
  enter value

  call f_integer

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

section "collection" executable

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

macro is_collection value* {
  enter value

  call f_is_collection

  return
}

section "list" executable

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

section "null" executable

macro null {
  enter

  call f_null

  return
}

section "print" executable

macro print arguments*, separator = 0, end_of_string = 0 {
  enter arguments, 0, separator, end_of_string

  call f_print

  leave
}

section "string" executable

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

macro split string*, separator = " " {
  enter string, separator

  call f_split

  return
}

macro join_links list*, separator = " " {
  enter list, separator

  call f_join_links

  return
}

macro join list*, separator = " " {
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

section "to_string" executable

macro to_string value* {
  enter value

  call f_to_string

  return
}

section "variables" executable

macro assign variable*, keys*, value*, context = [GLOBAL_CONTEXT] {
  enter variable, keys, value, context

  call f_assign

  return
}

macro access variable*, keys*, context = [GLOBAL_CONTEXT] {
  enter variable, keys, context

  call f_access

  return
}
