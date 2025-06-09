; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная

macro init_терминал {
  list
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "звонок"
  mov rbx, rax
  function rbx, f_bell, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "заголовок"
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "установить_заголовок"
  mov rbx, rax
  function rbx, f_set_title, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "шаг"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "шаг"
  mov rbx, rax
  integer 1
  dictionary_set_link rcx, rbx, rax

  string "сдвинуть_курсор_вверх"
  mov rbx, rax
  function rbx, f_move_cursor_up, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "шаг"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "шаг"
  mov rbx, rax
  integer 1
  dictionary_set_link rcx, rbx, rax

  string "сдвинуть_курсор_вниз"
  mov rbx, rax
  function rbx, f_move_cursor_down, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "шаг"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "шаг"
  mov rbx, rax
  integer 1
  dictionary_set_link rcx, rbx, rax

  string "сдвинуть_курсор_влево"
  mov rbx, rax
  function rbx, f_move_cursor_left, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "шаг"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "шаг"
  mov rbx, rax
  integer 1
  dictionary_set_link rcx, rbx, rax

  string "сдвинуть_курсор_вправо"
  mov rbx, rax
  function rbx, f_move_cursor_right, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "шаг"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "шаг"
  mov rbx, rax
  integer 1
  dictionary_set_link rcx, rbx, rax

  string "сдвинуть_курсор_вниз_к_началу_строки"
  mov rbx, rax
  function rbx, f_move_cursor_down_to_line_start, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "шаг"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "шаг"
  mov rbx, rax
  integer 1
  dictionary_set_link rcx, rbx, rax

  string "сдвинуть_курсор_вверх_к_началу_строки"
  mov rbx, rax
  function rbx, f_move_cursor_up_to_line_start, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "столбец"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "столбец"
  mov rbx, rax
  integer 1
  dictionary_set_link rcx, rbx, rax

  string "установить_горизонтальное_положение_курсора"
  mov rbx, rax
  function rbx, f_set_cursor_horizontal_position, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "строка", "столбец"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "строка"
  mov rbx, rax
  integer 1
  dictionary_set_link rcx, rbx, rax
  string "столбец"
  mov rbx, rax
  integer 1
  dictionary_set_link rcx, rbx, rax

  string "установить_положение_курсора"
  mov rbx, rax
  function rbx, f_set_cursor_position, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "очистить_буфер_после_курсора"
  mov rbx, rax
  function rbx, f_clear_buffer_after_cursor, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "очистить_буфер_до_курсора"
  mov rbx, rax
  function rbx, f_clear_buffer_before_cursor, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "очистить_буфер_экрана"
  mov rbx, rax
  function rbx, f_clear_screen_buffer, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "очистить_буфер_прокрутки"
  mov rbx, rax
  function rbx, f_clear_scroll_buffer, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "до_курсора", "после_курсора", "буфер_прокрутки"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "до_курсора"
  mov rbx, rax
  boolean 1
  dictionary_set_link rcx, rbx, rax
  string "после_курсора"
  mov rbx, rax
  boolean 1
  dictionary_set_link rcx, rbx, rax
  string "буфер_прокрутки"
  mov rbx, rax
  boolean 1
  dictionary_set_link rcx, rbx, rax

  string "очистить_буфер"
  mov rbx, rax
  function rbx, f_clear_buffer, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "очистить_строку_после_курсора"
  mov rbx, rax
  function rbx, f_clear_line_after_cursor, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "очистить_строку_до_курсора"
  mov rbx, rax
  function rbx, f_clear_line_before_cursor, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  list
  mov rdx, rax

  dictionary
  mov rcx, rax

  string "очистить_текущую_строку"
  mov rbx, rax
  function rbx, f_clear_current_line, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax

  arguments "до_курсора", "после_курсора"
  mov rdx, rax

  dictionary
  mov rcx, rax
  string "до_курсора"
  mov rbx, rax
  boolean 1
  dictionary_set_link rcx, rbx, rax
  string "после_курсора"
  mov rbx, rax
  boolean 1
  dictionary_set_link rcx, rbx, rax

  string "очистить_строку"
  mov rbx, rax
  function rbx, f_clear_line, rdx, rcx, 0, 1
  mov rcx, rax
  list
  assign rbx, rax, rcx
  mov rcx, rax
}

