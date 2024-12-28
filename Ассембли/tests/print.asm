; Тест отображения

buffer_to_string print.буфер
mov [print.строка], rax

; Проверка строк (строки, помещённые в кучу)
print <[print.строка]>

; Проверка буфера (строки, захардкоженные в FASM)
print <STRING_CONTENT_TEXT>

; Проверка чисел
integer 1024
print <rax>

list 0
mov rbx, rax

integer 0
list_append rbx, rax
integer 1
list_append rbx, rax
integer 2
list_append rbx, rax

print rax

list 0
mov rbx, rax

integer 0
list_append rbx, rax
list_append rbx, [print.строка]

list 0
mov rcx, rax

integer 99
list_append rcx, rax

list 0
mov rdx, rax

integer 0
list_append rdx, rax
integer 1
list_append rdx, rax
integer 2
list_append rdx, rax

list_append rcx, rdx

dictionary rbx, rcx
print rax

;; Проверка множественного отображения
;integer 1024
;print <rax, STRING_CONTENT_TEXT, [print.строка]>
;
;; Проверка замены разделителя и конца стрки
;
;integer 1024
;mov rbx, rax
;mov rcx, rax
;
;print <rax, rbx, rcx>, "?"
;
;print <rax, rbx, rcx>, "_", "*"
