; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

section "debug" executable

macro debug_start function_name* {
  if DEBUG eqtype
  enter

  list_length [DEBUG_TIME]
  integer rax
  mov rbx, rax
  string " "
  multiplication rbx, rax
  mov rbx, rax
  list
  list_append_link rax, rbx
  mov rbx, rax
  string ""
  print rbx, rax, rax

  delete rbx, rax

  string "начало"
  mov rcx, rax

  push rcx
  create_block 2*8
  mov rcx, rax
  push rcx
  syscall 228, 0, rcx
  pop r8, rcx

  list
  mov rbx, rax
  integer [r8 + 8*0]
  list_append_link rbx, rax
  integer [r8 + 8*1]
  list_append_link rbx, rax

  list_append_link [DEBUG_TIME], rbx

  list
  list_append_link rax, rcx
  mov rbx, rax
  string " "
  print rbx, rax, rax
  delete rbx, rax

  raw_string function_name
  print_raw rax

  list
  print rax

  leave
  end if
}

macro debug_end function_name* {
  if DEBUG eqtype
  enter

  list_length [DEBUG_TIME]
  dec rax
  integer rax
  mov rbx, rax
  string " "
  multiplication rbx, rax
  mov rbx, rax
  list
  list_append_link rax, rbx
  mov rbx, rax
  string ""
  print rbx, rax, rax
  delete rbx, rax

  string "конец "
  mov rcx, rax
  string function_name
  mov rdx, rax

  list_pop_link [DEBUG_TIME]
  mov rbx, rax

  push rcx
  create_block 2*8
  mov rcx, rax
  push rcx, rdx
  syscall 228, 0, rcx
  pop rdx, rcx

  integer 0
  list_get_link rbx, rax
  mov rax, [rax + INTEGER_HEADER*8]
  mov r8, [rcx + 8*0]
  sub r8, rax
  integer r8
  mov r8, rax

  integer 1
  list_get_link rbx, rax
  mov rax, [rax + INTEGER_HEADER*8]
  mov r9, [rcx + 8*1]
  sub r9, rax
  integer r9
  mov r9, rax
  pop rcx

  list
  list_append_link rax, rcx
  list_append_link rax, rdx
  list_append_link rax, r8
  list_append_link rax, r9
  print rax
  delete rax

  leave
  end if
}
