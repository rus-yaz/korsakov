from interpreter import Interpreter
from compiler import Compiler
from parser import Parser
from tokenizer import Tokenizer
from tokens import global_context

COMMANDLINE_ARGUMENTS = dict.fromkeys(["debug", "nostd", "tokens", "ast", "context"], False)


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

  # Interpretation

  interpret = Interpreter(module_name).interpret(ast.node, global_context)
  if COMMANDLINE_ARGUMENTS["debug"] or COMMANDLINE_ARGUMENTS["context"]:
    print(str(global_context.variables))

  return interpret.value, interpret.error
