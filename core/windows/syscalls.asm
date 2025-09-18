include "api/win64axp.inc"

; Системные вызовы (перенос)
define SYS_READ      0
define SYS_WRITE     1
define SYS_OPEN      2
define SYS_CLOSE     3
define SYS_STAT      4
define SYS_MMAP      9
define SYS_MUNMAP    11
define SYS_FORK      57
define SYS_EXECVE    59
define SYS_EXIT      60
define SYS_WAIT4     61
define SYS_GETCWD    79
define SYS_CHDIR     80
define SYS_READLINK  89
define SYS_GETRANDOM 318

; Опции для SYS_OPEN
define O_RDONLY GENERIC_READ  ; Открытие файла только для чтения
define O_WRONLY GENERIC_WRITE ; Открытие файла только для записи
define O_RDWR   GENERIC_ALL   ; Открытие файла для чтения и записи

define O_CREAT  OF_CREATE         ; Создание файла, если он не существует
define O_TRUNC  TRUNCATE_EXISTING ; Обрезать файл до нулевой длины, если он уже существует

; SYS_MMAP (перенос)
define PROT_NONE  0
define PROT_READ  1
define PROT_WRITE 2
define PROT_EXEC  4

define MAP_SHARED    0x0001
define MAP_PRIVATE   0x0002
define MAP_FIXED     0x0010
define MAP_ANONYMOUS 0x0020
define MAP_GROWSDOWN 0x0100
define MAP_GROWSUP   0x0200
define MAP_HUGETLB   0x4000

; SYS_GETCWD (перенос)
define MAX_PATH_LENGTH 0x1000

; SYS_GETRANDOM (перенос)
define GRND_NONBLOCK 1 ; Попытка немедленного получения без накопления энтропии
define GRND_RANDOM   2 ; Попытка вернуть число, используя максимальную энтропию

macro _get_stdin {
  invoke GetStdHandle, STD_INPUT_HANDLE
}

macro _get_stdout {
  invoke GetStdHandle, STD_OUTPUT_HANDLE
}

macro _get_stderr {
  invoke GetStdHandle, STD_ERROR_HANDLE
}

macro invoke name, [args] {
  common
    count = 0
  forward
    count = count + 1
  common
    count = count - 4

    push rcx, rdx, r8, r9, r10, r11, rbp
    mov rbp, rsp

    ; Теневое пространство
    sub rsp, 4*8
    if count > 0
      sub rsp, count * 8
    end if

    ; Выравнивание
    and rsp, -0x10

    invoke name, args

    mov rsp, rbp
    pop rbp, r11, r10, r9, r8, rdx, rcx
}

macro sys_exit code* {
  mov rax, code
  invoke ExitProcess,\
         rax
}

macro sys_fork [_] {
  raw_string "sys_fork: не реализовано"
  print_raw rax
  sys_exit 200
}

macro sys_execve [_] {
  raw_string "sys_execve: не реализовано"
  print_raw rax
  sys_exit 200
}

macro sys_wait4 [_] {
  raw_string "sys_wait4: не реализовано"
  print_raw rax
  sys_exit 200
}

macro sys_stat file_descriptor*, buffer_ptr* {
  raw_string "sys_stat: не реализовано"
  print_raw rax
  sys_exit 200
}

macro sys_open filename*, flags*, mode* {
  push r8, rbx

  mov rax, filename
  mov r8, flags
  mov rbx, mode

  invoke CreateFileW,\
         rax,\                    ; Имя файла
         r8,\                     ; Доступ
         0,\                      ; Общий доступ
         0,\                      ; Безопасность
         rbx,\                    ; Режим открытия
         FILE_ATTRIBUTE_NORMAL,\  ; Атрибуты и флаги
         0                        ; Дескриптор шаблонного файла

  pop rbx, r8
}

macro sys_close file_descriptor* {
  mov rax, file_descriptor
  invoke CloseHandle,\
         rax
}

macro sys_read file_descriptor*, buffer_ptr*, size* {
  push r9, r8

  mov rax, file_descriptor
  mov r8, buffer_ptr
  mov r9, size

  invoke ReadFile,\
         rax,\ ; Файловый дескриптор
         r8,\  ; Буфер для хранения данных
         r9,\  ; Размер читаемого файла
         0,\
         0

  pop r8, r9
}

macro sys_write file_descriptor*, buffer_ptr*, size* {
  push rax, r8, r9

  mov rax, file_descriptor
  mov r8, buffer_ptr
  mov r9, size

  invoke WriteFile,\
         rax,\ ; Файловый дескриптор, место записи
         r8,\  ; Указатель на сегмент памяти, место чтение
         r9,\  ; Размер читаемой последовательности в байтах
         0,\
         0

  pop r9, r8, rax
}

macro sys_mmap addr*, length*, rights*, flags*, file_descriptor*, offset* {
  ; TODO: Заменить на VirtualAlloc
  raw_string "sys_mmap: не поддерживается"
  print_raw rax
  sys_exit 50
}

macro sys_getcwd buffer*, size* {
  invoke GetCurrentDirectory,\
         size,\   ; Размер буфера
         buffer   ; Буфер, куда будет помещён путь
}

macro sys_chdir path* {
  invoke SetCurrentDirectory,\
         path ; Путь
}

macro sys_readlink [_] {
  raw_string "sys_readlink: не реализовано"
  print_raw rax
  sys_exit 200
}

macro sys_getrandom buffer*, size*, flags = 0 {
  push rax, r8

  mov r8, size
  mov rax, buffer

  invoke BCryptGenRandom,\
         0,\   ; Провайдер криптографического сервиса
         rax,\ ; Буфер
         r8,\  ; Размер
         0x2   ; Флаги

  pop r8, rax
}
