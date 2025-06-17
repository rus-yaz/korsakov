; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

raw_string "Логическая операция «не»", 10
print_raw rax

arguments "значение"
mov rdx, rax

dictionary
mov rcx, rax

string "к_булеву_значению"
mov rbx, rax
function rbx, f_boolean_not, rdx, rcx, 0, 1
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
list_append_link r15, rax

list
mov r14, rax
integer 1
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
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
list_append_link r15, rax

list
mov r14, rax
float 0.5
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float -0.5
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float -1.0
list_append_link r14, rax
list_append_link r15, rax

; ======================
; =  Булевы значения   =
; ======================

list
mov r14, rax
boolean 0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
boolean 1
list_append_link r14, rax
list_append_link r15, rax

; ======================
; =       Списки       =
; ======================

list
mov r14, rax
list
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
list
mov rbx, rax
null
list_append_link rbx,rax
list_append_link r14, rax
list_append_link r15, rax

; ======================
; =       Строки       =
; ======================

list
mov r14, rax
string ""
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
string "Тест"
list_append_link r14, rax
list_append_link r15, rax

; ======================
; =      Словари       =
; ======================

list
mov r14, rax
dictionary
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
dictionary
mov rdx, rax
integer 0
mov rbx, rax
integer 0
dictionary_set_link rdx, rbx, rax
list_append_link r14, rax
list_append_link r15, rax

test rcx, r15
