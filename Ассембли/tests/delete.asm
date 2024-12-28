integer 0

delete rax

buffer_to_string delete.буфер

delete rax

list 0
mov rbx, rax
integer 0
list_append rbx, rax
integer 1
list_append rbx, rax

delete rax

list 0
mov rbx, rax

buffer_to_string delete.буфер
list_append rbx, rax

delete rax

list 0
mov rbx, rax
integer 0
list_append rbx, rax
integer 1
list_append rbx, rax

list 0
mov rcx, rax
integer 2
list_append rcx, rax
integer 3
list_append rcx, rax

list_append rbx, rcx

delete rax

list 0
mov rbx, rax

integer 0
list_append rbx, rax
integer 2
list_append rbx, rax

list 0
mov rcx, rax

integer 1
list_append rcx, rax
integer 3
list_append rcx, rax

dictionary rbx, rcx

delete rax
