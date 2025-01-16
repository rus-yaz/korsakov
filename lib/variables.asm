f_assign:
  ; RBX — keys
  ; RCX — value
  ; RDX — context
  ; R8  — variable

  mov r8, rax

  dictionary_set rdx, r8, rcx
  mov rax, rcx

  ret

f_access:
  ; RBX — keys
  ; RCX — context
  ; RDX — variable

  mov rdx, rax

  dictionary_get rcx, rdx

  ret
