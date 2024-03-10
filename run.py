from tokens_list import global_context
from tokenize import Tokenizer
from parse import Parser
from interpret import Interpreter


def run(module_name: str, code: str, mods: dict = {"debug": False}):
  DEBUG = mods["debug"]

  tokens, error = Tokenizer(module_name, code).tokenize()
  if error or not tokens: return None, error

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
    print(str(global_context.variables))
    
  value, error = interpret.value, interpret.error

  return value, error
