boolean 1
print rax

boolean 0
print rax

integer 1
boolean rax
print rax

integer 0
boolean rax
print rax

integer 0
mov rbx, rax
list
list_append rax, rbx
boolean rax
print rax

list
boolean rax
print rax

string "Привет"
boolean rax
print rax

string ""
boolean rax
print rax

integer 0
mov rbx, rax
integer 1
mov rcx, rax
dictionary
boolean rax
print rax

dictionary
boolean rax
print rax
