string "Тест отображения"
print rax

string "Привет, мир!"
mov r8, rax

; Проверка строк (строки, помещённые в кучу)
print r8

; Проверка чисел
integer 1024
print <rax>

list
print rax

list
mov rbx, rax

integer 0
list_append rbx, rax
integer 1
list_append rbx, rax
integer 2
list_append rbx, rax

print rax

list
mov rbx, rax

integer 0
list_append rbx, rax
list_append rbx, r8

list
mov rcx, rax

integer 99
list_append rcx, rax

list
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

; Проверка множественного отображения
integer 1024
print <rax, STRING_CONTENT_TEXT, r8>

; Проверка замены разделителя и конца стрки

integer 1024
mov rbx, rax
mov rcx, rax

print <rax, rbx, rcx>, "?"

print <rax, rbx, rcx>, "_", "*"
