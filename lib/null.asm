; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

f_null:
  create_block NULL_SIZE*8
  mem_mov [rax + 8*0], NULL
  ret
