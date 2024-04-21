from os import name as os_name
from os.path import realpath
from pathlib import Path

from nodes import *
from loggers import *
from tokens import *
from classes import *

FILE_EXTENSIONS = ["корс", "kors"]
PATH_SEPARATOR = "\\" if os_name == "nt" else "/"
LANGAUGE_PATH = __file__.rsplit(PATH_SEPARATOR, 1)[0]
BUILDIN_LIBRARIES = [
  str(file).rsplit(PATH_SEPARATOR, 1)[1]
  for file_extension in FILE_EXTENSIONS
  for file in Path(LANGAUGE_PATH).glob(f"*.{file_extension}")
]


class Compiler:
  def __init__(self, file_name):
    self.file_path = realpath(file_name)
    self.script_location, self.file_name = self.file_path.rsplit(PATH_SEPARATOR, 1)
    self.stack = []
    self.code = []

  def compile(self, node, context: Context) -> Number:
    visitor = getattr(self, f"compile_{node.__class__.__name__}", self.no_compile_method)
    return visitor(node, context)

  def no_compile_method(self, node, context: Context) -> None:
    raise Exception(f"Метод compile_{type(node).__name__} не объявлен")

  def new_code(self, code_lines, name_of_operation=None):
    self.code += (["", f"; {name_of_operation}"] if name_of_operation else []) + code_lines

  def compile_NumberNode(self, node: NumberNode, context: Context):
    self.new_code([
      f"push {node.token.value}"
    ], "NumberNode")

  def compile_ListNode(self, node: ListNode, context: Context):
    for element in node.elements:
      self.compile(element, context)

  def compile_BinaryOperationNode(self, node: BinaryOperationNode, context: Context) -> Number:
    left = self.compile(node.left_node, context)
    right = self.compile(node.right_node, context)

    if node.operator.check_type(ADDITION):         operation = "add rax, rbx"
    elif node.operator.check_type(SUBTRACTION):    operation = "sub rax, rbx"
    elif node.operator.check_type(MULTIPLICATION): operation = "imul rbx"
    elif node.operator.check_type(DIVISION):       operation = "idiv rbx"
    # elif node.operator.check_type(POWER):          operation = " rax, rbx"
    # elif node.operator.check_type(ROOT):           operation = " rax, rbx"

    elif node.operator.check_type(EQUAL):          operation = "je"
    elif node.operator.check_type(NOT_EQUAL):      operation = "jne"
    elif node.operator.check_type(LESS):           operation = "jl"
    elif node.operator.check_type(MORE):           operation = "jm"
    elif node.operator.check_type(LESS_OR_EQUAL):  operation = "jle"
    elif node.operator.check_type(MORE_OR_EQUAL):  operation = "jme"

    elif node.operator.check_keyword(AND):         operation = "add rax, rbx"
    elif node.operator.check_keyword(OR):          operation = "add rax, rbx"

    else: operation = "push rbx"

    self.new_code([
        "pop rbx",
        "pop rax",
        operation,
        "push rax"
    ], "BinaryOperationNode")

  def compile_VariableAccessNode(self, node: VariableAccessNode, context: Context):
    variable = node.variable.value
    self.new_code([
      f"mov rax, [rbp - {8 * (self.stack.index(variable) + 1)}]",
      "push rax"
    ], "VariableAccessNode")

  def compile_VariableAssignNode(self, node: VariableAssignNode, context: Context):
    variable = node.variable.value

    self.compile(node.value, context)

    if variable not in self.stack:
      self.stack += [variable]

    self.new_code([
      "pop rax",
      f"mov [rbp - {8 * (self.stack.index(variable) + 1)}], rax",
      "sub rsp, 8"
    ], "VariableAssignNode")
