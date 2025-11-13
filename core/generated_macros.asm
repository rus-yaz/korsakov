; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная
;
; Данный файл автоматически сгенерирован из строк документации. Не редактируйте его вручную

; ./core/utils.asm

macro buffer_length pointer* {
  enter pointer
  call f_buffer_length
  return
}

macro sys_print pointer*, size* {
  enter pointer, size
  call f_sys_print
  return
}

macro sys_error pointer*, size* {
  enter pointer, size
  call f_sys_error
  return
}

macro mem_copy source*, destination*, size* {
  enter source, destination, size
  call f_mem_copy
  return
}

macro type_to_string type* {
  enter type
  call f_type_to_string
  return
}

macro type_full_size type* {
  enter type
  call f_type_full_size
  return
}

macro check_type value*, type* {
  enter value, type
  call f_check_type
  return
}

macro utf8_to_utf16 buffer* {
  enter buffer
  call f_utf8_to_utf16
  return
}

macro utf16_to_utf8 buffer* {
  enter buffer
  call f_utf16_to_utf8
  return
}

; ./executor/compiler.asm

macro compiler ast*, context* {
  debug_start "compiler"
  enter ast, context
  call f_compiler
  return
  debug_end "compiler"
}

macro compile node*, context* {
  debug_start "compile"
  enter node, context
  call f_compile
  return
  debug_end "compile"
}

macro compile_body node*, context* {
  debug_start "compile_body"
  enter node, context
  call f_compile_body
  return
  debug_end "compile_body"
}

macro compile_access_link node*, context* {
  debug_start "compile_access_link"
  enter node, context
  call f_compile_access_link
  return
  debug_end "compile_access_link"
}

macro compile_access node*, context* {
  debug_start "compile_access"
  enter node, context
  call f_compile_access
  return
  debug_end "compile_access"
}

macro compile_assign_link node*, context* {
  debug_start "compile_assign_link"
  enter node, context
  call f_compile_assign_link
  return
  debug_end "compile_assign_link"
}

macro compile_assign node*, context* {
  debug_start "compile_assign"
  enter node, context
  call f_compile_assign
  return
  debug_end "compile_assign"
}

macro compile_unary_operation node*, context* {
  debug_start "compile_unary_operation"
  enter node, context
  call f_compile_unary_operation
  return
  debug_end "compile_unary_operation"
}

macro compile_binary_operation node*, context* {
  debug_start "compile_binary_operation"
  enter node, context
  call f_compile_binary_operation
  return
  debug_end "compile_binary_operation"
}

macro compile_null node*, context* {
  debug_start "compile_null"
  enter node, context
  call f_compile_null
  return
  debug_end "compile_null"
}

macro compile_integer node*, context* {
  debug_start "compile_integer"
  enter node, context
  call f_compile_integer
  return
  debug_end "compile_integer"
}

macro compile_float node*, context* {
  debug_start "compile_float"
  enter node, context
  call f_compile_float
  return
  debug_end "compile_float"
}

macro compile_boolean node*, context* {
  debug_start "compile_boolean"
  enter node, context
  call f_compile_boolean
  return
  debug_end "compile_boolean"
}

macro compile_list node*, context* {
  debug_start "compile_list"
  enter node, context
  call f_compile_list
  return
  debug_end "compile_list"
}

macro compile_string node*, context* {
  debug_start "compile_string"
  enter node, context
  call f_compile_string
  return
  debug_end "compile_string"
}

macro compile_dictionary node*, context* {
  debug_start "compile_dictionary"
  enter node, context
  call f_compile_dictionary
  return
  debug_end "compile_dictionary"
}

macro compile_if node*, context* {
  debug_start "compile_if"
  enter node, context
  call f_compile_if
  return
  debug_end "compile_if"
}

macro compile_while node*, context* {
  debug_start "compile_while"
  enter node, context
  call f_compile_while
  return
  debug_end "compile_while"
}

macro compile_for node*, context* {
  debug_start "compile_for"
  enter node, context
  call f_compile_for
  return
  debug_end "compile_for"
}

macro compile_skip node*, context* {
  debug_start "compile_skip"
  enter node, context
  call f_compile_skip
  return
  debug_end "compile_skip"
}

macro compile_break node*, context* {
  debug_start "compile_break"
  enter node, context
  call f_compile_break
  return
  debug_end "compile_break"
}

