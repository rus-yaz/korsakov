string "Тест удаления различных типов данных"
print rax

integer 0

delete rax

string "Привет"

delete rax

list
mov rbx, rax
integer 0
list_append rbx, rax
integer 1
list_append rbx, rax

delete rax

list
mov rbx, rax

string "Привет"
list_append rbx, rax

delete rax

list
mov rbx, rax
integer 0
list_append rbx, rax
integer 1
list_append rbx, rax

list
mov rcx, rax
integer 2
list_append rcx, rax
integer 3
list_append rcx, rax

list_append rbx, rcx

delete rax

list
mov rbx, rax

integer 0
list_append rbx, rax
integer 2
list_append rbx, rax

list
mov rcx, rax

integer 1
list_append rcx, rax
integer 3
list_append rcx, rax

dictionary rbx, rcx

delete rax
