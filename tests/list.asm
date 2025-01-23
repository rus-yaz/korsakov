string "Работа со списками"
print rax

; Создание значений с типом Целое чисо на стеке

list
mov rbx, rax
integer 1
list_append rbx, rax
integer 2
list_append rbx, rax
integer 3
list_append rbx, rax
integer 4
list_append rbx, rax

; индекс = -1
integer -1
mov rcx, rax

; показать(список.индекс)
list_get rbx, rcx
mov rcx, rax
string "Элемент по индексу:"
print <rax, rcx>

; список.добавить(5)
integer 5
list_append rbx, rax

; показать(список.индекс)
list_get rbx, rcx
mov rbx, rax
string "Элемент по индексу:"
print <rax, rbx>

list
mov rbx, rax

mov rcx, rsp
push 0
mov rax, rsp
buffer_to_string rax
mov rdx, rax
mov rsp, rcx
list_append rbx, rax

list
mov rbx, rax
integer 1
list_append rbx, rax
list_append rax, rax

print rax

integer 0
list_set rbx, rax, rax
integer 1
list_set rbx, rax, rax

print rax

integer 0
list_index rbx, rax
print rax

list
mov rbx, rax
integer 2
list_append rbx, rax
integer 3
list_append rbx, rax
integer 4
list_append rbx, rax
integer 5
list_append rbx, rax
integer 6
list_append rbx, rax
integer 7
list_append rbx, rax

list_pop rbx
print <rax, rbx>

integer -1
list_pop rbx, rax
print <rax, rbx>

integer 0
list_pop rbx, rax
print <rax, rbx>

integer 1
list_pop rbx, rax
print <rax, rbx>

list
mov rcx, rax
integer 1
list_append rcx, rax
integer 2
list_append rcx, rax
integer 3
list_append rcx, rax

print rcx

integer 0
mov rbx, rax
integer 0
list_insert rcx, rbx, rax
print rcx

integer -1
mov rbx, rax
integer 4
list_insert rcx, rbx, rax
print rcx

integer 4
mov rbx, rax
integer 10
list_insert rcx, rbx, rax
print rcx