macro compile_function node*, context* {
  debug_start "compile_function"
  enter node, context
  call f_compile_function
  return
  debug_end "compile_function"
}

macro compile_call node*, context* {
  debug_start "compile_call"
  enter node, context
  call f_compile_call
  return
  debug_end "compile_call"
}

macro compile_return node*, context* {
  debug_start "compile_return"
  enter node, context
  call f_compile_return
  return
  debug_end "compile_return"
}

; ./executor/interpreter.asm

macro interpreter ast*, context* {
  debug_start "interpreter"
  enter ast, context
  call f_interpreter
  return
  debug_end "interpreter"
}

macro interpret node*, context* {
  debug_start "interpret"
  enter node, context
  call f_interpret
  return
  debug_end "interpret"
}

macro interpret_body node*, context* {
  debug_start "interpret_body"
  enter node, context
  call f_interpret_body
  return
  debug_end "interpret_body"
}

macro interpret_assign_link node*, context* {
  debug_start "interpret_assign_link"
  enter node, context
  call f_interpret_assign_link
  return
  debug_end "interpret_assign_link"
}

macro interpret_assign node*, context* {
  debug_start "interpret_assign"
  enter node, context
  call f_interpret_assign
  return
  debug_end "interpret_assign"
}

macro interpret_access_link node*, context* {
  debug_start "interpret_access_link"
  enter node, context
  call f_interpret_access_link
  return
  debug_end "interpret_access_link"
}

macro interpret_access node*, context* {
  debug_start "interpret_access"
  enter node, context
  call f_interpret_access
  return
  debug_end "interpret_access"
}

macro interpret_unary_operation node*, context* {
  debug_start "interpret_unary_operation"
  enter node, context
  call f_interpret_unary_operation
  return
  debug_end "interpret_unary_operation"
}

macro interpret_binary_operation node*, context* {
  debug_start "interpret_binary_operation"
  enter node, context
  call f_interpret_binary_operation
  return
  debug_end "interpret_binary_operation"
}

macro interpret_null node*, context* {
  debug_start "interpret_null"
  enter node, context
  call f_interpret_null
  return
  debug_end "interpret_null"
}

macro interpret_integer node*, context* {
  debug_start "interpret_integer"
  enter node, context
  call f_interpret_integer
  return
  debug_end "interpret_integer"
}

macro interpret_float node*, context* {
  debug_start "interpret_float"
  enter node, context
  call f_interpret_float
  return
  debug_end "interpret_float"
}

macro interpret_boolean node*, context* {
  debug_start "interpret_boolean"
  enter node, context
  call f_interpret_boolean
  return
  debug_end "interpret_boolean"
}

macro interpret_list node*, context* {
  debug_start "interpret_list"
  enter node, context
  call f_interpret_list
  return
  debug_end "interpret_list"
}

macro interpret_string node*, context* {
  debug_start "interpret_string"
  enter node, context
  call f_interpret_string
  return
  debug_end "interpret_string"
}

macro interpret_dictionary node*, context* {
  debug_start "interpret_dictionary"
  enter node, context
  call f_interpret_dictionary
  return
  debug_end "interpret_dictionary"
}

macro interpret_if node*, context* {
  debug_start "interpret_if"
  enter node, context
  call f_interpret_if
  return
  debug_end "interpret_if"
}

macro interpret_while node*, context* {
  debug_start "interpret_while"
  enter node, context
  call f_interpret_while
  return
  debug_end "interpret_while"
}

macro interpret_for node*, context* {
  debug_start "interpret_for"
  enter node, context
  call f_interpret_for
  return
  debug_end "interpret_for"
}

macro interpret_skip node*, context* {
  debug_start "interpret_skip"
  enter node, context
  call f_interpret_skip
  return
  debug_end "interpret_skip"
}

macro interpret_break node*, context* {
  debug_start "interpret_break"
  enter node, context
  call f_interpret_break
  return
  debug_end "interpret_break"
}

macro interpret_function node*, context* {
  debug_start "interpret_function"
  enter node, context
  call f_interpret_function
  return
  debug_end "interpret_function"
}

macro interpret_call node*, context* {
  debug_start "interpret_call"
  enter node, context
  call f_interpret_call
  return
  debug_end "interpret_call"
}

macro interpret_return node*, context* {
  debug_start "interpret_return"
  enter node, context
  call f_interpret_return
  return
  debug_end "interpret_return"
}

