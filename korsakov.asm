; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

include "./core/korsakov.asm"

include "./token.asm"
include "./nodes.asm"
include "./tokenizer.asm"
include "./parser.asm"
include "./compiler.asm"

section "data" writable
  СРАВНЕНИЯ          rq 1
  АСД                rq 1

  ДВОЙНАЯ_КАВЫЧКА           rq 1
  ОТКРЫВАЮЩАЯ_СКОБКА        rq 1
  ЗАКРЫВАЮЩАЯ_СКОБКА        rq 1
  ДВОЕТОЧИЕ                 rq 1
  ТОЧКА_С_ЗАПЯТОЙ           rq 1
  ТОЧКА                     rq 1
  ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК      rq 1
  РАВНО                     rq 1
  ПЛЮС                      rq 1
  МИНУС                     rq 1
  ЗВЁЗДОЧКА                 rq 1
  КОСАЯ_ЧЕРТА               rq 1
  ОБРАТНАЯ_КОСАЯ_ЧЕРТА      rq 1
  ТАБУЛЯЦИЯ                 rq 1
  ПЕРЕНОС_СТРОКИ            rq 1
  ПРОБЕЛ                    rq 1
  ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА rq 1

  И          rq 1
  ИЗ         rq 1
  ОТ         rq 1
  ДО         rq 1
  НЕ         rq 1
  ТО         rq 1
  ИЛИ        rq 1
  ПРИ        rq 1
  ДЛЯ        rq 1
  ЕСЛИ       rq 1
  ЛОЖЬ       rq 1
  ПОКА       rq 1
  ЧЕРЕЗ      rq 1
  КЛАСС      rq 1
  ИНАЧЕ      rq 1
  ИСТИНА     rq 1
  ВЕРНУТЬ    rq 1
  УДАЛИТЬ    rq 1
  ФУНКЦИЯ    rq 1
  ПРЕРВАТЬ   rq 1
  ВКЛЮЧИТЬ   rq 1
  ПРОВЕРИТЬ  rq 1
  ПРОПУСТИТЬ rq 1

  тип             rq 1
  узел            rq 1
  значение        rq 1
  аргументы       rq 1
  переменная      rq 1
  ключи           rq 1
  левый_узел      rq 1
  правый_узел     rq 1
  оператор        rq 1
  операнд         rq 1
  элементы        rq 1
  случаи          rq 1
  случай_иначе    rq 1
  начало          rq 1
  конец           rq 1
  шаг             rq 1
  тело            rq 1
  вернуть_нуль    rq 1
  условие         rq 1
  автовозвращение rq 1
  имя_класса      rq 1
  имя_объекта     rq 1
  родители        rq 1
  путь            rq 1
  имя_переменной  rq 1

  код            rq 1
  типы           rq 1
  токен          rq 1
  индекс         rq 1
  токены         rq 1
  символы        rq 1
  тип_токена     rq 1
  ключевые_слова rq 1

  ТИП_КОНЕЦ_ФАЙЛА               rq 1
  ТИП_ИДЕНТИФИКАТОР             rq 1
  ТИП_КЛЮЧЕВОЕ_СЛОВО            rq 1
  ТИП_ОТКРЫВАЮЩАЯ_СКОБКА        rq 1
  ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА        rq 1
  ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА rq 1
  ТИП_СТРОКА                    rq 1
  ТИП_ЦЕЛОЕ_ЧИСЛО               rq 1
  ТИП_ВЕЩЕСТВЕННОЕ_ЧИСЛО        rq 1
  ТИП_ТАБУЛЯЦИЯ                 rq 1
  ТИП_ПЕРЕНОС_СТРОКИ            rq 1
  ТИП_ДВОЕТОЧИЕ                 rq 1
  ТИП_ТОЧКА_С_ЗАПЯТОЙ           rq 1
  ТИП_ТОЧКА                     rq 1
  ТИП_ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК      rq 1
  ТИП_ПРИСВАИВАНИЕ              rq 1
  ТИП_СЛОЖЕНИЕ                  rq 1
  ТИП_ВЫЧИТАНИЕ                 rq 1
  ТИП_УМНОЖЕНИЕ                 rq 1
  ТИП_ДЕЛЕНИЕ                   rq 1
  ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ      rq 1
  ТИП_ЦЕЛОЧИСЛЕННОЕ_ДЕЛЕНИЕ     rq 1
  ТИП_ИЗВЛЕЧЕНИЕ_КОРНЯ          rq 1
  ТИП_ОБРАТНАЯ_КОСАЯ_ЧЕРТА      rq 1
  ТИП_ПРОБЕЛ                    rq 1
  ТИП_РАВНО                     rq 1
  ТИП_НЕ_РАВНО                  rq 1
  ТИП_БОЛЬШЕ                    rq 1
  ТИП_МЕНЬШЕ                    rq 1
  ТИП_БОЛЬШЕ_ИЛИ_РАВНО          rq 1
  ТИП_МЕНЬШЕ_ИЛИ_РАВНО          rq 1
  ТИП_ИНКРЕМЕНТАЦИЯ             rq 1
  ТИП_ДЕКРЕМЕНТАЦИЯ             rq 1
  ТИП_КОНЕЦ_КОНСТРУКЦИИ         rq 1

  УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ    rq 1
  УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ       rq 1
  УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ rq 1
  УЗЕЛ_СПИСКА                  rq 1
  УЗЕЛ_НУЛЬ                    rq 1
  УЗЕЛ_ЧИСЛА                   rq 1
  УЗЕЛ_СТРОКИ                  rq 1
  УЗЕЛ_ВЫЗОВА                  rq 1
  УЗЕЛ_УНАРНОЙ_ОПЕРАЦИИ        rq 1
  УЗЕЛ_СЛОВАРЯ                 rq 1
  УЗЕЛ_ПРОВЕРКИ                rq 1
  УЗЕЛ_ЕСЛИ                    rq 1
  УЗЕЛ_ДЛЯ                     rq 1
  УЗЕЛ_ПОКА                    rq 1
  УЗЕЛ_МЕТОДА                  rq 1
  УЗЕЛ_ФУНКЦИИ                 rq 1
  УЗЕЛ_КЛАССА                  rq 1
  УЗЕЛ_УДАЛЕНИЯ                rq 1
  УЗЕЛ_ВКЛЮЧЕНИЯ               rq 1
  УЗЕЛ_ВОЗВРАЩЕНИЯ             rq 1
  УЗЕЛ_ПРОПУСКА                rq 1
  УЗЕЛ_ПРЕРЫВАНИЯ              rq 1

