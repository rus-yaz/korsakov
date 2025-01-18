f_null:
  mov rbx, rax

  create_block INTEGER_SIZE*8

  mem_mov [rax + 8*0], NULL

  ret
