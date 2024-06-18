from typing import Optional

from loggers import Position


class Node:
  def __init__(self, position_start, position_end):
    self.position_start = position_start
    self.position_end   = position_end

# --------------------------------------------------


class NumberNode(Node):
  def __init__(self, token):
    self.token = token

    super().__init__(token.position_start, token.position_end)

  def __repr__(self):
    return f"NumberNode({self.token.value})"


class StringNode(Node):
  def __init__(self, token):
    self.token = token

    super().__init__(token.position_start, token.position_end)

  def __repr__(self):
    return f"StringNode({self.token.value!r})"


class ListNode(Node):
  def __init__(self, elements: list, position_start=None, position_end=None):
    self.elements = elements

    super().__init__(position_start, position_end)

  def __repr__(self):
    return f"ListNode(%({'; '.join(map(str, self.elements))})%)"


class DictionaryNode(Node):
  def __init__(self, elements: list, position_start, position_end):
    self.elements = elements

    super().__init__(position_start, position_end)

  def __repr__(self):
    return f"DictionaryNode(%({'; '.join(f'{str(key)}: {str(value)}' for key, value in self.elements)})%)"


# --------------------------------------------------


class UnaryOperationNode(Node):
  def __init__(self, operator, node):
    self.operator = operator
    self.node     = node

    super().__init__(operator.position_start, node.position_end)

  def __repr__(self):
    return f"UnaryOperationNode({self.operator}; {self.node})"


class BinaryOperationNode(Node):
  def __init__(self, left_node, operator, right_node):
    self.left_node  = left_node
    self.operator   = operator
    self.right_node = right_node

    super().__init__(left_node.position_start, right_node.position_end)

  def __repr__(self):
    return f"BinaryOperationNode({self.left_node}; {self.operator}; {self.right_node})"


# --------------------------------------------------


class VariableAccessNode(Node):
  def __init__(self, variable, keys: Optional[list] = None):
    self.variable = variable
    self.keys     = keys if keys else []

    if self.variable:
      position_start = self.variable.value
    else:
      position_start = Position(0, 0, 0, "", "")

    if self.variable:
      position_end = self.variable.position_end
    elif self.keys:
      position_end = self.keys[-1].position_end
    else:
      position_end = Position(0, 0, 0, "", "")

    super().__init__(position_start, position_end)

  def __repr__(self):
    return f"VariableAccessNode({self.variable.value}; {self.keys})"


class VariableAssignNode(Node):
  def __init__(self, variable, keys: list, value):
    self.variable = variable
    self.keys     = keys
    self.value    = value

    super().__init__(variable.position_start, variable.position_end)

  def __repr__(self):
    return f"VariableAssignNode({self.variable.value}; {self.keys}; {self.value})"


# --------------------------------------------------


class CheckNode(Node):
  def __init__(self, cases, else_case):
    self.cases     = cases
    self.else_case = else_case

    super().__init__(cases[0][0].position_start, (else_case or cases[-1])[0].position_end)

  def __repr__(self):
    return f"CheckNode({self.cases}; {self.else_case})"


class IfNode(Node):
  def __init__(self, cases, else_case):
    self.cases     = cases
    self.else_case = else_case

    super().__init__(cases[0][0].position_start, (else_case or cases[-1])[0].position_end)

  def __repr__(self):
    return f"IfNode({self.cases}; {self.else_case})"


# --------------------------------------------------


class ForNode(Node):
  def __init__(self, variable_name, start_node, end_node, step_node, body_node, return_null, else_case):
    self.variable_name = variable_name
    self.start_node    = start_node
    self.end_node      = end_node
    self.step_node     = step_node
    self.body_node     = body_node
    self.return_null   = return_null
    self.else_case     = else_case

    super().__init__(variable_name.position_start, body_node.position_end)

  def __repr__(self):
    return f"ForNode({self.variable_name.value}; {self.start_node}; {self.end_node}; {self.step_node}; {self.body_node}; {self.return_null}; {self.else_case})"


class WhileNode(Node):
  def __init__(self, condition_node, body_node, return_null, else_case):
    self.condition_node = condition_node
    self.body_node      = body_node
    self.return_null    = return_null
    self.else_case      = else_case

    super().__init__(condition_node.position_start, body_node.position_end)

  def __repr__(self):
    return f"WhileNode({self.condition_node}; {self.body_node}; {self.return_null}; {self.else_case})"


# --------------------------------------------------


class FunctionDefinitionNode(Node):
  def __init__(self, variable_name, argument_names, body_node, auto_return):
    self.variable_name  = variable_name
    self.argument_names = argument_names
    self.body_node      = body_node
    self.auto_return    = auto_return

    super().__init__((variable_name or (argument_names and argument_names[0]) or body_node).position_start, body_node.position_end)

  def __repr__(self):
    return f"FunctionDefinitionNode({self.variable_name.value}; {self.argument_names}; {self.body_node}; {self.auto_return})"


class ClassDefinitionNode(Node):
  def __init__(self, variable_name, body_node, parents):
    self.variable_name = variable_name
    self.body_node     = body_node
    self.parents       = parents

    super().__init__(variable_name.position_start, body_node.position_end)

  def __repr__(self):
    return f"ClassDefinitionNode({self.variable_name.value}; {self.body_node})"


class MethodDefinitionNode(Node):
  def __init__(self, variable_name, argument_names, body_node, auto_return, class_name="", object_name=""):
    self.variable_name  = variable_name
    self.argument_names = argument_names
    self.body_node      = body_node
    self.auto_return    = auto_return
    self.class_name     = class_name
    self.object_name    = object_name

    super().__init__((variable_name or argument_names[0] or body_node).position_start, body_node.position_end)

  def __repr__(self):
    return f"MethodDefinitionNode({self.variable_name.value}; {self.argument_names}; {self.body_node}; {self.auto_return})"


class CallNode(Node):
  def __init__(self, call_node, argument_nodes):
    self.call_node      = call_node
    self.argument_nodes = argument_nodes

    super().__init__(call_node.position_start, argument_nodes[-1].position_end if argument_nodes else call_node.position_end)

  def __repr__(self):
    return f"CallNode({self.call_node}; {self.argument_nodes})"


# --------------------------------------------------


class ReturnNode(Node):
  def __init__(self, return_node, position_start, position_end):
    self.return_node = return_node

    super().__init__(position_start, position_end)

  def __repr__(self):
    return f"ReturnNode({self.return_node})"


class SkipNode(Node):
  def __repr__(self):
    return "SkipNode"


class BreakNode(Node):
  def __repr__(self):
    return "BreakNode"


# --------------------------------------------------

class DeleteNode(Node):
  def __init__(self, variable, position_start, position_end):
    self.variable = variable

    super().__init__(position_start, position_end)

  def __repr__(self):
    return f"DeleteNode({self.variable.value})"


class IncludeNode(Node):
  def __init__(self, module, position_start, position_end):
    self.module = module

    super().__init__(position_start, position_end)

  def __repr__(self):
    return f"IncludeNode({self.module.value})"
