include "lib/korsakov.asm"

section 'data' writable


section 'start' executable
start:
integer 1
mov rbx, rax
integer 2
addition rbx, rax
mov rdx, rax
list 0
push rbx
mov rbx, rax
mov rax, rbx
pop rbx
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx

exit 0
