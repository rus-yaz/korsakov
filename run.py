from interpret import Interpreter
from lex import Lexer
from parse import Parser
from tokens_list import global_context


def run(module_name: str, code: str, mods: dict = {"debug": False}):
  DEBUG = mods["debug"]

  tokens, error = Lexer(module_name, code).make_tokens()
  if error:
    return None, error
  if not tokens:
    return None, None

  if DEBUG:
    [print("[DEBUG]", i) for i in tokens]

  ast = Parser(tokens).parse()
  value, error = ast.node, ast.error
  if error:
    return None, error

  if DEBUG:
    print(value.element_nodes)

  interpret = Interpreter(module_name).interpret(value, global_context)

  if DEBUG:
    print(str(global_context.symbol_table))
  value, error = interpret.value, interpret.error

  return value, error
