include '/var/home/x1z53/git/korsakov/core/korsakov.asm'
include '/var/home/x1z53/git/korsakov/modules/.asm'
start:
init_
push rdx, rcx, rbx
integer 10
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx
mov rbx, 0
.loop_start_1:
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
boolean rax
boolean_value rax
cmp rax, 1
jne .loop_end_1
mov rbx, 1
push rdx, rcx, rbx
push rbx
integer 1
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
subtraction rax, rbx
pop rbx
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
jmp .loop_start_1
.loop_end_1:
je .loop_else_skip_1
.loop_else_skip_1:
pop rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx, rdx
integer 5
mov rbx, rax
integer 1
mov rcx, rax
integer 0
.loop_start_2:
mov rdx, rax
is_greater_or_equal rdx, rbx
boolean_value rax
cmp rax, 1
je .loop_end_2
mov rax, rdx
push rdx, rcx, rbx
mov rdx, rax
list
mov rcx, rax
string "б"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
push rdx, rcx, rbx
push rbx
push rcx, rbx
list
mov rcx, rax
string "б"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
addition rax, rbx
pop rbx
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
.loop_iteration_2:
integer_add rdx, rcx
jmp .loop_start_2
.loop_end_2:
pop rdx, rcx, rbx


push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx, rdx
integer 5
mov rbx, rax
integer 2
mov rcx, rax
integer 0
.loop_start_3:
mov rdx, rax
is_greater_or_equal rdx, rbx
boolean_value rax
cmp rax, 1
je .loop_end_3
mov rax, rdx
push rdx, rcx, rbx
mov rdx, rax
list
mov rcx, rax
string "б"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
push rdx, rcx, rbx
push rbx
push rcx, rbx
list
mov rcx, rax
string "б"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
addition rax, rbx
pop rbx
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
.loop_iteration_3:
integer_add rdx, rcx
jmp .loop_start_3
.loop_end_3:
pop rdx, rcx, rbx


push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx, rdx
integer 10
mov rbx, rax
integer 1
mov rcx, rax
integer 0
.loop_start_4:
mov rdx, rax
is_greater_or_equal rdx, rbx
boolean_value rax
cmp rax, 1
je .loop_end_4
mov rax, rdx
push rdx, rcx, rbx
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
push rbx, rcx, rdx
integer 3
mov rbx, rax
integer 1
mov rcx, rax
integer 1
.loop_start_5:
mov rdx, rax
is_greater_or_equal rdx, rbx
boolean_value rax
cmp rax, 1
je .loop_end_5
mov rax, rdx
push rdx, rcx, rbx
mov rdx, rax
list
mov rcx, rax
string "б"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
.loop_iteration_5:
integer_add rdx, rcx
jmp .loop_start_5
.loop_end_5:
pop rdx, rcx, rbx

push rbx
integer 5
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
is_equal rax, rbx
pop rbx
boolean rax
boolean_value rax
cmp rax, 1
jne .if_1_branch_1
jmp .loop_end_4
jmp .if_1_end
.if_1_branch_1:
.if_1_end:
.loop_iteration_4:
integer_add rdx, rcx
jmp .loop_start_4
.loop_end_4:
pop rdx, rcx, rbx


push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
push rcx, rbx
list
mov rcx, rax
string "б"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rdx, rcx, rbx
integer 0
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rdx, rcx, rbx
integer 2
mov rdx, rax
list
mov rcx, rax
string "б"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
push rcx, rbx
list
mov rcx, rax
string "б"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx
integer 1
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
is_greater rax, rbx
pop rbx
boolean rax
boolean_value rax
cmp rax, 1
jne .if_2_branch_1
push rdx, rcx, rbx
integer 1
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
jmp .if_2_end
.if_2_branch_1:
push rbx
integer 0
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
is_equal rax, rbx
pop rbx
boolean rax
boolean_value rax
cmp rax, 1
jne .if_2_branch_2
push rdx, rcx, rbx
integer 1
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
jmp .if_2_end
.if_2_branch_2:
push rcx, rbx
list
mov rcx, rax
string "б"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
boolean rax
boolean_value rax
cmp rax, 1
jne .if_2_branch_3
push rdx, rcx, rbx
integer 0
mov rdx, rax
list
mov rcx, rax
string "б"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
jmp .if_2_end
.if_2_branch_3:
push rdx, rcx, rbx
integer 0
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
.if_2_end:

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
push rcx, rbx
list
mov rcx, rax
string "б"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rdx, rcx, rbx
list
push rbx
mov rbx, rax
list
push rbx
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 0
list_append_link rbx, rax
integer 0
list_append_link rbx, rax
mov rax, rbx
pop rbx
list_append_link rbx, rax
list
push rbx
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 0
list_append_link rbx, rax
integer 0
list_append_link rbx, rax
mov rax, rbx
pop rbx
list_append_link rbx, rax
list
push rbx
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 0
list_append_link rbx, rax
integer 0
list_append_link rbx, rax
mov rax, rbx
pop rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rdx, rcx, rbx
push rbx
string ""
mov rbx, rax
string 'Привет, мир!'
string_extend_links rbx, rax
mov rax, rbx
pop rbx
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rdx, rcx, rbx
push rbx
string ""
mov rbx, rax
string '!'
string_extend_links rbx, rax
mov rax, rbx
pop rbx
mov rdx, rax
list
push rbx
mov rbx, rax
integer 6
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rdx, rcx, rbx
push rbx
string ""
mov rbx, rax
string 'М'
string_extend_links rbx, rax
mov rax, rbx
pop rbx
mov rdx, rax
list
push rbx
mov rbx, rax
integer 8
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx
string ""
mov rbx, rax
string 'Привет,', 10, '', 9, 'мир!'
string_extend_links rbx, rax
mov rax, rbx
pop rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "разделить"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx
string ""
mov rbx, rax
string 'Привет, мир!'
string_extend_links rbx, rax
mov rax, rbx
pop rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "ошибка"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx
string ""
mov rbx, rax
string 'Текст ошибки'
string_extend_links rbx, rax
mov rax, rbx
pop rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rdx, rcx, rbx
integer 3
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rbx
mov rbx, 0
.loop_start_6:
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
push rbx, rcx
mov rcx, rax
integer_copy rax
mov rbx, rax
integer_dec rcx
push rdx, rcx, rbx
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
mov rax, rbx
pop rcx, rbx
boolean rax
boolean_value rax
cmp rax, 1
jne .loop_end_6
mov rbx, 1
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "установить_семя"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 123
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "получить_псевдослучайное_число"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 100
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "получить_псевдослучайное_число"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 100
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "получить_случайное_число"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 0
list_append_link rbx, rax
integer 100
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
jmp .loop_start_6
.loop_end_6:
je .loop_else_skip_6
.loop_else_skip_6:
pop rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rdx, rcx, rbx
float 3.2
mov rdx, rax
list
mov rcx, rax
string "а"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rdx, rcx, rbx
float 2.3
mov rdx, rax
list
mov rcx, rax
string "б"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx
push rcx, rbx
list
mov rcx, rax
string "б"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
addition rax, rbx
pop rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

