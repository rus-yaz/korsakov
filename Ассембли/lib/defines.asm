; FILE
define FILE_DESCRIPTOR_SIZE 0x400

; OPEN
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
define STRING          4
define BINARY          5
define DICTIONARY      6
define FUNCTION        7
define CLASS           8
define FILE_DESCRIPTOR 9
define FILE            10
define HEADER_SIGN     0xFEDCBA9876543210

; Размер заголовков типов данных
define INTEGER_HEADER 1
define STRING_HEADER  2
define BINARY_HEADER  2
define LIST_HEADER    3
define HEAP_BLOCK_HEADER 4
