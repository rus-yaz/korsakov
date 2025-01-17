string "Работа с файлами"
print rax

; Получение размера файла
get_file_size file.имя_файла_для_чтения
integer rax
print <FILE_SIZE_TEXT, rax>

; Открытие файла
open_file file.имя_файла_для_чтения
mov rbx, rax

; Чтение файла
read_file rbx
mov rcx, rax

; Закрытие файла, дальше он не нужен
close_file rbx

; Получение длины строки
string_length rcx
integer rax
print <STRING_SIZE_TEXT, rax>

; Вывод содержимого файла
print <STRING_CONTENT_TEXT, rcx>

; ---------
; Тест записи файла

; Открытие файла в режиме записи
open_file file.имя_файла_для_записи, O_WRONLY + O_CREAT + O_TRUNC, 644o
mov r8, rax

; Запись в файл из строки
write_file r8, rcx

; Закрытие файла
close_file r8

; Открытие файла
open_file file.имя_файла_для_записи
mov r8, rax

; Чтение файла
read_file r8
mov rcx, rax

; Закрытие файла, дальше он не нужен
close_file r8

; Вывод содержимого файла
print <STRING_CONTENT_TEXT, rcx>
