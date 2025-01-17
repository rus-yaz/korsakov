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
print <ITEM_BY_INDEX_TEXT, rax>

; список.добавить(5)
integer 5
list_append rbx, rax

; показать(список.индекс)
list_get rbx, rcx
print <ITEM_BY_INDEX_TEXT, rax>

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
