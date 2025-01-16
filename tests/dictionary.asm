dictionary 0
mov rcx, rax
print rax

dictionary_length rax
integer rax
print rax

integer 0
mov rbx, rax
integer 1
dictionary_set rcx, rax, rbx
print rax

list 0
mov rbx, rax
integer 0
list_append rbx, rax
integer 1
list_append rbx, rax
integer 2
list_append rbx, rax

list 0
mov rcx, rax
integer 3
list_append rcx, rax
integer 4
list_append rcx, rax
integer 5
list_append rcx, rax

dictionary rbx, rcx
mov rbx, rax
print rbx

integer 1
dictionary_get rbx, rax
print rax

integer 99
dictionary_get rbx, rax, rax
print rax

dictionary_keys rbx
print rax

dictionary_values rbx
print rax

dictionary_items rbx
print rax

dictionary_copy rbx
print rax

dictionary 0
mov rbx, rax

integer 0
mov rcx, rax
dictionary_set rbx, rcx, rcx

print rax

buffer_to_string delete.буфер
dictionary_set rbx, rcx, rax

print rax
