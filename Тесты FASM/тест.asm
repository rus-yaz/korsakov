format ELF64 executable
segment readable executable
entry main
main:
  mov r15, rsp
  ; NumberNode
  push 1
  ; NumberNode
  push 5
  ; BinaryOperationNode
  pop rbx
  pop rax
  add rax, rbx
  push rax
  ; VariableAssignNode
  ; NumberNode
  push 1
  ; VariableAccessNode
  mov rax, [r15 - 8]
  push rax
  ; BinaryOperationNode
  pop rbx
  pop rax
  add rax, rbx
  push rax
  ; NumberNode
  push 5
  ; BinaryOperationNode
  pop rbx
  pop rax
  add rax, rbx
  push rax
  ; VariableAssignNode
  mov rax, 60
  pop rdi
  syscall