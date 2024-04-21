from nodes import *
from loggers import *
from tokens import *
from classes import *

class Compiler:
  def __init__(self, file_name):
    self.file_path = realpath(file_name)
    self.script_location, self.file_name = self.file_path.rsplit(PATH_SEPARATOR, 1)
    self.variables = []
    self.code = []

  def compile(self, node, context: Context) -> Number:
    visitor = getattr(self, f"compile_{node.__class__.__name__}", self.no_compile_method)
    return visitor(node, context)

  def no_compile_method(self, node, context: Context) -> None:
    raise Exception(f"Метод compile_{type(node).__name__} не объявлен")

  def compile_NumberNode(self, node: NumberNode, context: Context):
    self.code += [
      "; NumberNode",
      f"push {node.token.value}"
    ]

  def compile_ListNode(self, node: ListNode, context: Context):
    for element in node.elements:
      self.compile(element, context)

  def compile_BinaryOperationNode(self, node: BinaryOperationNode, context: Context) -> Number:
    left = self.compile(node.left_node, context)
    right = self.compile(node.right_node, context)

    self.code += [
      "; BinaryOperationNode",
      "pop rbx",
      "pop rax"
    ]

    if node.operator.check_type(ADDITION):         self.code += [f"add rax, rbx"]
    elif node.operator.check_type(SUBTRACTION):    self.code += [f"sub rax, rbx"]
    elif node.operator.check_type(MULTIPLICATION): self.code += [f"mul rax, rbx"]
    elif node.operator.check_type(DIVISION):       self.code += [f" rax, rbx"]
    elif node.operator.check_type(POWER):          self.code += [f" rax, rbx"]
    elif node.operator.check_type(ROOT):           self.code += [f" rax, rbx"]

    elif node.operator.check_type(EQUAL):          self.code += [f"je"]
    elif node.operator.check_type(NOT_EQUAL):      self.code += [f"jne"]
    elif node.operator.check_type(LESS):           self.code += [f"jb"]
    elif node.operator.check_type(MORE):           self.code += [f"ja"]
    elif node.operator.check_type(LESS_OR_EQUAL):  self.code += [f"j"]
    elif node.operator.check_type(MORE_OR_EQUAL):  self.code += [f""]

    elif node.operator.check_keyword(AND):         self.code += [f"add rax, rbx"]
    elif node.operator.check_keyword(OR):          self.code += [f"add rax, rbx"]

    self.code += ["push rax"]

  def compile_VariableAccessNode(self, node: VariableAccessNode, context: Context):
    variable = node.variable.value
    self.code += [
      "; VariableAccessNode",
      f"mov rax, [r15 - {8 * (self.variables[variable] + 1)}]",
      "push rax"
    ]

  def compile_VariableAssignNode(self, node: VariableAssignNode, context: Context):
    variable = node.variable.value

    value = self.compile(node.value, context)

    self.variables = {variable: len(self.variables)}
    print(self.variables)
    self.code += [
      "; VariableAssignNode",
    ]
