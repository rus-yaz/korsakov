; Тест работы со списками

; Создание значений с типом Целое чисо на стеке
integer 4
integer 3
integer 2
integer 1

mov rax, rsp      ; Указатель на начало списка
list rax, 4       ; Количество элементов
mov [list.список], rax

; индекс = -1
integer -1
mov rax, rsp
mov [list.индекс], rax

; список.индекс
list_get [list.список], [list.индекс]

; показать(список.индекс)
print <ITEM_BY_INDEX_TEXT, rax>
