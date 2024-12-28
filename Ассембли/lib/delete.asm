f_delete:
  mov rbx, [rax - HEAP_BLOCK_HEADER*8]
  mov rcx, HEAP_BLOCK

  cmp rbx, rcx
  je .not_collection_item
    sub rax, 2*8 ; Учёт ссылок
    mov rbx, rax

    sub rbx, HEAP_BLOCK_HEADER*8
    check_type rbx, HEAP_BLOCK

  .not_collection_item:
  mov rbx, [rax]

  cmp rbx, LIST
  je .collection

  cmp rbx, STRING
  je .collection

  cmp rbx, DICTIONARY
  je .collection

  ; Если прыжка не произошло, переменная не является коллекцией
  delete_block rax
  ret

  .collection:

  mov rbx, [rax + 8*1]
  delete_block rax
  mov rax, rbx

  .while:
    cmp rax, 0
    je .end_while

    mov rbx, [rax + 8*1]
    add rax, 8*2

    delete rax

    mov rax, rbx
    jmp .while

  .end_while:

  ret