; ./executor/nodes.asm

macro check_node_type node*, type* {
  debug_start "check_node_type"
  enter node, type
  call f_check_node_type
  return
  debug_end "check_node_type"
}

macro access_link_node variable*, keys* {
  enter variable, keys
  call f_access_link_node
  return
}

macro access_node variable*, keys* {
  enter variable, keys
  call f_access_node
  return
}

macro assign_link_node variable*, keys*, value* {
  enter variable, keys, value
  call f_assign_link_node
  return
}

macro assign_node variable*, keys*, value* {
  enter variable, keys, value
  call f_assign_node
  return
}

macro binary_operation_node left_node*, operator*, right_node* {
  enter left_node, operator, right_node
  call f_binary_operation_node
  return
}

macro list_node elements* {
  enter elements
  call f_list_node
  return
}

macro null_node {
  enter
  call f_null_node
  return
}

macro integer_node token* {
  enter token
  call f_integer_node
  return
}

macro float_node token* {
  enter token
  call f_float_node
  return
}

macro boolean_node token* {
  enter token
  call f_boolean_node
  return
}

macro string_node token* {
  enter token
  call f_string_node
  return
}

macro call_node variable*, arguments*, named_arguments* {
  enter variable, arguments, named_arguments
  call f_call_node
  return
}

macro unary_operation_node operator*, operand* {
  enter operator, operand
  call f_unary_operation_node
  return
}

macro dictionary_node elements* {
  enter elements
  call f_dictionary_node
  return
}

macro check_node cases*, else_case* {
  enter cases, else_case
  call f_check_node
  return
}

macro if_node cases*, else_case* {
  enter cases, else_case
  call f_if_node
  return
}

macro for_node variable*, start*, end*, step*, body*, else_case* {
  enter variable, start, end, step, body, else_case
  call f_for_node
  return
}

macro while_node condition*, body*, else_case* {
  enter condition, body, else_case
  call f_while_node
  return
}

macro method_node variable*, arguments*, body*, autoreturn*, class_name=0, object_name=0 {
  enter variable, arguments, body, autoreturn, class_name, object_name
  call f_method_node
  return
}

macro function_node variable*, arguments*, body*, autoreturn* {
  enter variable, arguments, body, autoreturn
  call f_function_node
  return
}

macro class_node variable*, body*, parents* {
  enter variable, body, parents
  call f_class_node
  return
}

macro delete_node variable* {
  enter variable
  call f_delete_node
  return
}

macro include_node path* {
  enter path
  call f_include_node
  return
}

macro return_node value* {
  enter value
  call f_return_node
  return
}

macro skip_node {
  enter
  call f_skip_node
  return
}

macro break_node {
  enter
  call f_break_node
  return
}

; ./executor/parser.asm

macro parser tokens* {
  debug_start "parser"
  enter tokens
  call f_parser
  return
  debug_end "parser"
}

macro next {
  enter
  call f_next
  return
}

macro skip_newline {
  enter
  call f_skip_newline
  return
}

macro revert amount=0 {
  enter amount
  call f_revert
  return
}

macro update_token {
  enter
  call f_update_token
  return
}

macro expression {
  enter
  call f_expression
  return
}

macro binary_operation operators*, left_function*, right_function=0 {
  enter operators, left_function, right_function
  call f_binary_operation
  return
}

macro atom {
  enter
  call f_atom
  return
}

macro call_expression {
  enter
  call f_call_expression
  return
}

macro power_root {
  enter
  call f_power_root
  return
}

macro factor {
  enter
  call f_factor
  return
}

macro term {
  enter
  call f_term
  return
}

macro comparison_expression {
  enter
  call f_comparison_expression
  return
}

macro arithmetical_expression {
  enter
  call f_arithmetical_expression
  return
}

macro list_expression {
  enter
  call f_list_expression
  return
}

macro check_expression {
  enter
  call f_check_expression
  return
}

macro if_expression {
  enter
  call f_if_expression
  return
}

macro else_expression {
  enter
  call f_else_expression
  return
}

macro for_expression {
  enter
  call f_for_expression
  return
}

macro while_expression {
  enter
  call f_while_expression
  return
}

macro function_expression is_method=0 {
  enter is_method
  call f_function_expression
  return
}

macro class_expression {
  enter
  call f_class_expression
  return
}

macro delete_expression {
  enter
  call f_delete_expression
  return
}

