include "syscalls.asm"
include "types.asm"

section "syscall" executable

; Системный вызов. Количество передаваемых аргументов зависит от указанной в макросе цифры
;
; Аргументы:
;   number — номер системного вызова
;   arg_1...arg_6 — аргументы системного вызова (rdi, rsi, rdx, r10, r8, r9)

macro syscall_0 number {
  mov rax, number
  syscall
}

macro syscall_1 number, arg_1 {
  mov rdi, arg_1

  syscall_0 number
}

macro syscall_2 number, arg_1, arg_2 {
  mov rsi, arg_2

  syscall_1 number, arg_1
}

macro syscall_3 number, arg_1, arg_2, arg_3 {
  mov rdx, arg_3

  syscall_2 number, arg_1, arg_2
}

macro syscall_4 number, arg_1, arg_2, arg_3, arg_4 {
  mov r10, arg_4

  syscall_3 number, arg_1, arg_2, arg_3
}

macro syscall_5 number, arg_1, arg_2, arg_3, arg_4, arg_5 {
  mov r8, arg_5

  syscall_4 number, arg_1, arg_2, arg_3, arg_4
}

macro syscall_6 number, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6 {
  mov r9, arg_6

  syscall_5 number, arg_1, arg_2, arg_3, arg_4, arg_5
}

section "enter" executable

macro enter {
  push rax
  push rbx
  push rcx
  push rdx
  push rsi
  push rdi
  push r8
  push r9
  push r10
  push r11
  push r12
  push r13
  push r14
  push r15
}

macro enter_1 arg_1 {
	enter
	mov rax, arg_1
}

macro enter_2 arg_1, arg_2 {
	enter_1 arg_1
	mov rbx, arg_2
}

section "leave" executable

macro leave {
  pop r15
  pop r14
  pop r13
  pop r12
  pop r11
  pop r10
  pop r9
  pop r8
  pop rdi
  pop rsi
  pop rdx
  pop rcx
  pop rbx
  pop rax
}

macro leave_with_return {
  push rax
  add rsp, 8

  leave
  mov rax, [rsp - 8*15]
}

section "regs_operations" executable

macro pushq val {
  mov rax, val
  push rax
}

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
	enter_1 str_ptr

  call f_buffer_length

	leave_with_return
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
	enter_2 ptr, size

  call f_print

	leave
}

f_print:
  syscall_3 SYS_WRITE,\
            STDOUT,\
            rax,\       ; Указатель на данные для вывода
            rbx         ; Длина данных для вывода

  ret

section "print_buffer" executable

macro print_buffer ptr {
	enter_1 ptr

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

macro exit code {
  syscall_1 SYS_EXIT,\
            code
}

section "exit_with_message" executable

; Выход с кодом 0 и сообщением
;
; Аргументы:
;   message — указатель на текст сообщения

macro exit_with_message message, code {
  print_buffer message
  exit code
}

section "check_error" executable

macro check_error operation, message {
  push rax
  mov rax, message
  operation f_check_error
  pop rax
}

f_check_error:
  print_buffer rax
  exit -1

section "print_int" executable

macro print_int int {
	enter_1 int

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
	enter_1 string

  call f_print_string

	leave
}

f_print_string:
	; Проверка типа
	mov rbx, [rax]
	cmp rbx, STRING
	je .string
	mov rbx, [rax]
	cmp rbx, CHAR
	je .char

  print_buffer EXPECTED_STRING_CHAR_TYPE_ERROR

	.string:

	mov rcx, [rax + 8*1]     ; Длина строки
	add rax, 8*STRING_HEADER ; Указатель на содержимое строки

	.while:
		cmp rcx, 0
		jle .end

		dec rcx

		; Проверка типа
		mov rbx, [rax]
		cmp rbx, CHAR
		check_error jne, EXPECTED_CHAR_TYPE_ERROR

		mov rdx, [rax+8*2] ; Символ
		bswap rdx
		push rdx
		mov rdx, rsp

		print rdx,\ ; Указатель на строку
					8   ; Длина строки

		add rsp, 8
		add rax, 8*3

		jmp .while

	.char:
		mov rdx, [rax+8*2] ; Символ
		bswap rdx
		push rdx
		mov rdx, rsp

		print rdx,\ ; Указатель на строку
					8   ; Длина строки

		add rsp, 8

		push 10
		mov rax, rsp
		print rax,\
					1

		add rsp, 8

	.end:

  ret
