from errors_list import Position
from tokens_list import Token


class NumberNode:
  def __init__(self, token: Token):
    self.token = token
    self.position_start = self.token.position_start
    self.position_end = self.token.position_end


class StringNode:
  def __init__(self, token: Token):
    self.token = token
    self.position_start = self.token.position_start
    self.position_end = self.token.position_end


class DictionaryNode:
  def __init__(self, element_nodes: dict, position_start, position_end):
    self.element_nodes = element_nodes

    self.position_start = position_start
    self.position_end = position_end


class ListNode:
  def __init__(self, element_nodes: list, position_start, position_end):
    self.element_nodes = element_nodes

    self.position_start = position_start
    self.position_end = position_end


class UnaryOperationNode:
  def __init__(self, operator: Token, node: NumberNode):
    self.operator = operator
    self.node = node
    self.position_start = self.operator.position_start
    self.position_end = node.position_end


class BinaryOperationNode:
  def __init__(self, left_node, operator: Token, right_node):
    self.left_node = left_node
    self.operator = operator
    self.right_node = right_node
    self.position_start = self.left_node.position_start
    self.position_end = self.right_node.position_end


class VariableAccessNode:
  def __init__(self, variable: Token, keys: list, position_start: Position, position_end: Position):
    self.variable = variable
    self.keys = keys

    self.position_start = position_start
    self.position_end = position_end


class VariableAssignNode:
  def __init__(self, variable: Token, keys: list, value_node):
    self.variable = variable
    self.keys = keys
    self.value_node = value_node

    self.position_start = self.variable.position_start
    self.position_end = self.value_node.position_end


class CheckNode:
  def __init__(self, cases, else_case):
    self.cases = cases
    self.else_case = else_case

    self.position_start = self.cases[0][0].position_start
    self.position_end = (self.else_case or self.cases[-1])[0].position_end


class IfNode:
  def __init__(self, cases, else_case):
    self.cases = cases
    self.else_case = else_case

    self.position_start = self.cases[0][0].position_start
    self.position_end = (self.else_case or self.cases[-1])[0].position_end


class ForNode:
  def __init__(self, variable_name, start_node, end_node, step_node, body_node, return_null, else_case):
    self.variable_name = variable_name
    self.start_node = start_node
    self.end_node = end_node
    self.step_node = step_node
    self.body_node = body_node
    self.return_null = return_null
    self.else_case = else_case

    self.position_start = self.variable_name.position_start
    self.position_end = self.body_node.position_end


class WhileNode:
  def __init__(self, condition_node, body_node, return_null, else_case):
    self.condition_node = condition_node
    self.body_node = body_node
    self.should_return_null = return_null
    self.else_case = else_case

    self.position_start = self.condition_node.position_start
    self.position_end = self.body_node.position_end


class FunctionDefinitionNode:
  def __init__(self, variable_name, argument_names, body_node, should_auto_return):
    self.variable_name = variable_name
    self.argument_names = argument_names
    self.body_node = body_node
    self.should_auto_return = should_auto_return

    if self.variable_name:
      self.position_start = self.variable_name.position_start
    elif self.argument_names:
      self.position_start = self.argument_names[0].position_start
    else:
      self.position_start = self.body_node.position_start

    self.position_end = self.body_node.position_end


class FunctionCallNode:
  def __init__(self, callable_node, argument_nodes):
    self.call_node = callable_node
    self.argument_nodes = argument_nodes

    self.position_start: Position = self.call_node.position_start

    if self.argument_nodes:
      self.position_end: Position = self.argument_nodes[-1].position_end
    else:
      self.position_end: Position = self.call_node.position_end


class ReturnNode:
  def __init__(self, return_node, position_start, position_end):
    self.return_node = return_node

    self.position_start = position_start
    self.position_end = position_end


class ContinueNode:
  def __init__(self, position_start, position_end):
    self.position_start = position_start
    self.position_end = position_end


class BreakNode:
  def __init__(self, position_start, position_end):
    self.position_start = position_start
    self.position_end = position_end


class IncludeNode:
  def __init__(self, modules: list[Token], position_start, position_end):
    self.modules = modules

    self.position_start = position_start
    self.position_end = position_end