macro include_statement {
  enter
  call f_include_statement
  return
}

macro statement {
  enter
  call f_statement
  return
}

; ./executor/token.asm

macro token_check_type token*, types* {
  debug_start "token_check_type"
  enter token, types
  call f_token_check_type
  return
  debug_end "token_check_type"
}

macro token_check_keyword token*, keywords* {
  debug_start "token_check_keyword"
  enter token, keywords
  call f_token_check_keyword
  return
  debug_end "token_check_keyword"
}

; ./executor/tokenizer.asm

macro tokenizer code*, filename* {
  enter code, filename
  call f_tokenizer
  return
}

macro find_string list*, start* {
  enter list, start
  call f_find_string
  return
}

macro syntax_error file_stack*, message* {
  enter file_stack, message
  call f_syntax_error
  return
}

macro dump_currect_position file_name*, code*, start_line*, start_column*, stop_line*, stop_column* {
  enter file_name, code, start_line, start_column, stop_line, stop_column
  call f_dump_currect_position
  return
}

macro format_token type*, value*, start_line*, start_column*, stop_line*, stop_column* {
  enter type, value, start_line, start_column, stop_line, stop_column
  call f_format_token
  return
}

; ./korsakov.asm

macro print_help {
  enter
  call f_print_help
  return
}

macro format_help_flag flag_info* {
  enter flag_info
  call f_format_help_flag
  return
}

macro check_compilation error_message* {
  enter error_message
  call f_check_compilation
  return
}

; ./lib/arithmetical.asm

macro addition first*, second* {
  enter first, second
  call f_addition
  return
}

macro subtraction first*, second* {
  enter first, second
  call f_subtraction
  return
}

macro multiplication first*, second* {
  enter first, second
  call f_multiplication
  return
}

macro division first*, second* {
  enter first, second
  call f_division
  return
}

macro negate value* {
  enter value
  call f_negate
  return
}

; ./lib/binary.asm

macro buffer_to_binary pointer* {
  enter pointer
  call f_buffer_to_binary
  return
}

macro binary_to_string binary* {
  enter binary
  call f_binary_to_string
  return
}

macro buffer_to_string buffer* {
  enter buffer
  call f_buffer_to_string
  return
}

macro string_to_binary string* {
  enter string
  call f_string_to_binary
  return
}

macro binary_length binary* {
  enter binary
  call f_binary_length
  return
}

; ./lib/boolean.asm

macro boolean value* {
  enter value
  call f_boolean
  return
}

macro boolean_copy boolean* {
  enter boolean
  call f_boolean_copy
  return
}

macro boolean_value boolean* {
  enter boolean
  call f_boolean_value
  return
}

macro boolean_not boolean* {
  enter boolean
  call f_boolean_not
  return
}

macro boolean_and boolean_1*, boolean_2* {
  enter boolean_1, boolean_2
  call f_boolean_and
  return
}

macro boolean_or boolean_1*, boolean_2* {
  enter boolean_1, boolean_2
  call f_boolean_or
  return
}

; ./lib/comparisons.asm

macro is_equal value_1*, value_2* {
  enter value_1, value_2
  call f_is_equal
  return
}

macro is_not_equal value_1*, value_2* {
  enter value_1, value_2
  call f_is_not_equal
  return
}

macro is_lower value_1*, value_2* {
  enter value_1, value_2
  call f_is_lower
  return
}

macro is_greater value_1*, value_2* {
  enter value_1, value_2
  call f_is_greater
  return
}

macro is_lower_or_equal value_1*, value_2* {
  enter value_1, value_2
  call f_is_lower_or_equal
  return
}

macro is_greater_or_equal value_1*, value_2* {
  enter value_1, value_2
  call f_is_greater_or_equal
  return
}

; ./lib/context.asm

macro set_program_start_pointer pointer* {
  enter pointer
  call f_set_program_start_pointer
  return
}

macro get_program_start_pointer {
  enter
  call f_get_program_start_pointer
  return
}

macro get_cli_arguments_count {
  enter
  call f_get_cli_arguments_count
  return
}

macro get_cli_arguments {
  enter
  call f_get_cli_arguments
  return
}

macro get_environment_variables {
  enter
  call f_get_environment_variables
  return
}

; ./lib/copy.asm

macro copy value* {
  enter value
  call f_copy
  return
}

