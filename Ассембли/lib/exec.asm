section "run" executable

macro run command, args, env, wait = 1 {
  enter command, args, env, wait

  call f_run

  leave
}

f_run:
  push rdx
  push rax
  push rcx
  sys_fork
  pop rcx
  pop r15

  cmp rax, 0
  jne .main_process
    sys_execve r15, rbx, rcx
    exit EXECVE_WAS_NOT_EXECUTED

  .main_process:

  pop rdx
  cmp rdx, 0
  je .dont_wait
    sys_wait4 rax

  .dont_wait:

  ret
