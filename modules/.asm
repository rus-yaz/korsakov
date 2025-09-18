macro init_ {
  arguments "аргументы*", "разделитель", "конец_строки"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "разделитель"
  mov rbx, rax
  string " "
  dictionary_set_link rcx, rbx, rax
  string "конец_строки"
  mov rbx, rax
  string 10
  dictionary_set_link rcx, rbx, rax

  string "показать"
  mov rbx, rax
  function rbx, f_print, rdx, rcx, 1, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  arguments "аргументы*", "разделитель", "конец_строки"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "разделитель"
  mov rbx, rax
  string " "
  dictionary_set_link rcx, rbx, rax
  string "конец_строки"
  mov rbx, rax
  string 10
  dictionary_set_link rcx, rbx, rax

  string "ошибка"
  mov rbx, rax
  function rbx, f_error, rdx, rcx, 1, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  arguments "строка"
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "ввод"
  mov rbx, rax
  function rbx, f_input, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  arguments "список*", "объединитель"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "объединитель"
  mov rbx, rax
  string " "
  dictionary_set_link rcx, rbx, rax

  string "объединить"
  mov rbx, rax
  function rbx, f_join, rdx, rcx, 1, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  arguments "строка", "разделитель", "количество_частей"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "разделитель"
  mov rbx, rax
  string " "
  dictionary_set_link rcx, rbx, rax
  string "количество_частей"
  mov rbx, rax
  integer -1
  dictionary_set_link rcx, rbx, rax

  string "разделить"
  mov rbx, rax
  function rbx, f_split, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  arguments "нижний_порог", "верхний_порог"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "нижний_порог"
  mov rbx, rax
  integer 0
  dictionary_set_link rcx, rbx, rax
  string "верхний_порог"
  mov rbx, rax
  push rbx, rdx
  mov rax, -1
  mov rbx, 2
  mov rdx, 0
  idiv rbx
  integer rax
  pop rdx, rbx
  dictionary_set_link rcx, rbx, rax

  string "получить_случайное_число"
  mov rbx, rax
  function rbx, f_get_random, rdx, rcx, 1, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  arguments "нижний_порог", "верхний_порог"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "нижний_порог"
  mov rbx, rax
  integer 0
  dictionary_set_link rcx, rbx, rax
  string "верхний_порог"
  mov rbx, rax
  push rbx, rdx
  mov rax, -1
  mov rbx, 2
  mov rdx, 0
  idiv rbx
  integer rax
  pop rdx, rbx
  dictionary_set_link rcx, rbx, rax

  string "получить_псевдослучайное_число"
  mov rbx, rax
  function rbx, f_get_pseudorandom, rdx, rcx, 1, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  arguments "семя"
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "установить_семя"
  mov rbx, rax
  function rbx, f_set_seed, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  list
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "сбросить_семя"
  mov rbx, rax
  function rbx, f_reset_seed, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  arguments "число"
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "факториал"
  mov rbx, rax
  function rbx, f_factorial, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx


  arguments "степень"
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "степень_эйлера_тейлор"
  mov rbx, rax
  function rbx, f_euler_power_taylor, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  arguments "степень"
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "степень_эйлера"
  mov rbx, rax
  function rbx, f_euler_power, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx

  list
  mov rdx, rax
  dictionary
  mov rcx, rax
  string "амогус"
  mov rbx, rax
  function rbx, f_amogus, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
}

_function amogus, rax
  raw_string "         ______________       ", 10
  print_raw rax
  raw_string "        /              \      ", 10
  print_raw rax
  raw_string "       /                \     ", 10
  print_raw rax
  raw_string "      /          __________   ", 10
  print_raw rax
  raw_string "      |         /          \  ", 10
  print_raw rax
  raw_string "  ____|        /            \ ", 10
  print_raw rax
  raw_string " /    |        \            / ", 10
  print_raw rax
  raw_string " |    |         \__________/  ", 10
  print_raw rax
  raw_string " |    |                 |     ", 10
  print_raw rax
  raw_string " |    |                 |     ", 10
  print_raw rax
  raw_string " |    |                 |     ", 10
  print_raw rax
  raw_string " |    |                 |     ", 10
  print_raw rax
  raw_string " \____|                 |     ", 10
  print_raw rax
  raw_string "      |      _____      |     ", 10
  print_raw rax
  raw_string "      |     /     \     |     ", 10
  print_raw rax
  raw_string "      |     |     |     |     ", 10
  print_raw rax
  raw_string "      |     |     |     |     ", 10
  print_raw rax
  raw_string "      \_____/     \_____/     ", 10
  print_raw rax
  ret