; ./lib/delete.asm

macro delete variable* {
  enter variable
  call f_delete
  return
}

; ./lib/dictionary.asm

macro dictionary capacity=2 {
  enter capacity
  call f_dictionary
  return
}

macro dictionary_from_list list* {
  enter list
  call f_dictionary_from_list
  return
}

macro dictionary_length dictionary* {
  enter dictionary
  call f_dictionary_length
  return
}

macro dictionary_capacity dictionary* {
  enter dictionary
  call f_dictionary_capacity
  return
}

macro dictionary_expand_capacity dictionary* {
  enter dictionary
  call f_dictionary_expand_capacity
  return
}

macro dictionary_set_link dictionary*, key*, value* {
  enter dictionary, key, value
  call f_dictionary_set_link
  return
}

macro dictionary_set dictionary*, key*, value* {
  enter dictionary, key, value
  call f_dictionary_set
  return
}

macro dictionary_get_link dictionary*, key*, default=0 {
  enter dictionary, key, default
  call f_dictionary_get_link
  return
}

macro dictionary_get dictionary*, key*, default=0 {
  enter dictionary, key, default
  call f_dictionary_get
  return
}

macro dictionary_copy_links dictionary* {
  enter dictionary
  call f_dictionary_copy_links
  return
}

macro dictionary_copy dictionary* {
  enter dictionary
  call f_dictionary_copy
  return
}

macro dictionary_items_links dictionary* {
  enter dictionary
  call f_dictionary_items_links
  return
}

macro dictionary_items dictionary* {
  enter dictionary
  call f_dictionary_items
  return
}

macro dictionary_keys_links dictionary* {
  enter dictionary
  call f_dictionary_keys_links
  return
}

macro dictionary_keys dictionary* {
  enter dictionary
  call f_dictionary_keys
  return
}

macro dictionary_values_links dictionary* {
  enter dictionary
  call f_dictionary_values_links
  return
}

macro dictionary_values dictionary* {
  enter dictionary
  call f_dictionary_values
  return
}

macro dictionary_extend_links dictionary*, other* {
  enter dictionary, other
  call f_dictionary_extend_links
  return
}

macro dictionary_extend dictionary*, other* {
  enter dictionary, other
  call f_dictionary_extend
  return
}

macro dictionary_add_links dictionary1*, dictionary2* {
  enter dictionary1, dictionary2
  call f_dictionary_add_links
  return
}

macro dictionary_add dictionary1*, dictionary2* {
  enter dictionary1, dictionary2
  call f_dictionary_add
  return
}

; ./lib/error.asm

macro error_raw raw_string_link* {
  enter raw_string_link
  call f_error_raw
  return
}

macro error_binary binary_string_link* {
  enter binary_string_link
  call f_error_binary
  return
}

macro error arguments*, separator=0, end_of_string=0 {
  enter arguments, separator, end_of_string
  call f_error
  return
}

; ./lib/exit.asm

macro program_exit code=0 {
  enter code
  call f_program_exit
  return
}

; ./lib/float.asm

macro buffer_to_float buffer* {
  enter buffer
  call f_buffer_to_float
  return
}

macro float_copy float* {
  enter float
  call f_float_copy
  return
}

macro float_add float_1*, float_2* {
  enter float_1, float_2
  call f_float_add
  return
}

macro float_sub float_1*, float_2* {
  enter float_1, float_2
  call f_float_sub
  return
}

macro float_mul float_1*, float_2* {
  enter float_1, float_2
  call f_float_mul
  return
}

macro float_div float_1*, float_2* {
  enter float_1, float_2
  call f_float_div
  return
}

macro float_neg float* {
  enter float
  call f_float_neg
  return
}

macro integer_to_float integer* {
  enter integer
  call f_integer_to_float
  return
}

macro string_to_float string* {
  enter string
  call f_string_to_float
  return
}

; ./lib/fs.asm

macro readlink path* {
  enter path
  call f_readlink
  return
}

; ./lib/function.asm

macro function name*, link*, arguments*, named_arguments*, accumulators=0, is_internal=0 {
  enter name, link, arguments, named_arguments, accumulators, is_internal
  call f_function
  return
}

macro function_copy function* {
  enter function
  call f_function_copy
  return
}

macro function_call function*, arguments*, named_arguments* {
  enter function, arguments, named_arguments
  call f_function_call
  return
}

; ./lib/heap.asm

