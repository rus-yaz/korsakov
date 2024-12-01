; Тест работы со строками

; Взятие символа по индексу
integer -2
mov rax, rsp
mov [индекс], rax

get_string [содержимое_файла], [индекс]
mov [символ], rax

print <CHAR_BY_INDEX, [символ]>