macro print_ansi_sequence sequence {
  raw_string <27, sequence>
  print_raw rax
}

macro bell {
  enter

  call f_bell

  leave
}

macro set_cursor_up step = 0 {
  enter step

  call f_set_cursor_up

  leave
}

macro set_cursor_down step = 0 {
  enter step

  call f_set_cursor_down

  leave
}

macro set_cursor_right step = 0 {
  enter step

  call f_set_cursor_right

  leave
}

macro set_cursor_left step = 0 {
  enter step

  call f_set_cursor_left

  leave
}

macro move_cursor_down_to_line_start step = 0 {
  enter step

  call f_move_cursor_down_to_line_start

  leave
}

macro move_cursor_up_to_line_start step = 0 {
  enter step

  call f_move_cursor_up_to_line_start

  leave
}

macro set_cursor_horizontal_position column = 0 {
  enter column

  call f_set_cursor_horizontal_position

  leave
}

macro set_cursor_position row = 0, column = 0 {
  enter row, column

  call f_set_cursor_position

  leave
}

macro clear_buffer_after_cursor {
  enter

  call f_clear_buffer_after_cursor

  leave
}

macro clear_buffer_before_cursor {
  enter

  call f_clear_buffer_before_cursor

  leave
}

macro clear_screen_buffer {
  enter

  call f_clear_screen_buffer

  leave
}

macro clear_scroll_buffer after = 0, before = 0, scroll = 0 {
  enter after, before, scroll

  call f_clear_scroll_buffer

  leave
}

macro clear_line_after_cursor {
  enter

  call f_clear_line_after_cursor

  leave
}

macro clear_line_before_cursor {
  enter

  call f_clear_line_before_cursor

  leave
}

macro clear_current_line {
  enter

  call f_clear_current_line

  leave
}

macro clear_line after = 0, before = 0 {
  enter after, before

  call f_clear_line

  leave
}

f_bell:
  raw_string 7
  print_raw rax

  null
  ret

f_set_title:
  get_arg 0
  mov rbx, rax
  check_type rbx, STRING

  print_ansi_sequence "]2"

  cmp rbx, 0
  je @f
    string_to_binary rbx
    print_binary rax
  @@:

  bell

  null
  ret

f_move_cursor_up:
  get_arg 0
  mov rbx, rax
  check_type rbx, INTEGER

  print_ansi_sequence "["

  cmp rbx, 0
  je @f
    to_string rbx
    string_to_binary rax
    print_binary rax
  @@:

  raw_string "A"
  print_raw rax

  null
  ret

f_move_cursor_down:
  get_arg 0
  mov rbx, rax
  check_type rbx, INTEGER

  print_ansi_sequence "["

  cmp rbx, 0
  je @f
    to_string rbx
    string_to_binary rax
    print_binary rax
  @@:

  raw_string "B"
  print_raw rax

  null
  ret

f_move_cursor_right:
  get_arg 0
  mov rbx, rax
  check_type rbx, INTEGER

  print_ansi_sequence "["

  cmp rbx, 0
  je @f
    to_string rbx
    string_to_binary rax
    print_binary rax
  @@:

  raw_string "C"
  print_raw rax

  null
  ret

f_move_cursor_left:
  get_arg 0
  mov rbx, rax
  check_type rbx, INTEGER

  print_ansi_sequence "["

  cmp rbx, 0
  je @f
    to_string rbx
    string_to_binary rax
    print_binary rax
  @@:

  raw_string "D"
  print_raw rax

  null
  ret

f_move_cursor_down_to_line_start:
  get_arg 0
  mov rbx, rax
  check_type rbx, INTEGER

  print_ansi_sequence "["

  cmp rbx, 0
  je @f
    to_string rbx
    string_to_binary rax
    print_binary rax
  @@:

  raw_string "E"
  print_raw rax

  null
  ret

f_move_cursor_up_to_line_start:
  get_arg 0
  mov rbx, rax
  check_type rbx, INTEGER

  print_ansi_sequence "["

  cmp rbx, 0
  je @f
    to_string rbx
    string_to_binary rax
    print_binary rax
  @@:

  raw_string "F"
  print_raw rax

  null
  ret

