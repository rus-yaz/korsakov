; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Подготовленные функции"
print rax

integer 1
mov rbx, rax

integer 2
mov rcx, rax

is_equal rbx, rbx
integer rax
print rax

is_equal rbx, rcx
integer rax
print rax

string "Проверка 123"
mov rbx, rax

string "321 акреворП"
mov rcx, rax

is_equal rbx, rbx
integer rax
print rax

is_equal rbx, rcx
integer rax
print rax

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

list
mov rcx, rax
integer 4
list_append rcx, rax
integer 3
list_append rcx, rax
integer 2
list_append rcx, rax
integer 1
list_append rcx, rax

is_equal rbx, rbx
integer rax
print rax

is_equal rbx, rcx
integer rax
print rax