macro get_heap_address_by_offset offset* {
  enter offset
  call f_get_heap_address_by_offset
  return
}

macro get_heap_offset_by_address address* {
  enter address
  call f_get_heap_offset_by_address
  return
}

macro free_block block* {
  enter block
  call f_free_block
  return
}

macro merge_blocks block_1*, block_2* {
  enter block_1, block_2
  call f_merge_blocks
  return
}

macro delete_block block* {
  enter block
  call f_delete_block
  return
}

macro create_block size* {
  enter size
  call f_create_block
  return
}

; ./lib/input.asm

macro input string=0 {
  enter string
  call f_input
  return
}

; ./lib/integer.asm

macro integer value* {
  enter value
  call f_integer
  return
}

macro string_to_integer integer* {
  enter integer
  call f_string_to_integer
  return
}

macro integer_copy int* {
  enter int
  call f_integer_copy
  return
}

macro integer_neg int* {
  enter int
  call f_integer_neg
  return
}

macro integer_inc int* {
  enter int
  call f_integer_inc
  return
}

macro integer_dec int* {
  enter int
  call f_integer_dec
  return
}

macro integer_add int_1*, int_2* {
  enter int_1, int_2
  call f_integer_add
  return
}

macro integer_sub int_1*, int_2* {
  enter int_1, int_2
  call f_integer_sub
  return
}

macro integer_mul int_1*, int_2* {
  enter int_1, int_2
  call f_integer_mul
  return
}

macro integer_div int_1*, int_2* {
  enter int_1, int_2
  call f_integer_div
  return
}

macro float_to_integer float* {
  enter float
  call f_float_to_integer
  return
}

; ./lib/linux/context.asm

match =1, LINUX {
  macro parse_cli_arguments \{
    enter
    call f_parse_cli_arguments
    return
  \}
  
  macro parse_environment_variables \{
    enter
    call f_parse_environment_variables
    return
  \}
}

; ./lib/linux/exec.asm

match =1, LINUX {
  macro run command*, env*, wait=1 \{
    enter command, env, wait
    call f_run
    return
  \}
}

; ./lib/linux/file.asm

match =1, LINUX {
  macro _get_file_stat_buffer filename* \{
    enter filename
    call f__get_file_stat_buffer
    return
  \}
  
  macro _get_file_size filename* \{
    enter filename
    call f__get_file_size
    return
  \}
  
  macro open_file filename*, flags=O_RDONLY, mode=444o \{
    enter filename, flags, mode
    call f_open_file
    return
  \}
  
  macro close_file file* \{
    enter file
    call f_close_file
    return
  \}
  
  macro read_file file* \{
    enter file
    call f_read_file
    return
  \}
  
  macro write_file file*, string* \{
    enter file, string
    call f_write_file
    return
  \}
  
  macro get_absolute_path path* \{
    enter path
    call f_get_absolute_path
    return
  \}
}

; ./lib/linux/fs.asm

match =1, LINUX {
  macro getcwd \{
    enter
    call f_getcwd
    return
  \}
  
  macro chdir path* \{
    enter path
    call f_chdir
    return
  \}
  
  macro get_exe_path \{
    enter
    call f_get_exe_path
    return
  \}
  
  macro get_exe_directory \{
    enter
    call f_get_exe_directory
    return
  \}
}

; ./lib/linux/heap.asm

match =1, LINUX {
  macro init_heap \{
    enter
    call f_init_heap
    return
  \}
  
  macro expand_heap \{
    enter
    call f_expand_heap
    return
  \}
}

; ./lib/linux/random.asm

match =1, LINUX {
  macro get_random start=0, end=0 \{
    enter start, end
    call f_get_random
    return
  \}
}

; ./lib/list.asm

macro list capacity=2 {
  enter capacity
  call f_list
  return
}

macro list_length list* {
  enter list
  call f_list_length
  return
}

macro list_capacity list* {
  enter list
  call f_list_capacity
  return
}

macro list_expand_capacity list* {
  enter list
  call f_list_expand_capacity
  return
}

macro list_set_link list*, index*, value* {
  enter list, index, value
  call f_list_set_link
  return
}

macro list_set list*, index*, value* {
  enter list, index, value
  call f_list_set
  return
}

macro list_get_link list*, index* {
  enter list, index
  call f_list_get_link
  return
}

macro list_get list*, index* {
  enter list, index
  call f_list_get
  return
}

