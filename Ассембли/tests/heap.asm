; Тест работы с кучей

; Расширение кучи
expand_heap 0x1000

create_block 0x100
mov [тестовый_блок_1], rax

create_block 0x100
mov [тестовый_блок_2], rax

create_block 0x100
mov [тестовый_блок_3], rax

delete_block [тестовый_блок_1]
delete_block [тестовый_блок_3]
delete_block [тестовый_блок_2]
