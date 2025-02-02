string "Работа с файлами"
print rax

; Получение размера файла
get_file_size file.имя_файла_для_чтения
integer rax
mov rbx, rax
string "Размер файла:"
print <rax, rbx>

; Открытие файла
buffer_to_string file.имя_файла_для_чтения
open_file rax
mov rbx, rax

; Чтение файла
read_file rbx
mov rcx, rax

; Закрытие файла, дальше он не нужен
close_file rbx

; Получение длины строки
string_length rcx
integer rax
mov rbx, rax
string  "Размер строки:"
print <rax, rbx>

; Вывод содержимого файла
string "Содержимое строки:"
print <rax, rcx>

; ---------
; Тест записи файла

; Открытие файла в режиме записи
buffer_to_string file.имя_файла_для_записи
open_file rax, O_WRONLY + O_CREAT + O_TRUNC, 644o
mov r8, rax

; Запись в файл из строки
write_file r8, rcx

; Закрытие файла
close_file r8

; Открытие файла
buffer_to_string file.имя_файла_для_записи
open_file rax
mov r8, rax

; Чтение файла
read_file r8
mov rcx, rax

; Закрытие файла, дальше он не нужен
close_file r8

; Вывод содержимого файла
string "Содержимое строки:"
print <rax, rcx>
