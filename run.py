from subprocess import run as run_cmd

from interpreter import Interpreter
from compiler import Compiler
from parser import Parser
from tokenizer import Tokenizer
from tokens import global_context

COMMANDLINE_ARGUMENTS = dict.fromkeys(["compile", "asm", "comments", "object", "debug", "nostd", "tokens", "ast", "context"], False)


def run(module_name: str, code: str):
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

  # Tokenization
  tokens, error = Tokenizer(module_name, code).tokenize()
  if error or not tokens:
    return None, error

  if COMMANDLINE_ARGUMENTS["debug"] or COMMANDLINE_ARGUMENTS["tokens"]:
    [print("[DEBUG]", i) for i in tokens]

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
    compiler.compile(ast.node, global_context)
    compiler.replace_code("mark", ".mark")
    formatter = lambda lines: list(map(lambda x: x if ":" in x or "section" in x else f"  {x}", lines))

    code = [
      "format ELF64",
      "section \"_start\" executable",
      "public _start",
      "_start:",
      "  mov rbp, rsp",
    ] + formatter(compiler.code) + [
      "",
      "  ; Exit",
      "  mov rax, 60",
      "  pop rdi",
      "  syscall",
      ""
    ] + formatter(line for function in compiler.functions.values() for line in function) + [
      "; Error function",
      "!error:",
      "  mov rax, 1",
      "  mov rdi, 1",
      "  mov rsi, !error_message",
      "  mov rdx, !error_message_length",
      "  syscall",
      "  mov rax, 60",
      "  mov rdi, 200",
      "  syscall",
      ""
    ] + [
      "section \"_data\" writable",
      "  !INTEGER_IDENTIFIER = 0",
      "  !LIST_IDENTIFIER = 1",
      "  !error_message db \"Error\", 10",
      "  !error_message_length = 6"
    ]

    if not COMMANDLINE_ARGUMENTS["comments"]:
      lines = code.copy()
      code = []
      for line in lines:
        if line.strip() and ";" not in line:
          code += [line]

    file_name = module_name.rsplit(".", 1)[0]
    with open(file_name + ".asm", "w") as file:
      file.write("\n".join(code))

    run_cmd(["fasm", file_name + ".asm"])
    if not COMMANDLINE_ARGUMENTS["asm"]:
      run_cmd(["rm", file_name + ".asm"])

    run_cmd(["ld", file_name + ".o", "-o", file_name])
    if not COMMANDLINE_ARGUMENTS["object"]:
      run_cmd(["rm", file_name + ".o"])
  else:
    interpretation = Interpreter(module_name).interpret(ast.node, global_context)
    value, error = interpretation.value, interpretation.error

  if COMMANDLINE_ARGUMENTS["debug"] or COMMANDLINE_ARGUMENTS["context"]:
    print(str(global_context.variables))

  return value, error
