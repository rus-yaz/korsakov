; Тест чтения файла

; Получение размера файла
get_file_size file.имя_файла_для_чтения
integer rax
print <FILE_SIZE_TEXT, rax>

; Открытие файла
open_file file.имя_файла_для_чтения
mov [file.файл_для_чтения], rax

; Чтение файла
read_file [file.файл_для_чтения]
mov [file.содержимое_файла], rax

; Закрытие файла, дальше он не нужен
close_file [file.файл_для_чтения]

; Получение длины строки
string_length [file.содержимое_файла]
integer rax
mov [file.размер_файла], rax
print <STRING_SIZE_TEXT, [file.размер_файла]>

; Вывод содержимого файла
print <STRING_CONTENT_TEXT, [file.содержимое_файла]>

; ---------
; Тест записи файла

; Открытие файла в режиме записи
open_file file.имя_файла_для_записи, O_WRONLY + O_CREAT + O_TRUNC, 644o
mov [file.файл_для_записи], rax

; Запись в файл из строки
write_file [file.файл_для_записи], [file.содержимое_файла]

; Закрытие файла
close_file [file.файл_для_записи]

; Открытие файла
open_file file.имя_файла_для_записи
mov [file.файл_для_записи], rax

; Чтение файла
read_file [file.файл_для_записи]
mov [file.содержимое_файла], rax

; Закрытие файла, дальше он не нужен
close_file [file.файл_для_записи]

; Вывод содержимого файла
print <STRING_CONTENT_TEXT, [file.содержимое_файла]>
