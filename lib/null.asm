; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function null
; @description Создает и возвращает объект типа null
; @return Объект типа null
; @example
;   null  ; создает объект null
_function null
  create_block NULL_SIZE*8
  mem_mov [rax + 8*0], NULL
  ret