macro list_copy_links list* {
  enter list
  call f_list_copy_links
  return
}

macro list_copy list* {
  enter list
  call f_list_copy
  return
}

macro list_append_link list*, value* {
  enter list, value
  call f_list_append_link
  return
}

macro list_append list*, value* {
  enter list, value
  call f_list_append
  return
}

macro list_pop_link list*, index=-1 {
  enter list, index
  call f_list_pop_link
  return
}

macro list_pop list*, index=-1 {
  enter list, index
  call f_list_pop
  return
}

macro list_insert_link list*, index*, value* {
  enter list, index, value
  call f_list_insert_link
  return
}

macro list_insert list*, index*, value* {
  enter list, index, value
  call f_list_insert
  return
}

macro list_index list*, value* {
  enter list, value
  call f_list_index
  return
}

macro list_include list*, value* {
  enter list, value
  call f_list_include
  return
}

macro list_extend_links list*, other* {
  enter list, other
  call f_list_extend_links
  return
}

macro list_extend list*, other* {
  enter list, other
  call f_list_extend
  return
}

macro list_reverse_links list* {
  enter list
  call f_list_reverse_links
  return
}

macro list_reverse list* {
  enter list
  call f_list_reverse
  return
}

macro list_slice_links list*, start=0, end=-1, step=1 {
  enter list, start, end, step
  call f_list_slice_links
  return
}

macro list_slice list*, start=0, end=-1, step=1 {
  enter list, start, end, step
  call f_list_slice
  return
}

macro list_add_links list1*, list2* {
  enter list1, list2
  call f_list_add_links
  return
}

macro list_add list1*, list2* {
  enter list1, list2
  call f_list_add
  return
}

macro list_mul_links list*, count* {
  enter list, count
  call f_list_mul_links
  return
}

macro list_mul list*, count* {
  enter list, count
  call f_list_mul
  return
}

; ./lib/math.asm

macro factorial integer* {
  enter integer
  call f_factorial
  return
}

macro euler_power_taylor exponent* {
  enter exponent
  call f_euler_power_taylor
  return
}

macro euler_power exponent* {
  enter exponent
  call f_euler_power
  return
}

; ./lib/null.asm

macro null {
  enter
  call f_null
  return
}

; ./lib/print.asm

macro print_raw raw_string_link* {
  enter raw_string_link
  call f_print_raw
  return
}

macro print_binary binary_string_link* {
  enter binary_string_link
  call f_print_binary
  return
}

macro print arguments*, separator=0, end_of_string=0 {
  enter arguments, separator, end_of_string
  call f_print
  return
}

; ./lib/random.asm

macro get_pseudorandom start=0, end=0 {
  enter start, end
  call f_get_pseudorandom
  return
}

macro set_seed seed* {
  enter seed
  call f_set_seed
  return
}

macro reset_seed {
  enter
  call f_reset_seed
  return
}

; ./lib/string.asm

macro string_from_capacity capacity=2 {
  enter capacity
  call f_string_from_capacity
  return
}

macro string_length string* {
  enter string
  call f_string_length
  return
}

macro string_capacity string* {
  enter string
  call f_string_capacity
  return
}

macro string_expand_capacity string* {
  enter string
  call f_string_expand_capacity
  return
}

macro string_set_link string*, index*, char* {
  enter string, index, char
  call f_string_set_link
  return
}

macro string_set string*, index*, char* {
  enter string, index, char
  call f_string_set
  return
}

macro string_get_link string*, index* {
  enter string, index
  call f_string_get_link
  return
}

macro string_get string*, index* {
  enter string, index
  call f_string_get
  return
}

macro string_copy_links string* {
  enter string
  call f_string_copy_links
  return
}

macro string_copy string* {
  enter string
  call f_string_copy
  return
}

macro string_pop_link string*, index=-1 {
  enter string, index
  call f_string_pop_link
  return
}

macro string_pop string*, index=-1 {
  enter string, index
  call f_string_pop
  return
}

macro string_index string*, char* {
  enter string, char
  call f_string_index
  return
}

macro string_include string*, substring* {
  enter string, substring
  call f_string_include
  return
}

macro string_extend_links string*, other* {
  enter string, other
  call f_string_extend_links
  return
}

macro string_extend string*, other* {
  enter string, other
  call f_string_extend
  return
}

