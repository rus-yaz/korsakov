include '/var/home/x1z53/git/korsakov/core/korsakov.asm'
include '/var/home/x1z53/git/korsakov/modules/.asm'
start:
init_
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
string 'модуль1'
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
push rbx
string ""
mov rbx, rax
string 'модуль2'
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
push rbx
string ""
mov rbx, rax
string 'тело'
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
push rbx
string ""
mov rbx, rax
string 'модули/модуль1'
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
push rbx
string ""
mov rbx, rax
string 'модули/модуль3'
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
push rbx
string ""
mov rbx, rax
string 'модуль3'
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
push rbx
string ""
mov rbx, rax
string 'модули/модуль2'
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
push rbx
string ""
mov rbx, rax
string 'тело2'
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

exit 0