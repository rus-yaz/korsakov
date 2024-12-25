dictionary 0
dictionary_length rax

integer rax
print rax

list 0
mov rbx, rax
integer 0
list_append rbx, rax
integer 1
list_append rbx, rax
integer 2
list_append rbx, rax

list 0
mov rcx, rax
integer 3
list_append rcx, rax
integer 4
list_append rcx, rax
integer 5
list_append rcx, rax

dictionary rbx, rcx
mov rbx, rax

integer 0
dictionary_get rbx, rax
print rax