jmp .skip_function_1
.function_1:
push rdx, rcx, rbx
push rbx
push rcx, rbx
list
mov rcx, rax
string "_2"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "_1"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
addition rax, rbx
pop rbx
mov rdx, rax
list
mov rcx, rax
string "_1"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
integer 123
push rcx, rbx
list
mov rcx, rax
string "_1"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
ret
ret
.skip_function_1:
push r9, r8, rdx, rcx, rbx
string "а"
mov rbx, rax
mov rcx, .function_1
list
mov rdx, rax
dictionary
mov r8, rax
string "_1"
list_append_link rdx, rax
string "_2"
mov r9, rax
list_append_link rdx, r9
integer 0
dictionary_set_link r8, r9, rax
function rbx, rcx, rdx, r8, 0
mov rcx, rax
list
assign rbx, rax, rcx
pop rbx, rcx, rdx, r8, r9

jmp .skip_function_2
.function_2:
push rdx, rcx, rbx
push rbx
push rcx, rbx
list
mov rcx, rax
string "_2"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "_1"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
addition rax, rbx
pop rbx
mov rdx, rax
list
mov rcx, rax
string "_1"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
integer 123
ret
ret
.skip_function_2:
push r9, r8, rdx, rcx, rbx
string "б"
mov rbx, rax
mov rcx, .function_2
list
mov rdx, rax
dictionary
mov r8, rax
string "_1"
list_append_link rdx, rax
string "_2"
mov r9, rax
list_append_link rdx, r9
integer 0
dictionary_set_link r8, r9, rax
function rbx, rcx, rdx, r8, 0
mov rcx, rax
list
assign rbx, rax, rcx
pop rbx, rcx, rdx, r8, r9

jmp .skip_function_3
.function_3:
push rdx, rcx, rbx
push rbx
push rcx, rbx
list
mov rcx, rax
string "_2"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rbx, rax
push rcx, rbx
list
mov rcx, rax
string "_1"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
addition rax, rbx
pop rbx
mov rdx, rax
list
mov rcx, rax
string "_1"
mov rbx, rax
assign rbx, rcx, rdx
pop rbx, rcx, rdx
integer 123
ret
.skip_function_3:
push r9, r8, rdx, rcx, rbx
string "в"
mov rbx, rax
mov rcx, .function_3
list
mov rdx, rax
dictionary
mov r8, rax
string "_1"
list_append_link rdx, rax
string "_2"
mov r9, rax
list_append_link rdx, r9
integer 0
dictionary_set_link r8, r9, rax
function rbx, rcx, rdx, r8, 0
mov rcx, rax
list
assign rbx, rax, rcx
pop rbx, rcx, rdx, r8, r9

jmp .skip_function_4
.function_4:
integer 1
boolean rax
boolean_value rax
cmp rax, 1
jne .if_3_branch_1
integer 123
integer 1
ret
jmp .if_3_end
.if_3_branch_1:
.if_3_end:
ret
.skip_function_4:
push r9, r8, rdx, rcx, rbx
string "г"
mov rbx, rax
mov rcx, .function_4
list
mov rdx, rax
dictionary
mov r8, rax
function rbx, rcx, rdx, r8, 0
mov rcx, rax
list
assign rbx, rax, rcx
pop rbx, rcx, rdx, r8, r9

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 1
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "а"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 1
list_append_link rbx, rax
integer 2
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "б"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 1
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "б"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 1
list_append_link rbx, rax
integer 2
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "в"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 1
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "в"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
integer 1
list_append_link rbx, rax
integer 2
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "г"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "показать"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
push rbx
mov rbx, rax
push rbx, rcx
push rcx, rbx
list
mov rcx, rax
string "г"
mov rbx, rax
access rbx, rcx
pop rbx, rcx
mov rcx, rax
list
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx
list_append_link rbx, rax
mov rax, rbx
pop rbx
mov rbx, rax
list
dictionary_from_pairs rax
function_call rcx, rbx, rax
pop rcx, rbx

exit 0