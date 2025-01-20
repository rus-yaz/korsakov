f_run:
  get_arg 3
  mov rdx, rax
  get_arg 2
  mov rcx, rax
  get_arg 1
  mov rbx, rax
  get_arg 0

  push rdx
  push rax
  push rcx
  sys_fork
  pop rcx
  pop r15

  cmp rax, 0
  jne .main_process
    sys_execve r15, rbx, rcx
    exit -1, EXECVE_WAS_NOT_EXECUTED

  .main_process:

  pop rdx
  cmp rdx, 0
  je .dont_wait
    sys_wait4 rax

  .dont_wait:

  ret
