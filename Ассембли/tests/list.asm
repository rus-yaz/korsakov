; Тест работы со списками

; Создание значений с типом Целое чисо на стеке
integer 4
push rax
integer 3
push rax
integer 2
push rax
integer 1
push rax

mov rax, rsp
list rax, 4       ; Количество элементов
mov [list.список], rax

; индекс = -1
integer -1
mov [list.индекс], rax

; показать(список.индекс)
list_get [list.список], [list.индекс]
print <ITEM_BY_INDEX_TEXT, rax>

; список.добавить(5)
integer 5
list_append [list.список], rax

; показать(список.индекс)
list_get [list.список], [list.индекс]
print <ITEM_BY_INDEX_TEXT, rax>
