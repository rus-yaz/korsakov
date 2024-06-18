from parser import Parser
from subprocess import DEVNULL
from subprocess import run as cmd

from compiler import Compiler
from interpreter import Interpreter
from loggers import Position, RuntimeError
from tokenizer import Tokenizer
from tokens import global_context

COMMANDLINE_ARGUMENTS = dict.fromkeys(["compile", "asm", "comments", "object", "debug", "nostd", "tokens", "ast", "context"], False)

def run_command(command, comment=None):
  cmd(command, stdout=DEVNULL)
  if COMMANDLINE_ARGUMENTS["debug"] and comment:
    print(f"[ЗАПУСК] {comment}")

def formatter(lines) -> list[str]:
  exceptions = ":", "section", "format", "public"
  code = []
  for line in lines:
    is_exception = False
    for exception in exceptions:
      if exception in line:
        is_exception = True
        break

    code += [line if is_exception else f"  {line}"]

  return code

def run(module_name: str, source_code: str):
  """
    Описание:
      Функция запуска кода из строки

    Аргументы:
      module_name (строка): название модуля, где была вызвана функция
      code (строка): код для исполнения

    Возвращаемое значение:
      *Value или None: результат интерпретации или нуль
      *Error или None: сигнал ошибки или нуль
  """

  error_position = Position(0, 0, 0, module_name, "")
  if source_code == "":
    return None, RuntimeError(error_position, error_position, "Пустой файл", None, False)

  # Tokenization
  tokens, error = Tokenizer(module_name, source_code).tokenize()
  if error:
    return None, error
  elif tokens == []:
    return None, RuntimeError(error_position, error_position, "Нечего исполнять", None, False)

  if COMMANDLINE_ARGUMENTS["debug"] or COMMANDLINE_ARGUMENTS["tokens"]:
    [print("[ТОКЕНЫ]", i) for i in tokens]

  # ------------------------------

  # Abstract Syntax Tree

  ast = Parser(tokens).parse()
  if ast.error:
    return None, ast.error

  if COMMANDLINE_ARGUMENTS["debug"] or COMMANDLINE_ARGUMENTS["ast"]:
    print(ast.node.elements)

  # ------------------------------

  # Interpretation and Compilation

  value, error = None, None

  if COMMANDLINE_ARGUMENTS["compile"]:
    compiler = Compiler(module_name)

    compiler.compile(ast.node.elements)

    compiler.replace_code("mark", ".mark")

    code: list[str] = [
      "format ELF64",
      "section \"_start\" executable",
      "public _start",
      "_start:",
      "mov rbp, rsp",
    ] + compiler.code + [
      "",
      "push !INTEGER_IDENTIFIER",
      "mov rax, 0",
      "push rax",
      "lea rax, [rsp + 8]",
      "push rax",
      "call exit",
      "",
    ] + [line for function in compiler.functions.values() for line in function] + [
      "section \"_data\" writable",
      "!INTEGER_IDENTIFIER = 0",
      "!LIST_IDENTIFIER    = 1",

      "!SYSCALL_WRITE = 1",
      "!SYSCALL_EXIT  = 60",

      "!FILE_DESCRIPTOR_OUTPUT = 1",
      "!FILE_DESCRIPTOR_ERROR  = 2",

      "!ASCII_0 = 48",

      "!error_message dq \"E\", \"r\", \"r\", \"o\", \"r\"",
      "!error_message_length = 5",

      "!buffer_size = 1024",
      "!buffer rb !buffer_size",

      "!frames_counter dq 0",
      "!check dq 0",
    ] + [f"{variable} dq 0"for variable in compiler.variables]

    if not COMMANDLINE_ARGUMENTS["comments"]:
      lines = code.copy()
      code = []
      for line in lines:
        if line.strip() and ";" not in line:
          code += [line]

    file_name = module_name.rsplit(".", 1)[0]
    asm_file_name = file_name + ".asm"
    obj_file_name = file_name + ".o"
    with open(asm_file_name, "w") as file:
      file.write("\n".join(formatter(code)))

    run_command(["fasm", asm_file_name], f"Компиляция {asm_file_name}")
    if not COMMANDLINE_ARGUMENTS["asm"]:
      run_command(["rm", asm_file_name], f"Удаление {asm_file_name}")

    run_command(["ld", obj_file_name, "-o", file_name], f"Линковка {obj_file_name}")
    if not COMMANDLINE_ARGUMENTS["object"]:
      run_command(["rm", obj_file_name], f"Удаление {obj_file_name}")
  else:
    interpretation = Interpreter(module_name).interpret(ast.node, global_context)
    value, error = interpretation.value, interpretation.error

  if COMMANDLINE_ARGUMENTS["debug"] or COMMANDLINE_ARGUMENTS["context"]:
    print(str(global_context.variables))

  return value, error
