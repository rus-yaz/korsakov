from interpret import Interpreter
from lex import Lexer
from parse import Parser
from tokens_list import global_context


def run(module_name: str, code: str, mods: dict = {"debug": False}):
  DEBUG = mods["debug"]

  lexer = Lexer(module_name, code)
  tokens, error = lexer.make_tokens()
  if error:
    return None, error

  if DEBUG:
    [print("[DEBUG]", i) for i in tokens]

  parser = Parser(tokens)
  ast = parser.parse()
  value, error = ast.node, ast.error
  if error:
    return None, error

  if DEBUG:
    print(value.element_nodes)

  interpreter = Interpreter(module_name)
  interpret = interpreter.interpret(value, global_context)

  if DEBUG:
    print(str(global_context.symbol_table))
  value, error = interpret.value, interpret.error

  return value, error
