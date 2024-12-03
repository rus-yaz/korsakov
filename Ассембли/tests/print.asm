; Тест отображения

buffer_to_string print.буфер
mov [print.строка], rax

; Проверка строк (строки, помещённые в кучу)
print <[print.строка]>

; Проверка буфера (строки, захардкоженные в FASM)
print <STRING_CONTENT_TEXT>

; Проверка чисел
integer 1024
mov rax, rsp
print <rax>

; Проверка множественного отображения
;integer 1024
;mov rax, rsp
;print <rax, STRING_CONTENT_TEXT, [print.строка]>

; Проверка замены разделителя и конца стрки

integer 1024
mov rax, rsp
mov rbx, rax
mov rcx, rax

print <rax, rbx, rcx>, 63

print <rax, rbx, rcx>, 38, 95
