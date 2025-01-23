include "./core/korsakov.asm"

include "./token.asm"
include "./nodes.asm"
include "./tokenizer.asm"
include "./parser.asm"
include "./compiler.asm"

section "data" writable
  заголовок      db 'include "core/korsakov.asm"', 10,          0
  сегмент_кода   db "section 'start' executable", 10, "start:", 0
  конец_кода     db "exit 0",                     10,           0

  файл_для_чтения db "привет, мир.корс", 0
  файл_для_записи db "привет, мир.asm", 0

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

  и          db "и", 0
  И          rq 1
  из         db "из", 0
  ИЗ         rq 1
  от         db "от", 0
  ОТ         rq 1
  до         db "до", 0
  ДО         rq 1
  не         db "не", 0
  НЕ         rq 1
  то         db "то", 0
  ТО         rq 1
  или        db "или", 0
  ИЛИ        rq 1
  при        db "при", 0
  ПРИ        rq 1
  для        db "для", 0
  ДЛЯ        rq 1
  если       db "если", 0
  ЕСЛИ       rq 1
  ложь       db "ложь", 0
  ЛОЖЬ       rq 1
  пока       db "пока", 0
  ПОКА       rq 1
  через      db "через", 0
  ЧЕРЕЗ      rq 1
  класс      db "класс", 0
  КЛАСС      rq 1
  иначе      db "иначе", 0
  ИНАЧЕ      rq 1
  истина     db "истина", 0
  ИСТИНА     rq 1
  вернуть    db "вернуть", 0
  ВЕРНУТЬ    rq 1
  удалить    db "удалить", 0
  УДАЛИТЬ    rq 1
  функция    db "функция", 0
  ФУНКЦИЯ    rq 1
  прервать   db "прервать", 0
  ПРЕРВАТЬ   rq 1
  включить   db "включить", 0
  ВКЛЮЧИТЬ   rq 1
  проверить  db "проверить", 0
  ПРОВЕРИТЬ  rq 1
  пропустить db "пропустить", 0
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
  данные         rq 1
  индекс         rq 1
  токены         rq 1
  символы        rq 1
  тип_токена     rq 1
  ключевые_слова rq 1

  тип_конец_файла               dq 0
  тип_идентификатор             dq 1
  тип_ключевое_слово            dq 2
  тип_открывающая_скобка        dq 3
  тип_закрывающая_скобка        dq 4
  тип_открывающая_скобка_списка dq 5
  тип_строка                    dq 6
  тип_целое_число               dq 7
  тип_вещественное_число        dq 8
  тип_табуляция                 dq 9
  тип_перенос_строки            dq 10
  тип_двоеточие                 dq 11
  тип_точка_с_запятой           dq 12
  тип_точка                     dq 13
  тип_восклицательный_знак      dq 14
  тип_присваивание              dq 15
  тип_сложение                  dq 16
  тип_вычитание                 dq 17
  тип_умножение                 dq 18
  тип_деление                   dq 19
  тип_возведение_в_степень      dq 20
  тип_изъятие_корня             dq 21
  тип_обратная_косая_черта      dq 22
  тип_пробел                    dq 23
  тип_равно                     dq 24
  тип_не_равно                  dq 25
  тип_больше                    dq 26
  тип_меньше                    dq 27
  тип_больше_или_равно          dq 28
  тип_меньше_или_равно          dq 29
  тип_инкрементация             dq 30
  тип_декрементация             dq 31
  тип_конец_конструкции         dq 32

  узел_доступа_к_переменной    dq 1
  узел_бинарной_операции       dq 2
  узел_присваивания_переменной dq 3
  узел_списка                  dq 4
  узел_числа                   dq 5
  узел_строки                  dq 6
  узел_вызова                  dq 7
  узел_унарной_операции        dq 8
  узел_словаря                 dq 9
  узел_проверки                dq 10
  узел_если                    dq 11
  узел_для                     dq 12
  узел_пока                    dq 13
  узел_метода                  dq 14
  узел_функции                 dq 15
  узел_класса                  dq 16
  узел_удаления                dq 17
  узел_включения               dq 18
  узел_возвращения             dq 19
  узел_пропуска                dq 20
  узел_прерывания              dq 21

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
  ТИП_ИЗЪЯТИЕ_КОРНЯ             rq 1
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

  integer [тип_конец_файла]
  mov [ТИП_КОНЕЦ_ФАЙЛА], rax
  integer [тип_идентификатор]
  mov [ТИП_ИДЕНТИФИКАТОР], rax
  integer [тип_ключевое_слово]
  mov [ТИП_КЛЮЧЕВОЕ_СЛОВО], rax
  integer [тип_открывающая_скобка]
  mov [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА], rax
  integer [тип_закрывающая_скобка]
  mov [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА], rax
  integer [тип_открывающая_скобка_списка]
  mov [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА], rax
  integer [тип_строка]
  mov [ТИП_СТРОКА], rax
  integer [тип_целое_число]
  mov [ТИП_ЦЕЛОЕ_ЧИСЛО], rax
  integer [тип_вещественное_число]
  mov [ТИП_ВЕЩЕСТВЕННОЕ_ЧИСЛО], rax
  integer [тип_перенос_строки]
  mov [ТИП_ПЕРЕНОС_СТРОКИ], rax
  integer [тип_табуляция]
  mov [ТИП_ТАБУЛЯЦИЯ], rax
  integer [тип_двоеточие]
  mov [ТИП_ДВОЕТОЧИЕ], rax
  integer [тип_точка_с_запятой]
  mov [ТИП_ТОЧКА_С_ЗАПЯТОЙ], rax
  integer [тип_точка]
  mov [ТИП_ТОЧКА], rax
  integer [тип_восклицательный_знак]
  mov [ТИП_ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК], rax
  integer [тип_присваивание]
  mov [ТИП_ПРИСВАИВАНИЕ], rax
  integer [тип_сложение]
  mov [ТИП_СЛОЖЕНИЕ], rax
  integer [тип_вычитание]
  mov [ТИП_ВЫЧИТАНИЕ], rax
  integer [тип_умножение]
  mov [ТИП_УМНОЖЕНИЕ], rax
  integer [тип_деление]
  mov [ТИП_ДЕЛЕНИЕ], rax
  integer [тип_возведение_в_степень]
  mov [ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ], rax
  integer [тип_изъятие_корня]
  mov [ТИП_ИЗЪЯТИЕ_КОРНЯ], rax
  integer [тип_обратная_косая_черта]
  mov [ТИП_ОБРАТНАЯ_КОСАЯ_ЧЕРТА], rax
  integer [тип_пробел]
  mov [ТИП_ПРОБЕЛ], rax
  integer [тип_равно]
  mov [ТИП_РАВНО], rax
  integer [тип_не_равно]
  mov [ТИП_НЕ_РАВНО], rax
  integer [тип_больше]
  mov [ТИП_БОЛЬШЕ], rax
  integer [тип_меньше]
  mov [ТИП_МЕНЬШЕ], rax
  integer [тип_больше_или_равно]
  mov [ТИП_БОЛЬШЕ_ИЛИ_РАВНО], rax
  integer [тип_меньше_или_равно]
  mov [ТИП_МЕНЬШЕ_ИЛИ_РАВНО], rax
  integer [тип_инкрементация]
  mov [ТИП_ИНКРЕМЕНТАЦИЯ], rax
  integer [тип_декрементация]
  mov [ТИП_ДЕКРЕМЕНТАЦИЯ], rax
  integer [тип_конец_конструкции]
  mov [ТИП_КОНЕЦ_КОНСТРУКЦИИ], rax

  list
  list_append rax, [ТИП_РАВНО]
  list_append rax, [ТИП_НЕ_РАВНО]
  list_append rax, [ТИП_БОЛЬШЕ]
  list_append rax, [ТИП_МЕНЬШЕ]
  list_append rax, [ТИП_БОЛЬШЕ_ИЛИ_РАВНО]
  list_append rax, [ТИП_МЕНЬШЕ_ИЛИ_РАВНО]
  mov [СРАВНЕНИЯ], rax

  dictionary
  mov [типы], rax

  dictionary_set [типы], [ОТКРЫВАЮЩАЯ_СКОБКА], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]
  dictionary_set [типы], [ЗАКРЫВАЮЩАЯ_СКОБКА], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  dictionary_set [типы], [ДВОЕТОЧИЕ], [ТИП_ДВОЕТОЧИЕ]
  dictionary_set [типы], [ТОЧКА_С_ЗАПЯТОЙ], [ТИП_ТОЧКА_С_ЗАПЯТОЙ]
  dictionary_set [типы], [ТОЧКА], [ТИП_ТОЧКА]
  dictionary_set [типы], [ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК], [ТИП_ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК]
  dictionary_set [типы], [РАВНО], [ТИП_ПРИСВАИВАНИЕ]
  dictionary_set [типы], [ПЛЮС], [ТИП_СЛОЖЕНИЕ]
  dictionary_set [типы], [МИНУС], [ТИП_ВЫЧИТАНИЕ]
  dictionary_set [типы], [ЗВЁЗДОЧКА], [ТИП_УМНОЖЕНИЕ]
  dictionary_set [типы], [КОСАЯ_ЧЕРТА], [ТИП_ДЕЛЕНИЕ]
  dictionary_set [типы], [ОБРАТНАЯ_КОСАЯ_ЧЕРТА], [ТИП_ОБРАТНАЯ_КОСАЯ_ЧЕРТА]
  dictionary_set [типы], [ПЕРЕНОС_СТРОКИ], [ТИП_ПЕРЕНОС_СТРОКИ]
  dictionary_set [типы], [ТАБУЛЯЦИЯ], [ТИП_ТАБУЛЯЦИЯ]
  dictionary_set [типы], [ПРОБЕЛ], [ТИП_ПРОБЕЛ]

  list
  mov [ключевые_слова], rax

  buffer_to_string и
  mov [И], rax
  list_append [ключевые_слова], rax
  buffer_to_string из
  mov [ИЗ], rax
  list_append [ключевые_слова], rax
  buffer_to_string от
  mov [ОТ], rax
  list_append [ключевые_слова], rax
  buffer_to_string до
  mov [ДО], rax
  list_append [ключевые_слова], rax
  buffer_to_string не
  mov [НЕ], rax
  list_append [ключевые_слова], rax
  buffer_to_string то
  mov [ТО], rax
  list_append [ключевые_слова], rax
  buffer_to_string или
  mov [ИЛИ], rax
  list_append [ключевые_слова], rax
  buffer_to_string при
  mov [ПРИ], rax
  list_append [ключевые_слова], rax
  buffer_to_string для
  mov [ДЛЯ], rax
  list_append [ключевые_слова], rax
  buffer_to_string если
  mov [ЕСЛИ], rax
  list_append [ключевые_слова], rax
  buffer_to_string ложь
  mov [ЛОЖЬ], rax
  list_append [ключевые_слова], rax
  buffer_to_string пока
  mov [ПОКА], rax
  list_append [ключевые_слова], rax
  buffer_to_string через
  mov [ЧЕРЕЗ], rax
  list_append [ключевые_слова], rax
  buffer_to_string класс
  mov [КЛАСС], rax
  list_append [ключевые_слова], rax
  buffer_to_string иначе
  mov [ИНАЧЕ], rax
  list_append [ключевые_слова], rax
  buffer_to_string истина
  mov [ИСТИНА], rax
  list_append [ключевые_слова], rax
  buffer_to_string вернуть
  mov [ВЕРНУТЬ], rax
  list_append [ключевые_слова], rax
  buffer_to_string удалить
  mov [УДАЛИТЬ], rax
  list_append [ключевые_слова], rax
  buffer_to_string функция
  mov [ФУНКЦИЯ], rax
  list_append [ключевые_слова], rax
  buffer_to_string прервать
  mov [ПРЕРВАТЬ], rax
  list_append [ключевые_слова], rax
  buffer_to_string включить
  mov [ВКЛЮЧИТЬ], rax
  list_append [ключевые_слова], rax
  buffer_to_string проверить
  mov [ПРОВЕРИТЬ], rax
  list_append [ключевые_слова], rax
  buffer_to_string пропустить
  mov [ПРОПУСТИТЬ], rax
  list_append [ключевые_слова], rax

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

  integer [узел_доступа_к_переменной]
  mov [УЗЕЛ_ДОСТУПА_К_ПЕРЕМЕННОЙ], rax
  integer [узел_бинарной_операции]
  mov [УЗЕЛ_БИНАРНОЙ_ОПЕРАЦИИ], rax
  integer [узел_присваивания_переменной]
  mov [УЗЕЛ_ПРИСВАИВАНИЯ_ПЕРЕМЕННОЙ], rax
  integer [узел_списка]
  mov [УЗЕЛ_СПИСКА], rax
  integer [узел_числа]
  mov [УЗЕЛ_ЧИСЛА], rax
  integer [узел_строки]
  mov [УЗЕЛ_СТРОКИ], rax
  integer [узел_вызова]
  mov [УЗЕЛ_ВЫЗОВА], rax
  integer [узел_унарной_операции]
  mov [УЗЕЛ_УНАРНОЙ_ОПЕРАЦИИ], rax
  integer [узел_если]
  mov [УЗЕЛ_ЕСЛИ], rax
  integer [узел_словаря]
  mov [УЗЕЛ_СЛОВАРЯ], rax
  integer [узел_проверки]
  mov [УЗЕЛ_ПРОВЕРКИ], rax
  integer [узел_для]
  mov [УЗЕЛ_ДЛЯ], rax
  integer [узел_пока]
  mov [УЗЕЛ_ПОКА], rax
  integer [узел_метода]
  mov [УЗЕЛ_МЕТОДА], rax
  integer [узел_функции]
  mov [УЗЕЛ_ФУНКЦИИ], rax
  integer [узел_класса]
  mov [УЗЕЛ_КЛАССА], rax
  integer [узел_удаления]
  mov [УЗЕЛ_УДАЛЕНИЯ], rax
  integer [узел_включения]
  mov [УЗЕЛ_ВКЛЮЧЕНИЯ], rax
  integer [узел_возвращения]
  mov [УЗЕЛ_ВОЗВРАЩЕНИЯ], rax

  tokenizer файл_для_чтения
  mov [токены], rax
  ;print [токены]

  ;string ""
  ;print rax

  parser [токены]
  mov [АСД], rax
  ;print [АСД]

  ;string ""
  ;print rax

  compiler [АСД], [GLOBAL_CONTEXT]
  mov rbx, rax
  ;print rbx

  list
  mov rcx, rax

  buffer_to_string заголовок
  list_append rcx, rax

  buffer_to_string сегмент_кода
  list_append rcx, rax

  list_append rcx, rbx

  buffer_to_string конец_кода
  list_append rcx, rax

  join rcx, 10
  mov [код], rax

  open_file файл_для_записи, O_WRONLY + O_CREAT + O_TRUNC, 644o
  write_file rax, [код]
  close_file rax

  exit 0
