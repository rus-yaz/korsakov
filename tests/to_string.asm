; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Перевод в строку"
print rax

integer 0
to_string rax
print rax

integer 1
to_string rax
print rax

integer -1
to_string rax
print rax

string "123"
to_string rax
print rax

list
to_string rax
print rax

dictionary
to_string rax
print rax

list
mov rbx, rax
integer 0
list_append rbx, rax
integer 1
list_append rbx, rax
integer -1
list_append rbx, rax
string "123"
list_append rbx, rax
list
list_append rbx, rax
dictionary
list_append rbx, rax
to_string rbx
print rax
