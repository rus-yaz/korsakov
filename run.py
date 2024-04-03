from interpreter import Interpreter
from parser import Parser
from tokenizer import Tokenizer
from tokens import global_context

COMMANDLINE_ARGUMENTS = dict.fromkeys(["debug", "nostd", "tokens", "ast", "context"], False)


def run(module_name: str, code: str):
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
    print(ast.node.element_nodes)

  # ------------------------------

  # Interpretation

  interpret = Interpreter(module_name).interpret(ast.node, global_context)
  if COMMANDLINE_ARGUMENTS["debug"] or COMMANDLINE_ARGUMENTS["context"]:
    print(str(global_context.variables))

  return interpret.value, interpret.error