f_set_cursor_horizontal_position:
  get_arg 0
  mov rbx, rax
  check_type rbx, INTEGER

  print_ansi_sequence "["

  cmp rbx, 0
  je @f
    to_string rbx
    string_to_binary rax
    print_binary rax
  @@:

  raw_string "G"
  print_raw rax

  null
  ret

f_set_cursor_position:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax

  check_type rbx, INTEGER
  check_type rcx, INTEGER

  print_ansi_sequence "["

  cmp rbx, 0
  je @f
    to_string rbx
    string_to_binary rax
    print_binary rax
  @@:

  raw_string ";"
  print_raw rax

  cmp rcx, 0
  je @f
    to_string rcx
    string_to_binary rax
    print_binary rax
  @@:

  raw_string "H"
  print_raw rax

  null
  ret

f_clear_buffer_after_cursor:
  print_ansi_sequence "[0J"

  null
  ret

f_clear_buffer_before_cursor:
  print_ansi_sequence "[1J"

  null
  ret

f_clear_screen_buffer:
  print_ansi_sequence "[2J"

  null
  ret

f_clear_scroll_buffer:
  print_ansi_sequence "[3J"

  null
  ret

f_clear_buffer:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  cmp rbx, 0
  jne @f
    boolean 1
    mov rbx, rax
  @@:

  cmp rcx, 0
  jne @f
    boolean 1
    mov rcx, rax
  @@:

  cmp rdx, 0
  jne @f
    boolean 1
    mov rdx, rax
  @@:

  check_type rbx, BOOLEAN ; После курсора
  check_type rcx, BOOLEAN ; До курсора
  check_type rdx, BOOLEAN ; Буфер прокрутки

  boolean_value rbx
  mov rbx, rax

  boolean_value rcx
  mov rcx, rax

  boolean_value rdx
  mov rdx, rax

  cmp rbx, 1
  jne .check_before

  cmp rcx, 1
  je .clear_after

    clear_screen_buffer

  .clear_after:
    clear_buffer_after_cursor
    jmp .check_scroll_buffer

  .check_before:

  cmp rcx, 1
  jne .check_scroll_buffer
    clear_buffer_before_cursor

  .check_scroll_buffer:

  cmp rdx, 1
  jne @f
    clear_scroll_buffer
  @@:

  null
  ret

f_clear_line_after_cursor:
  print_ansi_sequence "[0K"

  null
  ret

f_clear_line_before_cursor:
  print_ansi_sequence "[1K"

  null
  ret

f_clear_current_line:
  print_ansi_sequence "[2K"

  null
  ret

f_clear_line:
  get_arg 0
  mov rbx, rax
  get_arg 1
  mov rcx, rax
  get_arg 2
  mov rdx, rax

  cmp rbx, 0
  jne @f
    boolean 1
    mov rbx, rax
  @@:

  cmp rcx, 0
  jne @f
    boolean 1
    mov rcx, rax
  @@:

  cmp rdx, 0
  jne @f
    boolean 1
    mov rdx, rax
  @@:

  check_type rbx, BOOLEAN ; После курсора
  check_type rcx, BOOLEAN ; До курсора

  boolean_value rbx
  mov rbx, rax

  boolean_value rcx
  mov rcx, rax

  cmp rbx, 1
  jne .check_before

  cmp rcx, 1
  je .clear_after

    clear_current_line

  .clear_after:
    clear_line_after_cursor
    jmp .end

  .check_before:

  cmp rcx, 1
  jne .end
    clear_line_before_cursor

  .end:

  null
  ret

f_reset_styles:
  print_ansi_sequence "[0m"

  null
  ret

f_set_bright_font:
  print_ansi_sequence "[1m"

  null
  ret

f_set_dim_font:
  print_ansi_sequence "[2m"

  null
  ret

f_set_italic_font:
  print_ansi_sequence "[3m"

  null
  ret

f_set_underline_font:
  print_ansi_sequence "[4m"

  null
  ret

f_set_blink_font:
  print_ansi_sequence "[5m"

  null
  ret

f_set_inverse_colors:
  print_ansi_sequence "[6m"

  null
  ret

f_set_hide_font:
  print_ansi_sequence "[7m"

  null
  ret
