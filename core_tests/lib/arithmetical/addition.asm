; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

raw_string "Сложение", 10
print_raw rax

arguments "операнд_1", "операнд_2"
mov rdx, rax

dictionary
mov rcx, rax

string "сложение"
mov rbx, rax
function rbx, f_addition, rdx, rcx, 0, 1
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

list
mov r14, rax
integer 12
list_append_link r14, rax
integer 34
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 123
list_append_link r14, rax
integer 456
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 1234
list_append_link r14, rax
integer 5678
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 12345
list_append_link r14, rax
integer 67890
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
float 0.0
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
float 0.0
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
float 1.0
list_append_link r14, rax
float -1.0
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
float -1.0
list_append_link r14, rax
float 1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float -1.0
list_append_link r14, rax
float -1.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 12.25
list_append_link r14, rax
float 12.25
list_append_link r14, rax
list_append_link r15, rax

; ======================
; =       Списки       =
; ======================

list
mov r14, rax
list
list_append_link r14, rax
list
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
list
list_append_link r14, rax
list
mov rbx, rax
integer 2
list_append_link rbx, rax
integer 3
list_append_link rbx, rax
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
list
mov rbx, rax
integer 2
list_append_link rbx, rax
integer 3
list_append_link rbx, rax
list_append_link r14, rax
list
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
list
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 1
list_append_link rbx, rax
list_append_link r14, rax
list
mov rbx, rax
integer 2
list_append_link rbx, rax
integer 3
list_append_link rbx, rax
list_append_link r14, rax
list_append_link r15, rax

integer 0
mov rbx, rax
list
mov r14, rax
list
list_append_link rax, rbx
list_append_link r14, rax
list
list_append_link rax, rbx
list_append_link r14, rax
list_append_link r15, rax

; ======================
; =       Строки       =
; ======================

list
mov r14, rax
string ""
list_append_link r14, rax
string ""
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
string ""
list_append_link r14, rax
string "123"
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
string "123"
list_append_link r14, rax
string ""
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
string "Корс"
list_append_link r14, rax
string "áков"
list_append_link r14, rax
list_append_link r15, rax

; ======================
; =      Словари       =
; ======================

list
mov r14, rax
dictionary
list_append_link r14, rax
dictionary
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
dictionary
mov rbx, rax
string "1"
mov rdx, rax
string "2"
dictionary_set_link rbx, rdx, rax
list_append_link r14, rax
dictionary
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
dictionary
list_append_link r14, rax
dictionary
mov rbx, rax
string "3"
mov rdx, rax
string "4"
dictionary_set_link rbx, rdx, rax
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
dictionary
mov rbx, rax
string "1"
mov rdx, rax
string "2"
dictionary_set_link rbx, rdx, rax
list_append_link r14, rax
dictionary
mov rbx, rax
string "3"
mov rdx, rax
string "4"
dictionary_set_link rbx, rdx, rax
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
dictionary
mov rbx, rax
string "1"
mov rdx, rax
string "2"
dictionary_set_link rbx, rdx, rax
list_append_link r14, rax
dictionary
mov rbx, rax
string "1"
mov rdx, rax
string "3"
dictionary_set_link rbx, rdx, rax
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
integer 5
list_append_link r14, rax
float 0.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 0.0
list_append_link r14, rax
integer 5
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 0
list_append_link r14, rax
float 5.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 5.0
list_append_link r14, rax
integer 0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
integer 5
list_append_link r14, rax
float 5.0
list_append_link r14, rax
list_append_link r15, rax

list
mov r14, rax
float 5.0
list_append_link r14, rax
integer 5
list_append_link r14, rax
list_append_link r15, rax

test rcx, r15