section "start" executable
start:
  string '"'
  mov [ДВОЙНАЯ_КАВЫЧКА], rax
  string "("
  mov [ОТКРЫВАЮЩАЯ_СКОБКА], rax
  string ")"
  mov [ЗАКРЫВАЮЩАЯ_СКОБКА], rax
  string ":"
  mov [ДВОЕТОЧИЕ], rax
  string ";"
  mov [ТОЧКА_С_ЗАПЯТОЙ], rax
  string "."
  mov [ТОЧКА], rax
  string "!"
  mov [ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК], rax
  string "="
  mov [РАВНО], rax
  string "+"
  mov [ПЛЮС], rax
  string "-"
  mov [МИНУС], rax
  string "*"
  mov [ЗВЁЗДОЧКА], rax
  string "/"
  mov [КОСАЯ_ЧЕРТА], rax
  string "\\"
  mov [ОБРАТНАЯ_КОСАЯ_ЧЕРТА], rax
  string 9
  mov [ТАБУЛЯЦИЯ], rax
  string 10
  mov [ПЕРЕНОС_СТРОКИ], rax
  string " "
  mov [ПРОБЕЛ], rax

  integer 0
  mov [ТИП_КОНЕЦ_ФАЙЛА], rax
  integer 1
  mov [ТИП_ИДЕНТИФИКАТОР], rax
  integer 2
  mov [ТИП_КЛЮЧЕВОЕ_СЛОВО], rax
  integer 3
  mov [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА], rax
  integer 4
  mov [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА], rax
  integer 5
  mov [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА], rax
  integer 6
  mov [ТИП_СТРОКА], rax
  integer 7
  mov [ТИП_ЦЕЛОЕ_ЧИСЛО], rax
  integer 8
  mov [ТИП_ВЕЩЕСТВЕННОЕ_ЧИСЛО], rax
  integer 9
  mov [ТИП_ПЕРЕНОС_СТРОКИ], rax
  integer 10
  mov [ТИП_ТАБУЛЯЦИЯ], rax
  integer 11
  mov [ТИП_ДВОЕТОЧИЕ], rax
  integer 12
  mov [ТИП_ТОЧКА_С_ЗАПЯТОЙ], rax
  integer 13
  mov [ТИП_ТОЧКА], rax
  integer 14
  mov [ТИП_ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК], rax
  integer 15
  mov [ТИП_ПРИСВАИВАНИЕ], rax
  integer 16
  mov [ТИП_СЛОЖЕНИЕ], rax
  integer 17
  mov [ТИП_ВЫЧИТАНИЕ], rax
  integer 18
  mov [ТИП_УМНОЖЕНИЕ], rax
  integer 19
  mov [ТИП_ДЕЛЕНИЕ], rax
  integer 20
  mov [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ], rax
  integer 21
  mov [ТИП_ЦЕЛОЧИСЛЕННОЕ_ДЕЛЕНИЕ], rax
  integer 22
  mov [ТИП_ИЗВЛЕЧЕНИЕ_КОРНЯ], rax
  integer 23
  mov [ТИП_ОБРАТНАЯ_КОСАЯ_ЧЕРТА], rax
  integer 24
  mov [ТИП_ПРОБЕЛ], rax
  integer 25
  mov [ТИП_РАВНО], rax
  integer 26
  mov [ТИП_НЕ_РАВНО], rax
  integer 27
  mov [ТИП_БОЛЬШЕ], rax
  integer 28
  mov [ТИП_МЕНЬШЕ], rax
  integer 29
  mov [ТИП_БОЛЬШЕ_ИЛИ_РАВНО], rax
  integer 30
  mov [ТИП_МЕНЬШЕ_ИЛИ_РАВНО], rax
  integer 31
  mov [ТИП_ИНКРЕМЕНТАЦИЯ], rax
  integer 32
  mov [ТИП_ДЕКРЕМЕНТАЦИЯ], rax
  integer 33
  mov [ТИП_КОНЕЦ_КОНСТРУКЦИИ], rax

  list
  list_append_link rax, [ТИП_РАВНО]
  list_append_link rax, [ТИП_НЕ_РАВНО]
  list_append_link rax, [ТИП_БОЛЬШЕ]
  list_append_link rax, [ТИП_МЕНЬШЕ]
  list_append_link rax, [ТИП_БОЛЬШЕ_ИЛИ_РАВНО]
  list_append_link rax, [ТИП_МЕНЬШЕ_ИЛИ_РАВНО]
  mov [СРАВНЕНИЯ], rax

  dictionary
  mov [типы], rax

  dictionary_set_link [типы], [ОТКРЫВАЮЩАЯ_СКОБКА], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]
  dictionary_set_link [типы], [ЗАКРЫВАЮЩАЯ_СКОБКА], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  dictionary_set_link [типы], [ДВОЕТОЧИЕ], [ТИП_ДВОЕТОЧИЕ]
  dictionary_set_link [типы], [ТОЧКА_С_ЗАПЯТОЙ], [ТИП_ТОЧКА_С_ЗАПЯТОЙ]
  dictionary_set_link [типы], [ТОЧКА], [ТИП_ТОЧКА]
  dictionary_set_link [типы], [ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК], [ТИП_ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК]
  dictionary_set_link [типы], [РАВНО], [ТИП_ПРИСВАИВАНИЕ]
  dictionary_set_link [типы], [ПЛЮС], [ТИП_СЛОЖЕНИЕ]
  dictionary_set_link [типы], [МИНУС], [ТИП_ВЫЧИТАНИЕ]
  dictionary_set_link [типы], [ЗВЁЗДОЧКА], [ТИП_УМНОЖЕНИЕ]
  dictionary_set_link [типы], [КОСАЯ_ЧЕРТА], [ТИП_ДЕЛЕНИЕ]
  dictionary_set_link [типы], [ОБРАТНАЯ_КОСАЯ_ЧЕРТА], [ТИП_ОБРАТНАЯ_КОСАЯ_ЧЕРТА]
  dictionary_set_link [типы], [ПЕРЕНОС_СТРОКИ], [ТИП_ПЕРЕНОС_СТРОКИ]
  dictionary_set_link [типы], [ТАБУЛЯЦИЯ], [ТИП_ТАБУЛЯЦИЯ]
  dictionary_set_link [типы], [ПРОБЕЛ], [ТИП_ПРОБЕЛ]

  list
  mov [ключевые_слова], rax

  string "и"
  mov [И], rax
  list_append_link [ключевые_слова], rax
  string "из"
  mov [ИЗ], rax
  list_append_link [ключевые_слова], rax
  string "от"
  mov [ОТ], rax
  list_append_link [ключевые_слова], rax
  string "до"
  mov [ДО], rax
  list_append_link [ключевые_слова], rax
  string "не"
  mov [НЕ], rax
  list_append_link [ключевые_слова], rax
  string "то"
  mov [ТО], rax
  list_append_link [ключевые_слова], rax
  string "или"
  mov [ИЛИ], rax
  list_append_link [ключевые_слова], rax
  string "при"
  mov [ПРИ], rax
  list_append_link [ключевые_слова], rax
  string "для"
  mov [ДЛЯ], rax
  list_append_link [ключевые_слова], rax
  string "если"
  mov [ЕСЛИ], rax
  list_append_link [ключевые_слова], rax
  string "ложь"
  mov [ЛОЖЬ], rax
  list_append_link [ключевые_слова], rax
  string "пока"
  mov [ПОКА], rax
  list_append_link [ключевые_слова], rax
  string "через"
  mov [ЧЕРЕЗ], rax
  list_append_link [ключевые_слова], rax
  string "класс"
  mov [КЛАСС], rax
  list_append_link [ключевые_слова], rax
  string "иначе"
  mov [ИНАЧЕ], rax
  list_append_link [ключевые_слова], rax
  string "истина"
  mov [ИСТИНА], rax
  list_append_link [ключевые_слова], rax
  string "вернуть"
  mov [ВЕРНУТЬ], rax
  list_append_link [ключевые_слова], rax
  string "удалить"
  mov [УДАЛИТЬ], rax
  list_append_link [ключевые_слова], rax
  string "функция"
  mov [ФУНКЦИЯ], rax
  list_append_link [ключевые_слова], rax
  string "прервать"
  mov [ПРЕРВАТЬ], rax
  list_append_link [ключевые_слова], rax
  string "включить"
  mov [ВКЛЮЧИТЬ], rax
  list_append_link [ключевые_слова], rax
  string "проверить"
  mov [ПРОВЕРИТЬ], rax
  list_append_link [ключевые_слова], rax
  string "пропустить"
  mov [ПРОПУСТИТЬ], rax
  list_append_link [ключевые_слова], rax

  string "тип"
  mov [тип], rax
  string "узел"
  mov [узел], rax
  string "значение"
  mov [значение], rax
  string "аргументы"
  mov [аргументы], rax
  string "переменная"
  mov [переменная], rax
  string "ключи"
  mov [ключи], rax
  string "левый_узел"
  mov [левый_узел], rax
  string "правый_узел"
  mov [правый_узел], rax
  string "оператор"
  mov [оператор], rax
  string "операнд"
  mov [операнд], rax
  string "элементы"
  mov [элементы], rax
  string "случаи"
  mov [случаи], rax
  string "случай_иначе"
  mov [случай_иначе], rax
  string "начало"
  mov [начало], rax
  string "конец"
  mov [конец], rax
  string "шаг"
  mov [шаг], rax
  string "тело"
  mov [тело], rax
  string "вернуть_нуль"
  mov [вернуть_нуль], rax
  string "условие"
  mov [условие], rax
  string "автовозвращение"
  mov [автовозвращение], rax
  string "имя_класса"
  mov [имя_класса], rax
  string "имя_объекта"
  mov [имя_объекта], rax
  string "родители"
  mov [родители], rax
  string "путь"
  mov [путь], rax
  string "имя_переменной"
  mov [имя_переменной], rax

  integer 1
  mov [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ], rax
  integer 2
  mov [УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ], rax
  integer 3
  mov [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ], rax
  integer 4
  mov [УЗЕЛ_СПИСКА], rax
  integer 5
  mov [УЗЕЛ_НУЛЬ], rax
  integer 6
  mov [УЗЕЛ_ЧИСЛА], rax
  integer 7
  mov [УЗЕЛ_СТРОКИ], rax
  integer 8
  mov [УЗЕЛ_ВЫЗОВА], rax
  integer 9
  mov [УЗЕЛ_УНАРНОЙ_ОПЕРАЦИИ], rax
  integer 10
  mov [УЗЕЛ_СЛОВАРЯ], rax
  integer 11
  mov [УЗЕЛ_ПРОВЕРКИ], rax
  integer 12
  mov [УЗЕЛ_ЕСЛИ], rax
  integer 13
  mov [УЗЕЛ_ДЛЯ], rax
  integer 14
  mov [УЗЕЛ_ПОКА], rax
  integer 15
  mov [УЗЕЛ_МЕТОДА], rax
  integer 16
  mov [УЗЕЛ_ФУНКЦИИ], rax
  integer 17
  mov [УЗЕЛ_КЛАССА], rax
  integer 18
  mov [УЗЕЛ_УДАЛЕНИЯ], rax
  integer 19
  mov [УЗЕЛ_ВКЛЮЧЕНИЯ], rax
  integer 20
  mov [УЗЕЛ_ВОЗВРАЩЕНИЯ], rax
  integer 21
  mov [УЗЕЛ_ПРОПУСКА], rax
  integer 22
  mov [УЗЕЛ_ПРЕРЫВАНИЯ], rax

  string "СЧЁТЧИК_ЕСЛИ"
  mov rcx, rax
  list
  mov rbx, rax
  integer 0
  assign rcx, rbx, rax

  string "СЧЁТЧИК_ЦИКЛОВ"
  mov rcx, rax
  list
  mov rbx, rax
  integer 0
  assign rcx, rbx, rax

  string "НОМЕР_ТЕКУЩЕГО_ЦИКЛА"
  mov rcx, rax
  list
  mov rbx, rax
  integer 0
  assign rcx, rbx, rax

  string "СЧЁТЧИК_ВЛОЖЕННОСТИ"
  mov rcx, rax
  list
  mov rbx, rax
  integer 0
  assign rcx, rbx, rax

  string "СЧЁТЧИК_ФУНКЦИЙ"
  mov rcx, rax
  list
  mov rbx, rax
  integer 0
  assign rcx, rbx, rax

  string "СЧЁТЧИК_ВЫЗОВОВ"
  mov rcx, rax
  list
  mov rbx, rax
  integer 0
  assign rcx, rbx, rax

  integer 2
  is_equal [ARGUMENTS_COUNT], rax
  boolean_value rax
  cmp rax, 1
  je .continue
    string <"Использование:", 10, "  korsakov <file.kors>">
    mov rbx, rax
    list
    list_append_link rax, rbx
    print rax
    exit -1

  .continue:

  integer 1
  list_get_link [ARGUMENTS], rax
  tokenizer rax
  mov [токены], rax
  ;list
  ;list_append_link rax, [токены]
  ;print rax

  ;string ""
  ;mov rbx, rax
  ;list_append_link rax, rbx
  ;print rax

  parser [токены]
  mov [АСД], rax
  ;list
  ;list_append_link rax, [АСД]
  ;print rax

  ;string ""
  ;mov rbx, rax
  ;list_append_link rax, rbx
  ;print rax

  compiler [АСД], [GLOBAL_CONTEXT]
  mov rbx, rax
  ;list
  ;list_append_link rax, rbx
  ;print rax

  string <"include 'core/korsakov.asm'", 10>
  mov rcx, rax

  string <"section 'start' executable", 10, "start:", 10>
  string_extend_links rcx, rax

  string_extend_links rcx, rbx

  string "exit 0"
  string_extend_links rcx, rax

  integer 1
  list_get_link [ARGUMENTS], rax
  split rax, "."
  mov rbx, rax
  integer 0
  list_get_link rbx, rax
  mov rbx, rax
  string ".asm"
  string_add_links rbx, rax

  open_file rax, O_WRONLY + O_CREAT + O_TRUNC, 644o
  write_file rax, rcx
  close_file rax

  list
  mov rcx, rax
  string "/bin/fasm"
  list_append_link rcx, rax
  string ".asm"
  string_add_links rbx, rax
  list_append_link rcx, rax
  run rcx, [ENVIRONMENT_VARIABLES]

  list
  mov rcx, rax
  string "/bin/ld"
  list_append_link rcx, rax
  string ".o"
  string_add_links rbx, rax
  list_append_link rcx, rax
  string "-o"
  list_append_link rcx, rax
  list_append_link rcx, rbx
  run rcx, [ENVIRONMENT_VARIABLES]

  exit 0
