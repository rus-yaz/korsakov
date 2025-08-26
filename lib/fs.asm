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

    string "Не удалось получить рабочую директорию"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct:

  mov rax, rsp
  add rsp, MAX_PATH_LENGTH

  buffer_to_string rax
  ret

; @function chdir
; @description Изменяет текущую рабочую директорию
; @param path - путь к новой рабочей директории
; @example
;   string "/home/user"
;   chdir rax  ; изменяет рабочую директорию
_function chdir, rax, rbx, rcx
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING

  string_to_binary rbx
  add rax, BINARY_HEADER*8

  sys_chdir rax

  cmp rax, 0
  jne @f
    ret
  @@:

  cmp rax, -2
  jne .not_directory_not_found
    list
    mov rcx, rax
    string "chdir: Объект «"
    list_append_link rcx, rax
    list_append_link rcx, rbx
    string "» не найден"
    list_append_link rcx, rax
    string ""
    error rcx, rax
    exit -1
  .not_directory_not_found:

  cmp rax, -13
  jne .not_permission_denied
    list
    mov rcx, rax
    string "chdir: Доступ к директории «"
    list_append_link rcx, rax
    list_append_link rcx, rbx
    string "» ограничен"
    list_append_link rcx, rax
    string ""
    error rcx, rax
    exit -1
  .not_permission_denied:

  cmp rax, -20
  jne .not_not_a_dicretory
    list
    mov rcx, rax
    string "chdir: Объект «"
    list_append_link rcx, rax
    list_append_link rcx, rbx
    string "» не является директорией"
    list_append_link rcx, rax
    string ""
    error rcx, rax
    exit -1
  .not_not_a_dicretory:

  mov rcx, rax

  list
  mov rbx, rax
  string "chdir: Непокрытая ошибка с кодом"
  list_append_link rbx, rax
  integer rcx
  list_append_link rbx, rax
  error rax
  exit -1

; @function readlink
; @description Читает содержимое символической ссылки
; @param path - путь к символической ссылке
; @return Содержимое символической ссылки
; @example
;   string "/path/to/link"
;   readlink rax  ; читает содержимое символической ссылки
_function readlink, rbx
  get_arg 0
  mov rbx, rax

  check_type rbx, STRING
  string_to_binary rbx

  add rax, BINARY_HEADER*8
  mov rbx, rax

  sub rsp, MAX_PATH_LENGTH
  mov rax, rsp
  sys_readlink rbx, rax, MAX_PATH_LENGTH

  cmp rax, 0
  jg .correct

    string "Не удалось прочитать ссылку"
    mov rbx, rax
    list
    list_append_link rax, rbx
    error rax
    exit -1

  .correct:

  add rax, rsp
  mov byte [rax], 0

  mov rax, rsp
  buffer_to_string rax
  add rsp, MAX_PATH_LENGTH

  ret

; @function get_exe_path
; @description Возвращает путь к исполняемому файлу программы
; @return Путь к исполняемому файлу
; @example
;   get_exe_path  ; возвращает путь к исполняемому файлу
_function get_exe_path
  string "/proc/self/exe"
  readlink rax

  ret

; @function get_exe_directory
; @description Возвращает директорию, в которой находится исполняемый файл программы
; @return Путь к директории исполняемого файла
; @example
;   get_exe_directory  ; возвращает директорию исполняемого файла
_function get_exe_directory, rbx, rcx
  get_exe_path
  mov rbx, rax

  string "/"
  mov rcx, rax
  integer 1
  split_from_right_links rbx, rcx, rax
  mov rbx, rax

  integer 0
  list_pop_link rbx, rax

  ret
