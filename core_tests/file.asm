; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

string "Работа с файлами"
mov rdx, rax
list
list_append_link rax, rdx
print rax

; Получение размера файла
string "Привет"
get_file_size rax
integer rax
mov rbx, rax
string "Размер файла:"
mov rdx, rax
list
list_append_link rax, rdx
list_append_link rax, rbx
print rax

; Открытие файла
string "Привет"
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
mov rdx, rax
list
list_append_link rax, rdx
list_append_link rax, rbx
print rax

; Вывод содержимого файла
string "Содержимое строки:"
mov rdx, rax
list
list_append_link rax, rdx
list_append_link rax, rcx
print rax

; ---------
; Тест записи файла

; Открытие файла в режиме записи
string "Пока"
open_file rax, O_WRONLY + O_CREAT + O_TRUNC, 644o
mov r8, rax

; Запись в файл из строки
write_file r8, rcx

; Закрытие файла
close_file r8

; Открытие файла
string "Пока"
open_file rax
mov r8, rax

; Чтение файла
read_file r8
mov rcx, rax

; Закрытие файла, дальше он не нужен
close_file r8

; Вывод содержимого файла
string "Содержимое строки:"
mov rdx, rax
list
list_append_link rax, rdx
list_append_link rax, rcx
print rax
