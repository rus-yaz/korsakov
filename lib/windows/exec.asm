; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function run
; @description Запускает внешнюю команду с указанными аргументами и переменными окружения
; @param command - список команд и аргументов для выполнения
; @param env - список переменных окружения
; @param wait=1 - флаг ожидания завершения процесса
; @example
;   list
;   list_append rax, "ls"
;   list_append rax, "-la"
;   mov rbx, rax
;
;   list
;   run rbx, rax  ; запускает команду ls -la без переменных среды
_function run, rax, rbx, rcx, rdx, r12
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  copy rbx
  mov rbx, rax
  copy rcx
  mov rcx, rax

  list_length rbx
  cmp rax, 1
  jge .correct
    string "run: Должна быть передана хотя бы одна строка"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct:

  mov [START_INFO.cb], sizeof.STARTUPINFO

  join_links rbx
  string_to_binary rax
  add rax, BINARY_HEADER*8
  utf8_to_utf16 rax

  invoke CreateProcessW, 0, rax, 0, 0, 0, 0, 0, 0, START_INFO, PROC_INFO

  cmp rax, 0
  jne @f

    string "run: Не удалось создать процесс"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  @@:

  cmp rdx, 0
  je .dont_wait
    invoke WaitForSingleObject, [PROC_INFO.hProcess], -1
  .dont_wait:

  invoke CloseHandle, [PROC_INFO.hProcess]
  invoke CloseHandle, [PROC_INFO.hThread]

  ret
