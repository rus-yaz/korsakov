section "debug" executable

define DEBUG

macro debug_start function_name* {
  if DEBUG eqtype
  enter

  list_length [time]
  integer rax
  mov rbx, rax
  string " "
  multiplication rbx, rax
  mov rbx, rax
  string ""
  print rbx, "", rax

  string "начало"
  mov rcx, rax
  string function_name
  mov rdx, rax

  push rcx
  create_block 2*8
  mov rcx, rax
  push rcx, rdx
  syscall 228, 0, rcx
  pop rdx, r8, rcx

  list
  mov rbx, rax
  integer [r8 + 8*0]
  list_append rbx, rax
  integer [r8 + 8*1]
  list_append rbx, rax

  list_append [time], rbx

  print <rcx, rdx>

  leave
  end if
}

macro debug_end function_name* {
  if DEBUG eqtype
  enter

  list_length [time]
  dec rax
  integer rax
  mov rbx, rax
  string " "
  multiplication rbx, rax
  mov rbx, rax
  string ""
  print rbx, "", rax

  string "конец "
  mov rcx, rax
  string function_name
  mov rdx, rax

  list_pop [time]
  mov rbx, rax

  push rcx
  create_block 2*8
  mov rcx, rax
  push rcx, rdx
  syscall 228, 0, rcx
  pop rdx, rcx

  integer 0
  list_get rbx, rax
  mov rax, [rax + INTEGER_HEADER*8]
  mov r8, [rcx + 8*0]
  sub r8, rax
  integer r8
  mov r8, rax

  integer 1
  list_get rbx, rax
  mov rax, [rax + INTEGER_HEADER*8]
  mov r9, [rcx + 8*1]
  sub r9, rax
  integer r9
  mov r9, rax
  pop rcx

  print <rcx, rdx, r8, r9>

  leave
  end if
}
