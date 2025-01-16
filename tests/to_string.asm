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

list 0
to_string rax
print rax

dictionary 0
to_string rax
print rax

list 0
mov rbx, rax
integer 0
list_append rbx, rax
integer 1
list_append rbx, rax
integer -1
list_append rbx, rax
string "123"
list_append rbx, rax
list 0
list_append rbx, rax
dictionary 0
list_append rbx, rax
to_string rbx
print rax
