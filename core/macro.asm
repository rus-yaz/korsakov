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
    push rbp
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
  local .incorrect, .correct
  mov rax, index

  cmp rax, 0
  jl .incorrect

  cmp rax, [rbp]
  jge .incorrect

  jmp .correct

  .incorrect:
    exit 100
  .correct:

  mov rax, [rbp + (1 + index) * 8]
}

macro return {
  pop rbp
  imul rbp, 8
  add rsp, rbp
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
    local .string, .end

    jmp .end
      .string db str, 0
    .end:

    mov rax, .string
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
  common
    local .float, .end

    jmp .end
      .float dq value
    .end:

    mov rax, .float
}

macro float value {
  raw_float value
  buffer_to_float rax
}

macro check_error operation*, message* {
  local .incorrect, .correct

  push rax

  raw_string message, 10
  operation .incorrect
  jmp .correct

  .incorrect:
    error_raw rax
    exit -1
  .correct:

  pop rax
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

macro _function name, [regs] {
  common

  local .start
  match =1, LINUX \{
    public f_#name
  \}

  f_#name:
    if regs eq
    else
      forward
        push regs
      common
    end if

    call .start

    if regs eq
    else
      reverse
        pop regs
      common
    end if

    ret

    .start:
}

include "generated_macros.asm"
