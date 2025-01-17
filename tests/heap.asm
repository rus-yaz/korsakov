string "Работа с кучей"
print rax

; Расширение кучи
create_block 0x1000
mov rbx, rax

create_block 0x1000
mov rcx, rax

create_block 0x1000
mov rdx, rax

delete_block rbx
delete_block rdx
delete_block rcx
