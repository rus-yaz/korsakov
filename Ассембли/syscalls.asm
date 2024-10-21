; Системные вызовы
define SYS_READ   0
define SYS_WRITE  1
define SYS_OPEN   2
define SYS_CLOSE  3
define SYS_STAT   4
define SYS_MMAP   9
define SYS_MUNMAP 11
define SYS_EXIT   60

; WRITE
define STDIN  0
define STDOUT 1
define STDERR 2

; OPEN
define O_RDONLY     0    ; 0x0000
define O_WRONLY     1    ; 0x0001
define O_RDWR       2    ; 0x0002
define O_APPEND     8    ; 0x0008 Операции записи добавляются в конец файла
define O_SYNC       64   ; 0x0040 Запись завершается после записи данных и метаданных
define O_NONBLOCK   128  ; 0x0080 Открывается в неблокирующем режиме
define O_DSYNC      256  ; 0x0100 Запись данных завершается только тогда, когда данные физически записаны
define O_CREAT      512  ; 0x0200 Создание файла, если он не существует
define O_TRUNC      1024 ; 0x0400 Обрезка файла до нулевой длины, если он существует
define O_EXCL       2048 ; 0x0800 Ошибка, если файл уже существует (используется с O_CREAT)
define O_DIRECTORY  8192 ; 0x2000 Ошибка, если файл не является каталогом

; STAT
define STAT_BUFFER_SIZE 144 ; 0x90

; MMAP
define PROT_NONE  0
define PROT_READ  1
define PROT_WRITE 2
define PROT_EXEC  4

define MAP_SHARED    1     ; 0x0001
define MAP_PRIVATE   2     ; 0x0002
define MAP_FIXED     16    ; 0x0010
define MAP_ANONYMOUS 32    ; 0x0020
define MAP_GROWSDOWN 256   ; 0x0100
define MAP_GROWSUP   512   ; 0x0200
define MAP_HUGETLB   16384 ; 0x4000
