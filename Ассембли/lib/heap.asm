section "create_block" executable

macro create_block size {
  enter size

  call f_create_block

  return
}

f_create_block:
  mov rbx, rax
  sys_mmap 0,\                                  ; Адрес (если 0, находится автоматически)
           rax,\                                ; Количество памяти для аллокации
           PROT_READ + PROT_WRITE + PROT_EXEC,\ ; Права (PROT_READ | PROT_WRITE)
           MAP_SHARED + MAP_ANONYMOUS,\         ; MAP_ANONYMOUS | MAP_PRIVATE
           0,\                                  ; Файл дескриптор (ввод)
           0                                    ; Смещение относительно начала файла (с начала файла)

  ; Проверка корректности выделения памяти
  test rax, rax
  check_error js, HEAP_ALLOCATION_ERROR

  mem_mov [rax + 8*0], HEAP_BLOCK
  mem_mov [rax + 8*1], rbx

  add rax, HEAP_BLOCK_HEADER*8

  ret

section "delete_block" executable

macro delete_block block {
  enter block

  call f_delete_block

  leave
}

f_delete_block:
  sub rax, HEAP_BLOCK_HEADER*8
  check_type rax, HEAP_BLOCK, EXPECTED_HEAP_BLOCK_ERROR

  sys_munmap rax,\        ; Указатель на кучу
             [rax + 8*1]  ; Размер кучи

  ret
