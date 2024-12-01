; Тест отображения

; Проверка строк (строки, помещённые в кучу)
print <[содержимое_файла]>

; Проверка буфера (строки, захардкоженные в FASM)
print <STRING_CONTENT>

; Проверка чисел
integer 1024
mov rax, rsp
print <rax>

; Проверка множественного отображения
integer 1024
mov rax, rsp
print <rax, STRING_CONTENT, [содержимое_файла]>

; Проверка замены разделителя и конца стрки

integer 1024
mov rax, rsp
mov rbx, rax
mov rcx, rax

print <rax, rbx, rcx>, 63

print <rax, rbx, rcx>, 38, 95
