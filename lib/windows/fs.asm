; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

; @function getcwd
; @description Возвращает текущую рабочую директорию
; @return Путь к текущей рабочей директории
; @example
;   getcwd  ; возвращает текущую рабочую директорию
_function getcwd, rbx
  sub rsp, MAX_PATH_LENGTH
  mov rax, rsp

  sys_getcwd rax, MAX_PATH_LENGTH

  cmp rax, 0
  jg .correct

    string "getcwd: Не удалось получить рабочую директорию"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct:

  mov rax, rsp
  utf16_to_utf8 rax
  buffer_to_string rax

  add rsp, MAX_PATH_LENGTH
  ret

; @function chdir
; @description Изменяет текущую рабочую директорию
; @param path - путь к новой рабочей директории
; @example
;   string "/home/user"
;   chdir rax  ; изменяет рабочую директорию
_function chdir, rax, rbx, r11
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_to_binary rbx
  add rax, BINARY_HEADER*8
  utf8_to_utf16 rax

  push r11
  sys_chdir rax
  pop r11

  cmp rax, 0
  je @f
    ret
  @@:

  raw_string "chdir: Непокрытая ошибка", 10
  error_raw rax
  exit -1

; @function get_exe_path
; @description Возвращает путь к исполняемому файлу программы
; @return Путь к исполняемому файлу
; @example
;   get_exe_path  ; возвращает путь к исполняемому файлу
_function get_exe_path
  sub rsp, MAX_PATH_LENGTH
  mov rbx, rsp

  invoke GetModuleFileNameW, 0, rbx, MAX_PATH_LENGTH
  utf16_to_utf8 rbx
  buffer_to_string rax

  add rsp, MAX_PATH_LENGTH
  ret

; @function get_exe_directory
; @description Возвращает директорию, в которой находится исполняемый файл программы
; @return Путь к директории исполняемого файла
; @example
;   get_exe_directory  ; возвращает директорию исполняемого файла
_function get_exe_directory, rbx, rcx
  get_exe_path
  mov rbx, rax

  string '\'
  mov rcx, rax
  integer 1
  split_from_right_links rbx, rcx, rax
  mov rbx, rax

  integer 0
  list_pop_link rbx, rax

  ret
