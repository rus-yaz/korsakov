integer 1
mov rax, rsp
mov [functions.число_1], rax

integer 2
mov rax, rsp
mov [functions.число_2], rax

is_equal [functions.число_1], [functions.число_1]
integer rax
mov rax, rsp
print rax

is_equal [functions.число_1], [functions.число_2]
integer rax
mov rax, rsp
print rax

buffer_to_string functions.буфер_1
mov [functions.тестовый_текст_1], rax

buffer_to_string functions.буфер_1
mov [functions.тестовый_текст_2], rax

is_equal [functions.тестовый_текст_1], [functions.тестовый_текст_1]
integer rax
mov rax, rsp
print rax

is_equal [functions.тестовый_текст_1], [functions.тестовый_текст_2]
integer rax
mov rax, rsp
print rax

integer 1
integer 2
integer 3
integer 4

mov rax, rsp
list rax, 4
mov [functions.список_1], rax

integer 4
integer 3
integer 2
integer 1

mov rax, rsp
list rax, 4
mov [functions.список_2], rax

is_equal [functions.список_1], [functions.список_1]
integer rax
mov rax, rsp
print rax

is_equal [functions.список_1], [functions.список_2]
integer rax
mov rax, rsp
print rax
