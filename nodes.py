from loggers import Position

# --------------------------------------------------


class NumberNode:
  def __init__(self, token):
    self.token = token
    self.position_start = self.token.position_start
    self.position_end = self.token.position_end

  def __repr__(self):
    return f"NumberNode({self.token.value})"


class StringNode:
  def __init__(self, token):
    self.token = token
    self.position_start = self.token.position_start
    self.position_end = self.token.position_end

  def __repr__(self):
    return f"StringNode(\"{self.token.value}\")"


class ListNode:
  def __init__(self, element_nodes: list, position_start, position_end):
    self.element_nodes = element_nodes

    self.position_start = position_start
    self.position_end = position_end

  def __repr__(self):
    return f"ListNode(%({', '.join(map(str, self.element_nodes))})%)"


class DictionaryNode:
  def __init__(self, element_nodes: list, position_start, position_end):
    self.element_nodes = element_nodes

    self.position_start = position_start
    self.position_end = position_end

  def __repr__(self):
    return f"DictionaryNode(%({', '.join(f'{str(key)}: {str(value)}' for key, value in self.element_nodes)})%)"


# --------------------------------------------------


class UnaryOperationNode:
  def __init__(self, operator, node: NumberNode):
    self.operator = operator
    self.node = node

    self.position_start = self.operator.position_start
    self.position_end = node.position_end

  def __repr__(self):
    return f"UnaryOperationNode({self.operator}, {self.node})"


class BinaryOperationNode:
  def __init__(self, left_node, operator, right_node):
    self.left_node = left_node
    self.operator = operator
    self.right_node = right_node

    self.position_start = self.left_node.position_start
    self.position_end = self.right_node.position_end

  def __repr__(self):
    return f"BinaryOperationNode({self.left_node}, {self.operator}, {self.right_node})"


# --------------------------------------------------


class VariableAccessNode:
  def __init__(self, variable, keys: list, position_start: Position, position_end: Position):
    self.variable = variable
    self.keys = keys

    self.position_start = position_start
    self.position_end = position_end

  def __repr__(self):
    return f"VariableAccessNode({self.variable.value}, {self.keys})"


class VariableAssignNode:
  def __init__(self, variable, keys: list, value_node):
    self.variable = variable
    self.keys = keys
    self.value_node = value_node

    self.position_start = self.variable.position_start
    self.position_end = self.value_node.position_end

  def __repr__(self):
    return f"VariableAssignNode({self.variable.value}, {self.keys}, {self.value_node})"


# --------------------------------------------------


class CheckNode:
  def __init__(self, cases, else_case):
    self.cases = cases
    self.else_case = else_case

    self.position_start = self.cases[0][0].position_start
    self.position_end = (self.else_case or self.cases[-1])[0].position_end

  def __repr__(self):
    return f"CheckNode({self.cases}, {self.else_case})"


class IfNode:
  def __init__(self, cases, else_case):
    self.cases = cases
    self.else_case = else_case

    self.position_start = self.cases[0][0].position_start
    self.position_end = (self.else_case or self.cases[-1])[0].position_end

  def __repr__(self):
    return f"IfNode({self.cases}, {self.else_case})"


# --------------------------------------------------


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

  def __repr__(self):
    return f"ForNode({self.variable_name.value}, {self.start_node}, {self.end_node}, {self.step_node}, {self.body_node}, {self.return_null}, {self.else_case})"


class WhileNode:
  def __init__(self, condition_node, body_node, return_null, else_case):
    self.condition_node = condition_node
    self.body_node = body_node
    self.return_null = return_null
    self.else_case = else_case

    self.position_start = self.condition_node.position_start
    self.position_end = self.body_node.position_end

  def __repr__(self):
    return f"WhileNode({self.condition_node}, {self.body_node}, {self.return_null}, {self.else_case})"


# --------------------------------------------------


class FunctionDefinitionNode:
  def __init__(self, variable_name, argument_names, body_node, auto_return):
    self.variable_name = variable_name
    self.argument_names = argument_names
    self.body_node = body_node
    self.auto_return = auto_return

    if self.variable_name:
      self.position_start = self.variable_name.position_start
    elif self.argument_names:
      self.position_start = self.argument_names[0].position_start
    else:
      self.position_start = self.body_node.position_start

    self.position_end = self.body_node.position_end

  def __repr__(self):
    return f"FunctionDefinitionNode({self.variable_name.value}, {self.argument_names}, {self.body_node}, {self.auto_return})"


class ClassDefinitionNode:
  def __init__(self, variable_name, body_node, parents):
    self.variable_name = variable_name
    self.body_node = body_node
    self.parents = parents

    self.position_start = self.variable_name.position_start
    self.position_end = self.body_node.position_end

  def __repr__(self):
    return f"ClassDefinitionNode({self.variable_name.value}, {self.body_node})"


class MethodDefinitionNode:
  def __init__(self, variable_name, argument_names, body_node, auto_return, class_name="", object_name=""):
    self.variable_name = variable_name
    self.argument_names = argument_names
    self.body_node = body_node
    self.auto_return = auto_return
    self.class_name = class_name
    self.object_name = object_name

    if self.variable_name:
      self.position_start = self.variable_name.position_start
    elif self.argument_names:
      self.position_start = self.argument_names[0].position_start
    else:
      self.position_start = self.body_node.position_start

    self.position_end = self.body_node.position_end

  def __repr__(self):
    return f"MethodDefinitionNode({self.variable_name.value}, {self.argument_names}, {self.body_node}, {self.auto_return})"


class CallNode:
  def __init__(self, call_node, argument_nodes):
    self.call_node = call_node
    self.argument_nodes = argument_nodes

    self.position_start: Position = self.call_node.position_start

    if self.argument_nodes:
      self.position_end: Position = self.argument_nodes[-1].position_end
    else:
      self.position_end: Position = self.call_node.position_end

  def __repr__(self):
    return f"CallNode({self.call_node}, {self.argument_nodes})"


# --------------------------------------------------


class ReturnNode:
  def __init__(self, return_node, position_start, position_end):
    self.return_node = return_node

    self.position_start = position_start
    self.position_end = position_end

  def __repr__(self):
    return f"ReturnNode({self.return_node})"


class ContinueNode:
  def __init__(self, position_start, position_end):
    self.position_start = position_start
    self.position_end = position_end

  def __repr__(self):
    return f"ContinueNode"


class BreakNode:
  def __init__(self, position_start, position_end):
    self.position_start = position_start
    self.position_end = position_end

  def __repr__(self):
    return f"BreakNode"


# --------------------------------------------------

class DeleteNode:
  def __init__(self, variable, position_start, position_end):
    self.variable = variable

    self.position_start = position_start
    self.position_end = position_end


class IncludeNode:
  def __init__(self, module, position_start, position_end):
    self.module = module

    self.position_start = position_start
    self.position_end = position_end

  def __repr__(self):
    return f"IncludeNode({self.module.value})"
