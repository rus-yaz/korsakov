include "lib/korsakov.asm"

section 'data' writable
string_1 db "привет, мир!", 0


section 'start' executable
start:
показать string_1
exit 0