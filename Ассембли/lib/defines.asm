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
define FILE_DESCRIPTOR_SIZE 0x400

define O_RDONLY     0x0000 ; Только чтение
define O_WRONLY     0x0001 ; Только запись
define O_RDWR       0x0002 ; Чтение и запись
define O_APPEND     0x0008 ; Операции записи добавляются в конец файла
define O_SYNC       0x0040 ; Запись завершается после записи данных и метаданных
define O_NONBLOCK   0x0080 ; Открывается в неблокирующем режиме
define O_DSYNC      0x0100 ; Запись данных завершается только тогда, когда данные физически записаны
define O_CREAT      0x0200 ; Создание файла, если он не существует
define O_TRUNC      0x0400 ; Обрезка файла до нулевой длины, если он существует
define O_EXCL       0x0800 ; Ошибка, если файл уже существует (используется с O_CREAT)
define O_DIRECTORY  0x2000 ; Ошибка, если файл не является каталогом

; STAT
define STAT_BUFFER_SIZE 0x90

; MMAP
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

; Типы данных
define NULL            0
define INTEGER         1
define FLOAT           2
define LIST            3
define CHAR            4
define STRING          5
define BINARY          6
define DICTIONARY      7
define FUNCTION        8
define CLASS           9
define FILE_DESCRIPTOR 10
define FILE            11

; Размер заголовков типов данных
define INTEGER_HEADER 1
define CHAR_HEADER    2
define STRING_HEADER  2
define BINARY_HEADER  2
define LIST_HEADER    3
define HEAP_BLOCK_HEADER 4
