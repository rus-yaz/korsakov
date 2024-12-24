integer 1
mov [functions.число_1], rax

integer 2
mov [functions.число_2], rax

is_equal [functions.число_1], [functions.число_1]
integer rax
print rax

is_equal [functions.число_1], [functions.число_2]
integer rax
print rax

buffer_to_string functions.буфер_1
mov [functions.тестовый_текст_1], rax

buffer_to_string functions.буфер_2
mov [functions.тестовый_текст_2], rax

is_equal [functions.тестовый_текст_1], [functions.тестовый_текст_1]
integer rax
print rax

is_equal [functions.тестовый_текст_1], [functions.тестовый_текст_2]
integer rax
print rax

integer 4
push rax
integer 3
push rax
integer 2
push rax
integer 1
push rax

mov rax, rsp
list rax, 4
mov [functions.список_1], rax

integer 1
push rax
integer 2
push rax
integer 3
push rax
integer 4
push rax

mov rax, rsp
list rax, 4
mov [functions.список_2], rax

is_equal [functions.список_1], [functions.список_1]
integer rax
print rax

is_equal [functions.список_1], [functions.список_2]
integer rax
print rax
