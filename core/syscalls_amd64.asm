section "syscalls_amd64" writable
  ; Системные вызовы
  define SYS_READ   0
  define SYS_WRITE  1
  define SYS_OPEN   2
  define SYS_CLOSE  3
  define SYS_STAT   4
  define SYS_MMAP   9
  define SYS_MUNMAP 11
  define SYS_FORK   57
  define SYS_EXECVE 59
  define SYS_EXIT   60
  define SYS_WAIT4  61

  ; Стандартные файловые дескрипторы
  define STDIN  0
  define STDOUT 1
  define STDERR 2

  ; Опции для SYS_OPEN
  define O_RDONLY    00000000o ; Открытие файла только для чтения
  define O_WRONLY    00000001o ; Открытие файла только для записи
  define O_RDWR      00000002o ; Открытие файла для чтения и записи
  define O_CREAT     00000100o ; Создание файла, если он не существует
  define O_EXCL      00000200o ; Используется с O_CREAT, чтобы гарантировать, что файл будет создан только если он не существует
  define O_NOCTTY    00000400o ; Не назначать терминал для управляющего процесса
  define O_TRUNC     00001000o ; Обрезать файл до нулевой длины, если он уже существует
  define O_APPEND    00002000o ; Запись в файл будет происходить в конец файла
  define O_NONBLOCK  00004000o ; Открытие файла в неблокирующем режиме
  define O_DSYNC     00010000o ; Запись будет выполнена только после того, как данные будут записаны на диск
  define O_DIRECT    00040000o ; Прямой доступ к диску, минуя кэш
  define O_LARGEFILE 00100000o ; Поддержка больших файлов
  define O_DIRECTORY 00200000o ; Убедиться, что открываемый файл является директорией
  define O_NOFOLLOW  00400000o ; Не следовать символическим ссылкам
  define O_NOATIME   01000000o ; Не обновлять время доступа к файлу
  define O_CLOEXEC   02000000o ; Установить флаг close_on_exec
  define O_SYNC      04000000o ; Запись в файл будет синхронизирована с диском
  define O_TMPFILE   20000000o ; Создать временный файл в памяти

  ; SYS_STAT
  define STAT_BUFFER_SIZE 0x90

  ; SYS_MMAP
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

section "syscalls" executable

macro syscall number*, arg_1 = 0, arg_2 = 0, arg_3 = 0, arg_4 = 0, arg_5 = 0, arg_6 = 0 {
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

macro sys_read file_descriptor*, buffer_ptr*, size* {
  syscall SYS_READ,\
          file_descriptor,\ ; Файловый дескриптор, место чтение
          buffer_ptr,\      ; Указатель на сегмент памяти, место записи
          size              ; Размер читаемой последовательности в байтах
}

macro sys_write file_descriptor*, buffer_ptr*, size* {
  syscall SYS_WRITE,\
          file_descriptor,\ ; Файловый дескриптор, место записи
          buffer_ptr,\      ; Указатель на сегмент памяти, место чтение
          size              ; Размер читаемой последовательности в байтах
}

macro sys_open filename*, flags*, mode* {
  syscall SYS_OPEN,\
          filename,\ ; Указатель на имя файла
          flags,\    ; Тип доступа файла
          mode       ; Первоначальное разрешение на доступ к файлу
}

macro sys_close file_descriptor* {
  syscall SYS_CLOSE,\
          file_descriptor ; Файловый дескриптор для закрытия
}

macro sys_stat filename*, buffer_ptr* {
  syscall SYS_STAT,\
          filename,\ ; Указатель на имя файла
          buffer_ptr ; Указатель на сегмент памяти, место записи
}

macro sys_mmap addr*, length*, rights*, flags*, file_descriptor*, offset* {
  syscall SYS_MMAP,\
          addr,\            ; Адрес (если 0, находится автоматически)
          length,\          ; Количество памяти для аллокации
          rights,\          ; Права (PROT_READ | PROT_WRITE)
          flags,\           ; MAP_ANONYMOUS | MAP_PRIVATE
          file_descriptor,\ ; Файловый дескриптор
          offset            ; Смещение относительно начала файла
}

macro sys_munmap addr*, length* {
  syscall SYS_MUNMAP,\
          addr,\ ; Адрес
          length ; Количество памяти для очистки
}

macro sys_exit error_code* {
  syscall SYS_EXIT,\
          error_code ; Код выхода
}

macro sys_fork {
  syscall SYS_FORK
}

macro sys_execve command*, args*, env* {
  syscall SYS_EXECVE,\
          command,\ ; Команда
          args,\    ; Аргументы
          env       ; Переменные среды
}

; TODO: Другие аргументы

macro sys_wait4 pid* {
  syscall SYS_WAIT4,\
          pid  ; Идентификатор процесса
}
