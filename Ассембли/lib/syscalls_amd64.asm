; Системные вызовы
define SYS_READ   0
define SYS_WRITE  1
define SYS_OPEN   2
define SYS_CLOSE  3
define SYS_STAT   4
define SYS_MMAP   9
define SYS_MUNMAP 11
define SYS_EXIT   60

; Стандартные файловые дескрипторы
define STDIN  0
define STDOUT 1
define STDERR 2

section "syscall" executable

; Системный вызов. Количество передаваемых аргументов зависит от указанной в макросе цифры
;
; Аргументы:
;   number — номер системного вызова
;   arg_1...arg_6 — аргументы системного вызова (rdi, rsi, rdx, r10, r8, r9)

macro syscall number, arg_1 = 0, arg_2 = 0, arg_3 = 0, arg_4 = 0, arg_5 = 0, arg_6 = 0 {
  push r9, r8, r10, rdx, rsi, rdi

  mov r9,  arg_6
  mov r8,  arg_5
  mov r10, arg_4
  mov rdx, arg_3
  mov rsi, arg_2
  mov rdi, arg_1
  mov rax, number
  syscall

  pop r9, r8, r10, rdx, rsi, rdi
}

macro sys_read file_descriptor, buffer_ptr, size {
  syscall SYS_READ,\
          file_descriptor,\ ; Файловый дескриптор, место чтение
          buffer_ptr,\      ; Указатель на сегмент памяти, место записи
          size              ; Размер читаемой последовательности в байтах
}

macro sys_write file_descriptor, buffer_ptr, size {
  syscall SYS_WRITE,\
          file_descriptor,\ ; Файловый дескриптор, место записи
          buffer_ptr,\      ; Указатель на сегмент памяти, место чтение
          size              ; Размер читаемой последовательности в байтах
}

macro sys_open filename, flags, mode {
  syscall SYS_OPEN,\
          filename,\ ; Указатель на имя файла
          flags,\    ; Тип доступа файла
          mode       ; Первоначальное разрешение на доступ к файлу
}

macro sys_close file_descriptor {
  syscall SYS_CLOSE,\
          file_descriptor ; Файловый дескриптор для закрытия
}

macro sys_stat filename, buffer_ptr {
  syscall SYS_STAT,\
          filename,\ ; Указатель на имя файла
          buffer_ptr ; Указатель на сегмент памяти, место записи
}

macro sys_mmap addr, length, rights, flags, file_descriptor, offset {
  syscall SYS_MMAP,\
          addr,\            ; Адрес (если 0, находится автоматически)
          length,\          ; Количество памяти для аллокации
          rights,\          ; Права (PROT_READ | PROT_WRITE)
          flags,\           ; MAP_ANONYMOUS | MAP_PRIVATE
          file_descriptor,\ ; Файловый дескриптор
          offset            ; Смещение относительно начала файла
}

macro sys_munmap addr, length {
  syscall SYS_MUNMAP,\
          addr,\            ; Адрес
          length            ; Количество памяти для очистки
}

macro sys_exit error_code {
  syscall SYS_EXIT,\
          error_code ; Код выхода
}
