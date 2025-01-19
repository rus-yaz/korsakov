section "macro" executable

macro push [arg*] {
  push arg
}

macro pop [arg*] {
  pop arg
}

macro enter arg_1 = 0, arg_2 = 0, arg_3 = 0, arg_4 = 0, arg_5 = 0, arg_6 = 0, arg_7 = 0, arg_8 = 0, arg_9 = 0, arg_10 = 0, arg_11 = 0, arg_12 = 0 {
  push rax, rbx, rcx, rdx, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15

  macro pushq [arg*] \{
    mov [rsp - 8*2], rax
    mov rax, arg
    mov [rsp - 8*1], rax
    mov rax, [rsp - 8*2]
    sub rsp, 8
  \}

  pushq arg_12, arg_11, arg_10, arg_9, arg_8, arg_7, arg_6, arg_5, arg_4, arg_3, arg_2, arg_1
  pop   rax,    rbx,    rcx,    rdx,   r8,    r9,    r10,   r11,   r12,   r13,   r14,   r15
}

macro leave {
  pop r15, r14, r13, r12, r11, r10, r9, r8, rdi, rsi, rdx, rcx, rbx, rax
}

macro return {
  push rax
  add rsp, 8

  leave

  mov rax, [rsp - 8*15]
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

macro print_buffer [buffer*] {
  enter buffer

  call f_print_buffer

  leave
}

macro check_type variable_ptr*, type* {
  enter variable_ptr, type

  call f_check_type

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


section "dictionary" executable

macro dictionary keys = 0, values = 0 {
  enter keys, values

  call f_dictionary

  return
}

macro dictionary_length dictionary* {
  enter dictionary

  call f_dictionary_length

  return
}

macro dictionary_keys dictionary* {
  enter dictionary

  call f_dictionary_keys

  return
}

macro dictionary_values dictionary* {
  enter dictionary

  call f_dictionary_values

  return
}

macro dictionary_get dictionary*, key*, default_value = 0 {
  enter dictionary, key, default_value

  call f_dictionary_get

  return
}

macro dictionary_items dictionary* {
  enter dictionary

  call f_dictionary_items

  return
}

macro dictionary_copy dictionary* {
  enter dictionary

  call f_dictionary_copy

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

section "heap" executable

macro allocate_heap {
  enter

  call f_allocate_heap

  leave
}

macro delete_block block* {
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

section "list" executable

macro list {
  enter

  call f_list

  return
}

macro list_length list* {
  enter list

  call f_list_length

  return
}

macro list_get list*, index* {
  enter list, index

  call f_list_get

  return
}

macro join list*, separator = " " {
  enter list, separator

  call f_join

  return
}

macro list_copy list* {
  enter list

  call f_list_copy

  return
}

macro list_append list*, item* {
  enter list, item

  call f_list_append

  return
}

macro string_to_list string* {
  enter string

  call f_string_to_list

  return
}

macro list_to_string list {
  enter list

  call f_list_to_string

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

macro list_set list*, index*, item* {
  enter list, index, item

  call f_list_set

  return
}

macro list_pop list*, index = 0 {
  enter list, index

  call f_list_pop

  return
}

macro list_insert list*, index*, item* {
  enter list, index, item

  call f_list_insert

  return
}

section "print" executable

macro print_string string* {
  enter string

  call f_print_string

  leave
}

; TODO: Реализовать через `join`

macro print arguments*, separator = " ", end_of_string = 10 {
  push rax

  macro print_argument [argument*] \{
    enter argument

    call f_print

    push separator
    mov rax, rsp
    sys_print rax, 8
    pop rax

    leave
  \}

  print_argument arguments

  push 0, end_of_string
  mov rax, rsp

  sys_print rax, 8*2
  pop rax, rax

  pop rax
}

section "string" executable

macro string str {
  a = $
  jmp @f
    db str, 0
  @@:
  buffer_to_string a + 2
  ; `+ 2` — что-то из разряда магии
  ; Потому что без него захватываются лишние 2 бита
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

macro string_length string* {
  enter string

  call f_string_length

  return
}

macro string_copy string* {
  enter string

  call f_string_copy

  return
}

macro string_append string_1*, string_2* {
  enter string_1, string_2

  call f_string_append

  return
}

macro string_add string_1*, string_2* {
  enter string_1, string_2

  call f_string_add

  return
}

macro string_get string*, index* {
  enter string, index

  call f_string_get

  return
}

macro split string*, separator = " " {
  enter string, separator

  call f_split

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

macro string_set string*, index*, value* {
  enter string, index, value

  call f_string_set

  return
}

section "to_string" executable

macro to_string value* {
  enter value

  call f_to_string

  return
}

macro type_to_string type* {
  enter type

  call f_type_to_string

  return
}

section "delete" executable

macro delete variable* {
  enter variable

  call f_delete

  leave
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

section "null" executable

macro null {
  enter

  call f_null

  return
}
