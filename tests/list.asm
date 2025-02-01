string "Работа со списками"
print rax

; Создание значений с типом Целое чисо на стеке

list
mov rbx, rax
list
list_append rbx, rax
print rax

list
mov rbx, rax

integer 1
list_append rbx, rax
integer 2
list_append_link rbx, rax
integer 3
list_append rbx, rax
integer 4
list_append_link rbx, rax
print rax

integer 1
list_get_link rbx, rax
print rax

integer -1
list_get rbx, rax
print rax

integer 1
mov rcx, rax
integer 11
list_set_link rbx, rcx, rax
print rax

integer 3
mov rcx, rax
integer 17
list_set rbx, rcx, rax
print rax

list_copy rbx
print rax

list_copy_links rbx
print rax

integer 1
list_index rbx, rax
print rax

integer 1
list_include rbx, rax
print rax

integer 21
list_include rbx, rax
print rax

list_pop_link rbx
print <rbx, rax>

integer 0
list_pop rbx, rax
print <rbx, rax>

integer 0
mov rcx, rax
integer 9
list_insert_link rbx, rcx, rax
print rax

integer 0
mov rcx, rax
integer 0
list_insert rbx, rcx, rax
print rax
