section "push" executable

; Множественная версия операции push
;
; Аргументы:
;   arg — значение, которое будет отправлено на стек

macro push [arg] {
  push arg
}

section "pushq" executable

macro pushq val {
  mov rax, val
  push rax
}

section "pop" executable

; Множественная версия операции pop
;
; Аргументы:
;   arg — регистр, куда будет помещено значение со стека

macro pop [arg] {
  pop arg
}

section "enter" executable

macro enter arg_1 = 0, arg_2 = 0, arg_3 = 0, arg_4 = 0, arg_5 = 0, arg_6 = 0, arg_7 = 0, arg_8 = 0, arg_9 = 0, arg_10 = 0, arg_11 = 0, arg_12 = 0 {
  push rax, rbx, rcx, rdx, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15

  mov rax, arg_1
  mov rbx, arg_2
  mov rcx, arg_3
  mov rdx, arg_4
  mov r8,  arg_5
  mov r9,  arg_6
  mov r10, arg_7
  mov r11, arg_8
  mov r12, arg_9
  mov r13, arg_10
  mov r14, arg_11
  mov r15, arg_12
}

section "leave" executable

macro leave {
  pop r15, r14, r13, r12, r11, r10, r9, r8, rdi, rsi, rdx, rcx, rbx, rax
}

section "return" executable

macro return {
  push rax
  add rsp, 8

  leave

  mov rax, [rsp - 8*15]
}

section "mem_mov" executable

; Обмен между двумя различными фрагментами памяти
;
; Аргументы:
;   dst — приёмник
;   src — источник
macro mem_mov dst, src {
  push r15
  mov r15, src
  mov dst, r15
  pop r15
}

section "buffer_length" executable

macro buffer_length str_ptr {
  enter str_ptr

  call f_buffer_length

  return
}

f_buffer_length:
  mov rcx, 0 ; Счётчик

  .loop:
    ; Сравниваем текущий байт с нулём
    mov bl, [rax + rcx]
    cmp bl, 0
    je .done

    inc rcx
    jmp .loop

  .done:
  mov rax, rcx

  ret

section "print" executable

macro print ptr, size {
  enter ptr, size

  call f_print

  leave
}

f_print:
  sys_write STDOUT,\
            rax,\       ; Указатель на данные для вывода
            rbx         ; Длина данных для вывода

  ret

section "print_buffer" executable

macro print_buffer ptr {
  enter ptr

  call f_print_buffer

  leave
}

f_print_buffer:
  mov rsi, rax
  buffer_length rsi
  mov rbx, rax

  print rsi,\      ; Указатель на буфер
        rbx        ; Размер буфера

  ret

section "exit" executable

; Выход из программы
;
; Аргументы:
;   code — код выхода

macro exit code, message = 0 {
  if message eqtype 0
  else
    print_buffer message
  end if

  sys_exit code
}

section "check_error" executable

macro check_error operation, message {
  push rax

  mov rax, message
  operation f_check_error

  pop rax
}

f_check_error:
  exit -1, rax

section "print_int" executable

macro print_int int {
  enter int

  call f_print_int

  leave
}

f_print_int:
  mov r8, rsp
  mov rbx, 10
  push 0
  push 10
  mov rcx, 2
  mov rdx, 0

  .while:
    idiv rbx
    add rdx, 48
    push rdx
    mov rdx, 0
    inc rcx

    cmp rax, 0
    jne .while

  mov rax, rsp
  imul rcx, 8
  print rax, rcx

  mov rsp, r8

  ret

section "print_string" executable

macro print_string string {
  enter string

  call f_print_string

  leave
}

f_print_string:
  ; Проверка типа
  mov rbx, [rax]
  cmp rbx, STRING
  check_error jne, EXPECTED_STRING_CHAR_TYPE_ERROR

	mov rcx, [rax + 8*1]       ; Длина строки
	add rax, STRING_HEADER * 8 ; Указатель на содержимое строки

	.while:
		cmp rcx, 0
		jle .end

		dec rcx

		; Проверка типа
		mov rbx, [rax]
		cmp rbx, INTEGER_HEADER
		check_error jne, EXPECTED_CHAR_TYPE_ERROR

		mov rdx, [rax + INTEGER_HEADER*8] ; Символ
		bswap rdx
		push rdx
		mov rdx, rsp

		print rdx,\ ; Указатель на строку
					8     ; Длина строки

		add rsp, 8
		add rax, (INTEGER_HEADER + 1) * 8

		jmp .while

	.end:

  ret
