; OPEN
define FILE_DESCRIPTOR_SIZE 0x400

define O_RDONLY    0x0000 ; Open for reading only
define O_WRONLY    0x0001 ; Open for writing only
define O_RDWR      0x0002 ; Open for reading and writing
define O_CREAT     0x0200 ; Create the file if it does not exist
define O_EXCL      0x0400 ; Ensure that this call creates the file. If the file already exists, the call will fail
define O_TRUNC     0x2000 ; If the file is opened for writing (O_WRONLY or O_RDWR) and it already exists, truncate it to zero length
define O_APPEND    0x0008 ; Open the file in append mode. Writes will occur at the end of the file
define O_NONBLOCK  0x0080 ; Open in non-blocking mode. For example, for sockets, this means that operations will not block if the data is not immediately available
define O_DSYNC     0x0100 ; Write operations will complete when the data is physically written to the disk
define O_RSYNC     0x1000 ; Read operations will complete when the data is physically written to the disk
define O_SYNC      0x1010 ; Write operations will complete when the data and metadata are physically written to the disk
define O_DIRECTORY 0x2000 ; The file is expected to be a directory
define O_NOFOLLOW  0x2000 ; Do not follow symbolic links

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
