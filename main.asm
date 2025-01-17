include "./core/korsakov.asm"

include "./nodes.asm"
include "./tokenizer.asm"
include "./parser.asm"
include "./compiler.asm"

section "data" writable
  заголовок      db 'include "core/korsakov.asm"', 10,           0
  сегмент_кода   db "section 'start' executable", 10, "start:", 0
  конец_кода     db "exit 0",                     10,           0

  файл_для_чтения db "привет, мир.корс", 0
  файл_для_записи db "привет, мир.asm", 0

  СРАВНЕНИЯ          rq 1
  АСД                rq 1
  КОЛИЧЕСТВО_СТРОК   rq 1

  INCORRECT_TOKEN_TYPE_ERROR db "Неверный токен:", 0
  INCORRECT_NODE             db "Неверный узел:", 0
  INVALID_NODE_TYPE          db "Неизвестный тип узла:", 0

  двойная_кавычка           db '"', 0
  ДВОЙНАЯ_КАВЫЧКА           rq 1
  открывающая_скобка        db "(", 0
  ОТКРЫВАЮЩАЯ_СКОБКА        rq 1
  закрывающая_скобка        db ")", 0
  ЗАКРЫВАЮЩАЯ_СКОБКА        rq 1
  двоеточие                 db ":", 0
  ДВОЕТОЧИЕ                 rq 1
  точка_с_запятой           db ";", 0
  ТОЧКА_С_ЗАПЯТОЙ           rq 1
  точка                     db ".", 0
  ТОЧКА                     rq 1
  восклицательный_знак      db "!", 0
  ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК      rq 1
  равно                     db "=", 0
  РАВНО                     rq 1
  плюс                      db "+", 0
  ПЛЮС                      rq 1
  минус                     db "-", 0
  МИНУС                     rq 1
  звёздочка                 db "*", 0
  ЗВЁЗДОЧКА                 rq 1
  косая_черта               db "/", 0
  КОСАЯ_ЧЕРТА               rq 1
  обратная_косая_черта      db "\\", 0
  ОБРАТНАЯ_КОСАЯ_ЧЕРТА      rq 1
  табуляция                 db 9, 0
  ТАБУЛЯЦИЯ                 rq 1
  перенос_строки            db 10, 0
  ПЕРЕНОС_СТРОКИ            rq 1
  пробел                    db " ", 0
  ПРОБЕЛ                    rq 1
  открывающая_скобка_списка db "%(", 0
  ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА rq 1
  закрывающая_скобка_списка db ")%", 0
  ЗАКРЫВАЮЩАЯ_СКОБКА_СПИСКА rq 1

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

  ТИП             db "тип", 0
  тип             rq 1
  УЗЕЛ            db "узел", 0
  узел            rq 1
  ЗНАЧЕНИЕ        db "значение", 0
  значение        rq 1
  АРГУМЕНТЫ       db "аргументы", 0
  аргументы       rq 1
  ПЕРЕМЕННАЯ      db "переменная", 0
  переменная      rq 1
  КЛЮЧИ           db "ключи", 0
  ключи           rq 1
  ЛЕВЫЙ_УЗЕЛ      db "левый_узел", 0
  левый_узел      rq 1
  ПРАВЫЙ_УЗЕЛ     db "правый_узел", 0
  правый_узел     rq 1
  ОПЕРАТОР        db "оператор", 0
  оператор        rq 1
  ОПЕРАНД         db "операнд", 0
  операнд         rq 1
  ЭЛЕМЕНТЫ        db "элементы", 0
  элементы        rq 1
  СЛУЧАИ          db "случаи", 0
  случаи          rq 1
  СЛУЧАЙ_ИНАЧЕ    db "случай_иначе", 0
  случай_иначе    rq 1
  НАЧАЛО          db "начало", 0
  начало          rq 1
  КОНЕЦ           db "конец", 0
  конец           rq 1
  ШАГ             db "шаг", 0
  шаг             rq 1
  ТЕЛО            db "тело", 0
  тело            rq 1
  ВЕРНУТЬ_НУЛЬ    db "вернуть_нуль", 0
  вернуть_нуль    rq 1
  УСЛОВИЕ         db "условие", 0
  условие         rq 1
  АВТОВОЗВРАЩЕНИЕ db "автовозвращение", 0
  автовозвращение rq 1
  ИМЯ_КЛАССА      db "имя_класса", 0
  имя_класса      rq 1
  ИМЯ_ОБЪЕКТА     db "имя_объекта", 0
  имя_объекта     rq 1
  РОДИТЕЛИ        db "родители", 0
  родители        rq 1
  ПУТЬ            db "путь", 0
  путь            rq 1
  ИМЯ_ПЕРЕМЕННОЙ  db "имя_переменной", 0
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

  тип_конец_файла          dq 0
  тип_идентификатор        dq 1
  тип_ключевое_слово       dq 2
  тип_открывающая_скобка   dq 3
  тип_закрывающая_скобка   dq 4
  тип_строка               dq 5
  тип_целое_число          dq 6
  тип_вещественное_число   dq 7
  тип_табуляция            dq 8
  тип_перенос_строки       dq 9
  тип_двоеточие            dq 10
  тип_точка_с_запятой      dq 11
  тип_точка                dq 12
  тип_восклицательный_знак dq 13
  тип_присваивание         dq 14
  тип_сложение             dq 15
  тип_вычитание            dq 16
  тип_умножение            dq 17
  тип_деление              dq 18
  тип_возведение_в_степень dq 19
  тип_изъятие_корня        dq 20
  тип_обратная_косая_черта dq 21
  тип_пробел               dq 22
  тип_равно                dq 23
  тип_не_равно             dq 24
  тип_больше               dq 25
  тип_меньше               dq 26
  тип_больше_или_равно     dq 27
  тип_меньше_или_равно     dq 28
  тип_инкрементация        dq 29
  тип_декрементация        dq 30
  тип_конец_конструкции    dq 31

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

  ТИП_КОНЕЦ_ФАЙЛА          rq 1
  ТИП_ИДЕНТИФИКАТОР        rq 1
  ТИП_КЛЮЧЕВОЕ_СЛОВО       rq 1
  ТИП_ОТКРЫВАЮЩАЯ_СКОБКА   rq 1
  ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА   rq 1
  ТИП_СТРОКА               rq 1
  ТИП_ЦЕЛОЕ_ЧИСЛО          rq 1
  ТИП_ВЕЩЕСТВЕННОЕ_ЧИСЛО   rq 1
  ТИП_ТАБУЛЯЦИЯ            rq 1
  ТИП_ПЕРЕНОС_СТРОКИ       rq 1
  ТИП_ДВОЕТОЧИЕ            rq 1
  ТИП_ТОЧКА_С_ЗАПЯТОЙ      rq 1
  ТИП_ТОЧКА                rq 1
  ТИП_ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК rq 1
  ТИП_ПРИСВАИВАНИЕ         rq 1
  ТИП_СЛОЖЕНИЕ             rq 1
  ТИП_ВЫЧИТАНИЕ            rq 1
  ТИП_УМНОЖЕНИЕ            rq 1
  ТИП_ДЕЛЕНИЕ              rq 1
  ТИП_ВОЗВЕДЕНИЕ_В_СТЕПЕНЬ rq 1
  ТИП_ИЗЪЯТИЕ_КОРНЯ        rq 1
  ТИП_ОБРАТНАЯ_КОСАЯ_ЧЕРТА rq 1
  ТИП_ПРОБЕЛ               rq 1
  ТИП_РАВНО                rq 1
  ТИП_НЕ_РАВНО             rq 1
  ТИП_БОЛЬШЕ               rq 1
  ТИП_МЕНЬШЕ               rq 1
  ТИП_БОЛЬШЕ_ИЛИ_РАВНО     rq 1
  ТИП_МЕНЬШЕ_ИЛИ_РАВНО     rq 1
  ТИП_ИНКРЕМЕНТАЦИЯ        rq 1
  ТИП_ДЕКРЕМЕНТАЦИЯ        rq 1
  ТИП_КОНЕЦ_КОНСТРУКЦИИ    rq 1

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
  integer 0
  mov [КОЛИЧЕСТВО_СТРОК], rax

  buffer_to_string двойная_кавычка
  mov [ДВОЙНАЯ_КАВЫЧКА], rax
  buffer_to_string открывающая_скобка
  mov [ОТКРЫВАЮЩАЯ_СКОБКА], rax
  buffer_to_string закрывающая_скобка
  mov [ЗАКРЫВАЮЩАЯ_СКОБКА], rax
  buffer_to_string двоеточие
  mov [ДВОЕТОЧИЕ], rax
  buffer_to_string точка_с_запятой
  mov [ТОЧКА_С_ЗАПЯТОЙ], rax
  buffer_to_string точка
  mov [ТОЧКА], rax
  buffer_to_string восклицательный_знак
  mov [ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК], rax
  buffer_to_string равно
  mov [РАВНО], rax
  buffer_to_string плюс
  mov [ПЛЮС], rax
  buffer_to_string минус
  mov [МИНУС], rax
  buffer_to_string звёздочка
  mov [ЗВЁЗДОЧКА], rax
  buffer_to_string косая_черта
  mov [КОСАЯ_ЧЕРТА], rax
  buffer_to_string обратная_косая_черта
  mov [ОБРАТНАЯ_КОСАЯ_ЧЕРТА], rax
  buffer_to_string табуляция
  mov [ТАБУЛЯЦИЯ], rax
  buffer_to_string перенос_строки
  mov [ПЕРЕНОС_СТРОКИ], rax
  buffer_to_string пробел
  mov [ПРОБЕЛ], rax
  buffer_to_string открывающая_скобка_списка
  mov [ОТКРЫВАЮЩАЯ_СКОБКА_СПИСКА], rax
  buffer_to_string закрывающая_скобка_списка
  mov [ЗАКРЫВАЮЩАЯ_СКОБКА_СПИСКА], rax

  dictionary
  mov rbx, rax

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

  mov [типы], rbx

  list
  list_append rax, [ТИП_РАВНО]
  list_append rax, [ТИП_НЕ_РАВНО]
  list_append rax, [ТИП_БОЛЬШЕ]
  list_append rax, [ТИП_МЕНЬШЕ]
  list_append rax, [ТИП_БОЛЬШЕ_ИЛИ_РАВНО]
  list_append rax, [ТИП_МЕНЬШЕ_ИЛИ_РАВНО]
  mov [СРАВНЕНИЯ], rax

  dictionary_set rbx, [ОТКРЫВАЮЩАЯ_СКОБКА], [ТИП_ОТКРЫВАЮЩАЯ_СКОБКА]
  dictionary_set rbx, [ЗАКРЫВАЮЩАЯ_СКОБКА], [ТИП_ЗАКРЫВАЮЩАЯ_СКОБКА]
  dictionary_set rbx, [ДВОЕТОЧИЕ], [ТИП_ДВОЕТОЧИЕ]
  dictionary_set rbx, [ТОЧКА_С_ЗАПЯТОЙ], [ТИП_ТОЧКА_С_ЗАПЯТОЙ]
  dictionary_set rbx, [ТОЧКА], [ТИП_ТОЧКА]
  dictionary_set rbx, [ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК], [ТИП_ВОСКЛИЦАТЕЛЬНЫЙ_ЗНАК]
  dictionary_set rbx, [РАВНО], [ТИП_ПРИСВАИВАНИЕ]
  dictionary_set rbx, [ПЛЮС], [ТИП_СЛОЖЕНИЕ]
  dictionary_set rbx, [МИНУС], [ТИП_ВЫЧИТАНИЕ]
  dictionary_set rbx, [ЗВЁЗДОЧКА], [ТИП_УМНОЖЕНИЕ]
  dictionary_set rbx, [КОСАЯ_ЧЕРТА], [ТИП_ДЕЛЕНИЕ]
  dictionary_set rbx, [ОБРАТНАЯ_КОСАЯ_ЧЕРТА], [ТИП_ОБРАТНАЯ_КОСАЯ_ЧЕРТА]
  dictionary_set rbx, [ПЕРЕНОС_СТРОКИ], [ТИП_ПЕРЕНОС_СТРОКИ]
  dictionary_set rbx, [ТАБУЛЯЦИЯ], [ТИП_ТАБУЛЯЦИЯ]
  dictionary_set rbx, [ПРОБЕЛ], [ТИП_ПРОБЕЛ]

  list
  mov rbx, rax

  buffer_to_string и
  mov [И], rax
  list_append rbx, rax
  buffer_to_string из
  mov [ИЗ], rax
  list_append rbx, rax
  buffer_to_string от
  mov [ОТ], rax
  list_append rbx, rax
  buffer_to_string до
  mov [ДО], rax
  list_append rbx, rax
  buffer_to_string не
  mov [НЕ], rax
  list_append rbx, rax
  buffer_to_string то
  mov [ТО], rax
  list_append rbx, rax
  buffer_to_string или
  mov [ИЛИ], rax
  list_append rbx, rax
  buffer_to_string при
  mov [ПРИ], rax
  list_append rbx, rax
  buffer_to_string для
  mov [ДЛЯ], rax
  list_append rbx, rax
  buffer_to_string если
  mov [ЕСЛИ], rax
  list_append rbx, rax
  buffer_to_string ложь
  mov [ЛОЖЬ], rax
  list_append rbx, rax
  buffer_to_string пока
  mov [ПОКА], rax
  list_append rbx, rax
  buffer_to_string через
  mov [ЧЕРЕЗ], rax
  list_append rbx, rax
  buffer_to_string класс
  mov [КЛАСС], rax
  list_append rbx, rax
  buffer_to_string иначе
  mov [ИНАЧЕ], rax
  list_append rbx, rax
  buffer_to_string истина
  mov [ИСТИНА], rax
  list_append rbx, rax
  buffer_to_string вернуть
  mov [ВЕРНУТЬ], rax
  list_append rbx, rax
  buffer_to_string удалить
  mov [УДАЛИТЬ], rax
  list_append rbx, rax
  buffer_to_string функция
  mov [ФУНКЦИЯ], rax
  list_append rbx, rax
  buffer_to_string прервать
  mov [ПРЕРВАТЬ], rax
  list_append rbx, rax
  buffer_to_string включить
  mov [ВКЛЮЧИТЬ], rax
  list_append rbx, rax
  buffer_to_string проверить
  mov [ПРОВЕРИТЬ], rax
  list_append rbx, rax
  buffer_to_string пропустить
  mov [ПРОПУСТИТЬ], rax
  list_append rbx, rax

  mov [ключевые_слова], rbx

  buffer_to_string ТИП
  mov [тип], rax
  buffer_to_string УЗЕЛ
  mov [узел], rax
  buffer_to_string ЗНАЧЕНИЕ
  mov [значение], rax
  buffer_to_string АРГУМЕНТЫ
  mov [аргументы], rax
  buffer_to_string ПЕРЕМЕННАЯ
  mov [переменная], rax
  buffer_to_string КЛЮЧИ
  mov [ключи], rax
  buffer_to_string ЛЕВЫЙ_УЗЕЛ
  mov [левый_узел], rax
  buffer_to_string ПРАВЫЙ_УЗЕЛ
  mov [правый_узел], rax
  buffer_to_string ОПЕРАТОР
  mov [оператор], rax
  buffer_to_string ОПЕРАНД
  mov [операнд], rax
  buffer_to_string ЭЛЕМЕНТЫ
  mov [элементы], rax
  buffer_to_string СЛУЧАИ
  mov [случаи], rax
  buffer_to_string СЛУЧАЙ_ИНАЧЕ
  mov [случай_иначе], rax
  buffer_to_string НАЧАЛО
  mov [начало], rax
  buffer_to_string КОНЕЦ
  mov [конец], rax
  buffer_to_string ШАГ
  mov [шаг], rax
  buffer_to_string ТЕЛО
  mov [тело], rax
  buffer_to_string ВЕРНУТЬ_НУЛЬ
  mov [вернуть_нуль], rax
  buffer_to_string УСЛОВИЕ
  mov [условие], rax
  buffer_to_string АВТОВОЗВРАЩЕНИЕ
  mov [автовозвращение], rax
  buffer_to_string ИМЯ_КЛАССА
  mov [имя_класса], rax
  buffer_to_string ИМЯ_ОБЪЕКТА
  mov [имя_объекта], rax
  buffer_to_string РОДИТЕЛИ
  mov [родители], rax
  buffer_to_string ПУТЬ
  mov [путь], rax
  buffer_to_string ИМЯ_ПЕРЕМЕННОЙ
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

  ;print [пустая_строка]

  parser [токены]
  mov [АСД], rax
  ;print [АСД]

  ;print [пустая_строка]

  compiler [АСД], [GLOBAL_CONTEXT]
  ;print rax

  mov rbx, rax

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
