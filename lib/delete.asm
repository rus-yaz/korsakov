; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_delete:
  get_arg 0
  mov rbx, rax

  mov rcx, rbx
  sub rcx, HEAP_BLOCK_HEADER*4

  mov r8d, [rcx]
  cmp r8d, HEAP_BLOCK
  je .correct_block

    raw_string "free_block: Ожидался блок кучи"
    error_raw rax
    exit -1

  .correct_block:

  mov rcx, [rbx]

  cmp rcx, COLLECTION
  je .collection
  cmp rcx, LIST
  je .collection
  cmp rcx, STRING
  je .collection
  cmp rcx, DICTIONARY
  je .collection

    ; Если прыжка не произошло, переменная не является коллекцией
    delete_block rbx
    ret

  .collection:

  mov rcx, [rbx + 8*3]
  mov rdx, [rbx + 8*1]
  delete_block rbx

  mov r8, rcx

  .while:
    cmp rdx, 0
    je .end_while

    delete [r8]
    add r8, 8

    dec rdx
    jmp .while

  .end_while:

  delete_block rcx

  ret