macro split_links string*, separator=" ", max_parts=-1 {
  enter string, separator, max_parts
  call f_split_links
  return
}

macro split string*, separator=" ", max_parts=-1 {
  enter string, separator, max_parts
  call f_split
  return
}

macro split_from_right_links string*, separator=" ", max_parts=-1 {
  enter string, separator, max_parts
  call f_split_from_right_links
  return
}

macro split_from_right string*, separator=" ", max_parts=-1 {
  enter string, separator, max_parts
  call f_split_from_right
  return
}

macro join_links list*, separator=" " {
  enter list, separator
  call f_join_links
  return
}

macro join list*, separator=" " {
  enter list, separator
  call f_join
  return
}

macro is_alpha string* {
  enter string
  call f_is_alpha
  return
}

macro is_digit string* {
  enter string
  call f_is_digit
  return
}

macro string_to_list string* {
  enter string
  call f_string_to_list
  return
}

macro string_reverse_links string* {
  enter string
  call f_string_reverse_links
  return
}

macro string_reverse string* {
  enter string
  call f_string_reverse
  return
}

macro string_slice_links string*, start=0, end=-1, step=1 {
  enter string, start, end, step
  call f_string_slice_links
  return
}

macro string_slice string*, start=0, end=-1, step=1 {
  enter string, start, end, step
  call f_string_slice
  return
}

macro string_add_links string1*, string2* {
  enter string1, string2
  call f_string_add_links
  return
}

macro string_add string1*, string2* {
  enter string1, string2
  call f_string_add
  return
}

macro string_mul_links string*, count* {
  enter string, count
  call f_string_mul_links
  return
}

macro string_mul string*, count* {
  enter string, count
  call f_string_mul
  return
}

; ./lib/to_string.asm

macro to_string value* {
  enter value
  call f_to_string
  return
}

; ./lib/variables.asm

macro assign_link variable*, keys*, value*, context=[GLOBAL_CONTEXT] {
  enter variable, keys, value, context
  call f_assign_link
  return
}

macro assign variable*, keys*, value*, context=[GLOBAL_CONTEXT] {
  enter variable, keys, value, context
  call f_assign
  return
}

macro access_link variable*, keys*, context=[GLOBAL_CONTEXT] {
  enter variable, keys, context
  call f_access_link
  return
}

macro access variable*, keys*, context=[GLOBAL_CONTEXT] {
  enter variable, keys, context
  call f_access
  return
}

; ./lib/windows/context.asm

match =1, WINDOWS {
  macro parse_cli_arguments \{
    enter
    call f_parse_cli_arguments
    return
  \}
  
  macro parse_environment_variables \{
    enter
    call f_parse_environment_variables
    return
  \}
}

; ./lib/windows/exec.asm

match =1, WINDOWS {
  macro run command*, env*, wait=1 \{
    enter command, env, wait
    call f_run
    return
  \}
}

; ./lib/windows/file.asm

match =1, WINDOWS {
  macro _get_file_size handle* \{
    enter handle
    call f__get_file_size
    return
  \}
  
  macro open_file filename*, flags=O_RDONLY, mode=OPEN_EXISTING \{
    enter filename, flags, mode
    call f_open_file
    return
  \}
  
  macro close_file file* \{
    enter file
    call f_close_file
    return
  \}
  
  macro read_file file* \{
    enter file
    call f_read_file
    return
  \}
  
  macro write_file file*, string* \{
    enter file, string
    call f_write_file
    return
  \}
  
  macro get_absolute_path path* \{
    enter path
    call f_get_absolute_path
    return
  \}
}

; ./lib/windows/fs.asm

match =1, WINDOWS {
  macro getcwd \{
    enter
    call f_getcwd
    return
  \}
  
  macro chdir path* \{
    enter path
    call f_chdir
    return
  \}
  
  macro get_exe_path \{
    enter
    call f_get_exe_path
    return
  \}
  
  macro get_exe_directory \{
    enter
    call f_get_exe_directory
    return
  \}
}

; ./lib/windows/heap.asm

match =1, WINDOWS {
  macro init_heap \{
    enter
    call f_init_heap
    return
  \}
  
  macro expand_heap \{
    enter
    call f_expand_heap
    return
  \}
}

; ./lib/windows/random.asm

match =1, WINDOWS {
  macro get_random start=0, end=0 \{
    enter start, end
    call f_get_random
    return
  \}
}
