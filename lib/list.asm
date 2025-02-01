f_list:
  get_arg 0
  mov r8, rax

  collection r8
  mem_mov [rax], LIST

  ret

f_list_length:
  get_arg 0

  check_type rax, LIST
  collection_length rax

  ret

f_list_capacity:
  get_arg 0

  check_type rax, LIST
  collection_capacity rax

  ret

f_list_append_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  collection_append_link rbx, rcx
  mov rax, rbx

  ret

f_list_append:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST

  copy rcx
  list_append_link rbx, rax

  ret

f_list_get_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  collection_get_link rbx, rcx

  ret

f_list_get:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  collection_get rbx, rcx

  ret

f_list_copy_links:
  get_arg 0
  mov rbx, rax

  check_type rbx, LIST
  collection_copy_links rbx

  ret

f_list_copy:
  get_arg 0
  mov rbx, rax

  check_type rbx, LIST
  collection_copy rbx
  mem_mov [rax], LIST

  ret

f_list_set_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, LIST
  collection_set_link rbx, rcx, rdx

  ret

f_list_set:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, LIST
  copy rdx
  list_set_link rbx, rcx, rax

  ret

f_list_pop_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  collection_pop_link rbx, rcx

  ret

f_list_pop:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  list_pop_link rbx, rcx
  mov rbx, rax

  copy rax
  delete rbx

  ret

f_list_insert_link:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, LIST
  collection_insert_link rbx, rcx, rdx

  ret

f_list_insert:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  check_type rbx, LIST
  copy rcx
  mov rcx, rax
  copy rdx
  list_insert_link rbx, rcx, rax

  ret

f_list_index:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  collection_index rbx, rcx

  ret

f_list_include:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, LIST
  list_index rbx, rcx

  mov rax, [rax + INTEGER_HEADER*8]

  cmp rax, -1
  je .return_false
    boolean 1
    ret

  .return_false:
    boolean 0
    ret
