; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

raw_string "Сравнение «больше или равно»", 10
print_raw rax

arguments "операнд_1", "операнд_2"
mov rdx, rax

dictionary
mov rcx, rax

string "и"
mov rbx, rax
function rbx, f_is_greater_or_equal, rdx, rcx, 0, 1
mov rcx, rax
list
assign rbx, rax, rcx
mov rcx, rax

list
mov r15, rax

; ======================
; =    Целые числа     =
; ======================

list
mov r14, rax
integer 0
list_append_link r14, rax
integer 0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 1
list_append_link r14, rax
integer 0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer -1
list_append_link r14, rax
integer 0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 0
list_append_link r14, rax
integer 1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 1
list_append_link r14, rax
integer 1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer -1
list_append_link r14, rax
integer 1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 0
list_append_link r14, rax
integer -1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 1
list_append_link r14, rax
integer -1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer -1
list_append_link r14, rax
integer -1
list_append_link r14, rax
list_append_link r15, rax

; ======================
; = Вещественные числа =
; ======================

list
mov r14, rax
float 0.0
list_append_link r14, rax
float 0.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 1.0
list_append_link r14, rax
float 0.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float -1.0
list_append_link r14, rax
float 0.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 0.0
list_append_link r14, rax
float 1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 1.0
list_append_link r14, rax
float 1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float -1.0
list_append_link r14, rax
float 1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 0.0
list_append_link r14, rax
float -1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 1.0
list_append_link r14, rax
float -1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float -1.0
list_append_link r14, rax
float -1.0
list_append_link r14, rax
list_append_link r15, rax

; ======================
; =    Разные типы     =
; ======================

; ------------------------------------
; - Целые числа и Вещественные числа -
; ------------------------------------

list
mov r14, rax
integer 0
list_append_link r14, rax
float 0.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 0.0
list_append_link r14, rax
integer 0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 1
list_append_link r14, rax
float 0.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 0.0
list_append_link r14, rax
integer 1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer -1
list_append_link r14, rax
float 0.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 0.0
list_append_link r14, rax
integer -1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 0
list_append_link r14, rax
float 1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 1.0
list_append_link r14, rax
integer 0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 1
list_append_link r14, rax
float 1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 1.0
list_append_link r14, rax
integer 1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer -1
list_append_link r14, rax
float 1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 1.0
list_append_link r14, rax
integer -1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 0
list_append_link r14, rax
float -1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float -1.0
list_append_link r14, rax
integer 0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 1
list_append_link r14, rax
float -1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float -1.0
list_append_link r14, rax
integer 1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer -1
list_append_link r14, rax
float -1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float -1.0
list_append_link r14, rax
integer -1
list_append_link r14, rax
list_append_link r15, rax

test rcx, r15
