; Тест работы с кучей

; Расширение кучи
create_block 0x1000
mov [heap.тестовый_блок_1], rax

create_block 0x1000
mov [heap.тестовый_блок_2], rax

create_block 0x1000
mov [heap.тестовый_блок_3], rax

delete_block [heap.тестовый_блок_1]
delete_block [heap.тестовый_блок_3]
delete_block [heap.тестовый_блок_2]
