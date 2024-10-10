; format ELF64 executable
; entry _start

format ELF64
public _start

section ".data" writable
	heap_ptr rq 1
	heap_size dq 4096
	heap_end rq 1
	avl_tree_ptr rq 1
	HEADER_SIGN dq 0xFEDCBA9876543210

; Системные вызовы
define SYS_MMAP 9
define SYS_EXIT 60

macro mem_mov dst, src {
	push r15
	mov r15, src
	mov dst, r15
	pop r15
}

macro write_header reg, val_1, val_2, val_3, val_4 {
	mem_mov [reg + 8*0], val_1 ; Метка заголовка блока
	mem_mov [reg + 8*1], val_2 ; Размер данного блока
	mem_mov [reg + 8*2], val_3 ; Размер предыдущего блока
	mem_mov [reg + 8*3], val_4 ; Состояние блока
}

macro allocate size {
	mov rax, SYS_MMAP ; Код системного вызова для MMAP
	mov rdi, 0        ; Адрес (если ноль, нахоходится автоматически)
	mov rsi, size     ; Количество памяти для аллокации
	mov edx, 7        ; Права (PROT_READ | PROT_WRITE)
	mov r10, 34       ; Что-то (MAP_ANONYMOUS | MAP_PRIVATE)
	xor r8d, r8d      ; Файл дескриптор (ввод)
	xor r9d, r9d      ; Смещение относительно начала файла (с начала файла)
	syscall

	test rax, rax ; Проверка корректности выделения памяти
	js error_exit ; Если RAX меньше нуля, то выйти с ошибкой
}

macro allocate_heap {
	allocate [heap_size] ; Аллокация памяти для кучи
	mov [heap_ptr], rax  ; Сохранение указателя на начало кучи в переменную HEAP_PTR

	mov rbx, [heap_size]                       ; Запись размера кучи в RBX
	sub rbx, 8*4                               ; Учёт размера заголовка блока
	write_header rax, [HEADER_SIGN], rbx, 0, 0 ; Запись заголовка первого блока

	mov rax, [heap_ptr]  ; Запись указателя на начало кучи RAX
	add rax, 8*4         ; Смещение указателя RAX на размер заголовка блока
	add rax, [heap_size] ; Смещение указателя RAX на размер кучи
	mov [heap_end], rax  ; Запись указателя на конец кучи в переменную HEAP_END
}

macro create_block memory_to_allocate {
	; Нахождение размера записываемого блока
	size = memory_to_allocate + (8*4 - memory_to_allocate mod (8*4))

	push rax 

		mov rax, size

		call f_create_block
	pop rax
}

section "_start" executable
_start:
	allocate_heap
	create_block 256
	create_block 256

	mov rdi, 0
	call sys_exit

section ".exit" executable
error_exit:
	mov edi, 1              ; Status code 1 (exit with error)
sys_exit:
	; System call to exit
	mov eax, SYS_EXIT       ; syscall number for exit
	syscall                 ; Make the system call
	ret

f_create_block:
	; Нахождение размера записываемого блока
	mov r8, rax

	mov rax, [heap_ptr] ; Запись указателя на начало кучи в RAX

	; Цикл для нахождения подходящего блока
	create_block_do:
		; Если заголовок не найден, выйти с ошибкой
		mov rdx, [rax]
		cmp rdx, [HEADER_SIGN]
		jne error_exit

		; Если блок используется, начать искать новый блок
		mov rdx, [rax + 8*3]
		test rdx, 1
		jnz create_block_else

		; Сравнение выделенного размера и размера блока
		mov rdx, [rax + 8*1]
		cmp rdx, r8
		jge create_block_final 

	create_block_else:
		add rax, [rax + 8*1] ; Смещение адреса текущего блока на его размер
		add rax, 8*4         ; Смещение адреса текущего указателя на размер заголовка
		jmp create_block_do  ; Переход к началу цикла

	; Окончание цикла
	create_block_final:

	mov rcx, [rax + 8*1] ; Сохранение размера текущего блока в RCX

	; Вычисление адреса нового блока
	mov rbx, rax
	add rbx, r8
	add rbx, 8*4

	; Вычисление адреса следующего блока
	mov rdx, rax
	add rdx, 8*4
	add rdx, rcx

	; Проверка нахождения блока внутри кучи
	cmp rdx, heap_end
	jge create_block_skip_next_block_modifying

	push rax
		; Проверка вместимости пространства
		mov rax, [rdx + 8*3]
		test rax, 1
	pop rax
	jnz create_block_skip_next_block_modifying


	create_block_skip_next_block_modifying:

	mem_mov [rax + 8*3], 1 ; Изменение состояния текущего блока на используемое
	sub rcx, r8          ; Вычисление размера текущего блока в RCX
	mem_mov [rax + 8*1], r8 ; Изменение SIZE у предыдущего блока

	; KEY
	; SIZE
	; PREV_SIZE
	; STATE
	write_header rbx, [HEADER_SIGN], rcx, r8, 0
	ret