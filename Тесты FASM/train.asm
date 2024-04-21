format ELF64
public _start

section "data" writable
  buffer_size = 20
  buffer rb buffer_size
  string db "Hello, World!", 13, 10

section "_start" executable
_start:
  ; Печать строки
  mov rax, string
  call print_string

  ; Печать символа
  mov rax, 48
  call print_char
  mov rax, '!'
  call print_char
  mov rax, 10
  call print_char

  ; Печать числа
  mov rax, 420
  mov rbx, buffer
  mov rcx, buffer_size
  call number_to_string

  mov rax, buffer
  call print_string

  mov rax, 10
  call print_char

  call exit

; Функция печати числа rax
; Аргументы:
; - rax - число
; - rbx - буфер
; - rcx - размер буфера
section "number_to_string" executable
number_to_string:
  push rax
  push rbx
  push rcx
  push rdx
  push rsi

  mov rsi, rcx
  xor rcx, rcx
  .loop_start:
    push rbx
    mov rbx, 10
    xor rdx, rdx
    div rbx
    pop rbx
    add rdx, '0'
    push rdx
    inc rcx

    cmp rax, 0
    je .next

    jmp .loop_start

  .next:
    mov rdx, rcx
    xor rcx, rcx

  .to_string:
    cmp rcx, rdx
    je .pop

    pop rax
    mov [rbx + rcx], rax
    inc rcx

    jmp .to_string

  .pop:
    cmp rcx, rdx
    je .loop_end

    pop rax
    inc rcx

    jmp .pop

  .loop_end:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

; Функция печати символа rax
section "print_char" executable
print_char:
  push rax
  push rbx
  push rcx
  push rdx

  push rax

  mov rax, 1
  mov rdi, 1
  mov rsi, rsp
  mov rdx, 1
  syscall

  pop rax

  pop rdx
  pop rcx
  pop rbx
  pop rax
  ret

; Функция печати строки rax
; Аргументы
; - rax - строка
section "print_string" executable
print_string:
  mov rsi, rax
  call length
  mov rdx, rax

  mov rax, 1
  mov rdi, 1
  syscall

  ret

; Функция подсчёта длины массива/строки rax
; Аргументы
; - rax - массив/строка
; Возвращаемые значения
; - rax - длина
section "length" executable
length:
  push rbx

  xor rbx, rbx

  .loop_start:
    cmp [rax + rbx], byte 0
    je .loop_end

    inc rbx
    jmp .loop_start

  .loop_end:
    mov rax, rbx

    pop rbx
    ret

section "exit" executable
exit:
  mov rdi, 0
  mov rax, 60
  syscall
