integer 1
mov rax, rsp
mov [число_1], rax

integer 2
mov rax, rsp
mov [число_2], rax

is_equal [число_1], [число_1]
integer rax
mov rax, rsp
print rax

is_equal [число_1], [число_2]
integer rax
mov rax, rsp
print rax

buffer_to_string temp_buffer_1
mov [тестовый_текст_1], rax

buffer_to_string temp_buffer_2
mov [тестовый_текст_2], rax

is_equal [тестовый_текст_1], [тестовый_текст_1]
integer rax
mov rax, rsp
print rax

is_equal [тестовый_текст_1], [тестовый_текст_2]
integer rax
mov rax, rsp
print rax

integer 1
integer 2
integer 3
integer 4

mov rax, rsp
list rax, 4
mov [список_1], rax

integer 4
integer 3
integer 2
integer 1

mov rax, rsp
list rax, 4
mov [список_2], rax

is_equal [список_1], [список_1]
integer rax
mov rax, rsp
print rax

is_equal [список_1], [список_2]
integer rax
mov rax, rsp
print rax
