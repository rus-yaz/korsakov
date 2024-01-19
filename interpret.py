from os import name as os_name
from os.path import realpath
from pathlib import Path

from errors_list import *
from nodes_list import *
from tokens_list import *
from types_list import *

PATH_SEPARATOR = "\\" if os_name == "nt" else "/"
LANGAUGE_PATH = __file__.rsplit(PATH_SEPARATOR, 1)[0]
BUILDIN_LIBRARIES = {
  str(file).rsplit(PATH_SEPARATOR, 1)[1].removesuffix(f".{FILE_EXTENSION}"): str(file)
  for file in Path(LANGAUGE_PATH).glob(f"*.{FILE_EXTENSION}")
}


class Interpreter:
  def __init__(self, file_name):
    self.file_path = realpath(file_name)
    self.script_location, self.file_name = self.file_path.rsplit(PATH_SEPARATOR, 1)

  def interpret(self, node, context: Context) -> Number:
    method = f"interpret_{type(node).__name__}"
    visitor = getattr(self, method, self.no_interpret_method)
    return visitor(node, context)

  def no_interpret_method(self, node, context: Context) -> None:
    raise Exception(f"Метод interpret_{type(node).__name__} не объявлен")

  def interpret_NumberNode(self, node: NumberNode, context: Context) -> Number:
    return RuntimeResponse().success(Number(node.token.value, context).set_position(node.position_start, node.position_end))

  def interpret_StringNode(self, node: StringNode, context: Context):
    return RuntimeResponse().success(String(node.token.value, context).set_position(node.position_start, node.position_end))

  def interpret_ListNode(self, node: ListNode, context: Context):
    response = RuntimeResponse()
    elements = []

    for element_node in node.element_nodes:
      elements += [
        element_node
        if context == global_symbol_table else
        response.register(self.interpret(element_node, context))
      ]

      if response.should_return():
        return response

    return response.success(List(elements, context).set_position(node.position_start, node.position_end))

  def interpret_BinaryOperationNode(self, node: BinaryOperationNode, context: Context) -> Number:
    response = RuntimeResponse()

    left: Value = response.register(self.interpret(node.left_node, context))
    if response.should_return():
      return response

    right: Value = response.register(self.interpret(node.right_node, context))
    if response.should_return():
      return response

    if node.operator.type == ADDITION:
      result, error = left.addition(right)
    elif node.operator.type == SUBSTRACION:
      result, error = left.subtraction(right)
    elif node.operator.type == MULTIPLICATION:
      result, error = left.multiplication(right)
    elif node.operator.type == DIVISION:
      result, error = left.division(right)
    elif node.operator.type == POWER:
      result, error = left.power(right)
    elif node.operator.type == ROOT:
      result, error = left.root(right)

    elif node.operator.type == EQUAL:
      result, error = left.equal(right)
    elif node.operator.type == NOT_EQUAL:
      result, error = left.not_equal(right)
    elif node.operator.type == LESS:
      result, error = left.less(right)
    elif node.operator.type == MORE:
      result, error = left.more(right)
    elif node.operator.type == LESS_OR_EQUAL:
      result, error = left.less_or_equal(right)
    elif node.operator.type == MORE_OR_EQUAL:
      result, error = left.more_or_equal(right)

    elif node.operator.matches_keyword(AND):
      result, error = left.both(right)
    elif node.operator.matches_keyword(OR):
      result, error = left.some(right)
    elif node.operator.matches_keyword(NOT):
      result, error = left.denial(right)

    if error:
      return response.failure(error)

    return response.success(result.set_position(node.position_start, node.position_end))

  def interpret_UnaryOperationNode(self, node: UnaryOperationNode, context: Context) -> Number:
    response = RuntimeResponse()

    result: Number = response.register(self.interpret(node.node, context))
    if response.should_return():
      return response
    error = None

    if node.operator.type == SUBSTRACION:
      result, error = result.multiplication(Number(-1))
    elif node.operator.type == ROOT:
      result, error = Number(2).root(result)

    elif node.operator.type == INCREMENT:
      self.interpret(VariableAssignNode(
        node.node.variable_name,
        NumberNode(Token(INTEGER, result.value + 1, result.position_start))), context)
      if node.operator.value:
        result, error = result.addition(Number(1))
    elif node.operator.type == DECREMENT:
      self.interpret(VariableAssignNode(
        node.node.variable_name,
        NumberNode(Token(INTEGER, result.value - 1, result.position_start))
      ), context)
      if node.operator.value:
        result, error = result.subtraction(Number(1))
    elif node.operator.matches_keyword(NOT):
      result, error = result.denial()

    if error:
      return response.failure(error)

    return response.success(result.set_position(node.position_start, node.position_end))

  def interpret_VariableAccessNode(self, node: VariableAccessNode, context: Context):
    response = RuntimeResponse()
    variable_name = node.variable_name.value

    if "." in variable_name:
      name, *indexes = variable_name.split(".")
      value: List = context.symbol_table.get_variable(name)

      indexes = [
        int(index)
        if index.isdigit() or index[0] == "-" else
        context.symbol_table.get_variable(index).value
        for index in indexes
      ]

      while indexes:
        index, *indexes = indexes

        if isinstance(value, List):
          value = list(value.elements.values())[index]
        elif isinstance(value, String):
          value = String(value.value[index])
    else:
      value = context.symbol_table.get_variable(variable_name)

    if value == None:
      return response.failure(BadIdentifierError(node.position_start, node.position_end, f"`{variable_name}`"))

    return response.success(value.set_context(context).set_position(node.position_start, node.position_end))

  def interpret_VariableAssignNode(self, node: VariableAssignNode, context: Context):
    response = RuntimeResponse()
    variable_name = node.variable_name.copy()

    if isinstance(node.value_node, ListNode):
      value = response.register(self.interpret(ListNode(
        node.value_node.element_nodes,
        variable_name,
        node.position_start,
        node.position_end
      ), context))
    else:
      value = response.register(self.interpret(node.value_node, context))

    if response.should_return():
      return response

    if "." in variable_name.value:
      variable_name.value, *keys = variable_name.value.split(".")
      keys = [
        int(key)
        if key.isdigit() or key[0] == "-" else
        context.symbol_table.get_variable(key).value
        for key in keys
      ]

      elements: dict = context.symbol_table.get_variable(variable_name.value)

      items = [list(elements.elements.values())]

      for key in keys[:-1]:
        if key >= len(items[0]):
          return response.failure(IndexOutOfRangeError(node.position_start, node.position_end, key))

        item = items[0][key]

        if isinstance(item, List):
          item = list(item.elements.values())

        items.insert(0, item)

      items.insert(0, value)

      for key in keys[::-1]:
        value = items.pop(0)
        if isinstance(value, list):
          if key < 0:
            key += len(value)

          value = List(value)

        items[0][key] = value

      value = List(items[0])

    context.symbol_table.set_variable(variable_name.value, value)
    return response.success(value)

  def interpret_IfNode(self, node: IfNode, context: Context):
    response = RuntimeResponse()

    for condition, expression, should_return_null in node.cases:
      condition_value = response.register(self.interpret(condition, context))
      if response.should_return():
        return response

      if condition_value.is_true():
        expression_value = response.register(self.interpret(expression, context))

        if response.should_return():
          return response

        return response.success(Number(None, context) if should_return_null else expression_value)

    if node.else_case:
      expression, should_return_null = node.else_case
      else_case_value = response.register(self.interpret(expression, context))
      if response.should_return():
        return response

      return response.success(Number(None, context) if should_return_null else else_case_value)

    return response.success(Number(None, context))

  def interpret_ForNode(self, node: ForNode, context: Context):
    response = RuntimeResponse()
    elements = []

    start_value: Number | List | String = response.register(self.interpret(node.start_value_node, context))
    if response.should_return():
      return response

    if node.end_value_node:
      end_value = response.register(
        self.interpret(node.end_value_node, context))
      if response.should_return():
        return response
    else:
      end_value = None

    if node.step_value_node:
      step_value = response.register(self.interpret(node.step_value_node, context))
      if response.should_return():
        return response
    else:
      step_value = Number(1)

    if end_value != None:
      index = start_value.value

      while index < end_value.value if step_value.value > 0 else index > end_value.value:
        context.symbol_table.set_variable(node.variable_name.value, Number(index))

        value = [response.register(self.interpret(node.body_node, context))]
        if response.should_return() and not response.break_loop and not response.continue_loop:
          return response

        if response.continue_loop:
          continue
        if response.break_loop:
          break

        elements += value
        index += step_value.value
    else:
      index = 0
      while index < len(start_value.value):
        context.symbol_table.set_variable(
          node.variable_name.value,
          String(start_value.value[index])
          if isinstance(start_value, String) else
          start_value.elements[index]
        )

        value = response.register(self.interpret(node.body_node, context))
        if response.should_return() and not response.break_loop and not response.continue_loop:
          return response

        if response.continue_loop:
          continue
        if response.break_loop:
          break

        elements += [value]
        index += 1

    return response.success(
        Number(None, context)
        if node.should_return_null else
        List(elements, context).set_position(node.position_start, node.position_end)
    )

  def interpret_WhileNode(self, node: WhileNode, context: Context):
    response = RuntimeResponse()
    elements = []

    while True:
      condition = response.register(self.interpret(node.condition_node, context))
      if response.should_return():
        return response

      if not condition.is_true():
        break

      value = [response.register(self.interpret(node.body_node, context))]
      if response.should_return() and not response.break_loop and not response.continue_loop:
        return response

      if response.continue_loop:
        continue
      if response.break_loop:
        break

      elements += [value]

    return response.success(
        Number(None, context).set_position(node.position_start, node.position_end)
        if node.should_return_null else
        List(elements, context).set_position(node.position_start, node.position_end)
    )

  def interpret_FunctionDefinitionNode(self, node: FunctionDefinitionNode, context: Context):
    response = RuntimeResponse()

    function_name = node.variable_name.value if node.variable_name else None
    body_node = node.body_node
    argument_names = list(map(lambda x: x.value, node.argument_names))
    function_value = Function(
      function_name,
      body_node,
      argument_names,
      node.should_auto_return,
      context
    ).set_position(node.position_start, node.position_end)

    if node.variable_name:
      context.symbol_table.set_variable(function_name, function_value)

    return response.success(function_value)

  def interpret_FunctionCallNode(self, node: FunctionCallNode, context: Context):
    response = RuntimeResponse()
    arguments = []

    call_value: Function = response.register(self.interpret(node.call_node, context))
    if response.should_return():
      return response

    for argument_node in node.argument_nodes:
      arguments += [response.register(self.interpret(argument_node, context))]
      if response.should_return():
        return response

    return_value = response.register(call_value.execute(arguments))
    if response.should_return():
      return response

    return response.success(return_value)

  def interpret_ReturnNode(self, node: ReturnNode, context: Context):
    response = RuntimeResponse()

    if node.return_node:
      value = response.register(self.interpret(node.return_node, context))
      if response.should_return():
        return response
    else:
      value = Number(None, context)

    return response.success_return(value)

  def interpret_ContinueNode(self, node: ContinueNode, context: Context):
    return RuntimeResponse().success_continue()

  def interpret_BreakNode(self, node: BreakNode, context: Context):
    return RuntimeResponse().success_break()

  # Recursion including
  def interpret_IncludeNode(self, node: IncludeNode, context: Context):
    from run import run

    response = RuntimeResponse()

    for module in node.modules:
      module_name = module.value

      if module_name.endswith("*"):
        if PATH_SEPARATOR in module_name:
          module_name, depth = module_name.rsplit(PATH_SEPARATOR, 1)
        else:
          depth = module_name
        module_path = f"{self.script_location}{PATH_SEPARATOR}{module_name}"

        get_files = getattr(Path(module_path), "glob" if depth == "*" else "rglob")
        files = list(map(str, get_files(f"*.{FILE_EXTENSION}")))
        if self.file_path in files:
          files.remove(self.file_path)

        for file_path in files:
          with open(file_path) as file:
            _, error = run(file_path, file.read())
            if error:
              return response.failure(error)
      else:
        module_path = f"{self.script_location}{PATH_SEPARATOR}{module_name}.{FILE_EXTENSION}"
        files = list(map(str, Path(self.script_location).glob(f"*.{FILE_EXTENSION}")))

        if module_path not in files:
          if module_name not in BUILDIN_LIBRARIES:
            return response.failure(ModuleNotFoundError(module.position_start, module.position_end, module_name))

          module_path = BUILDIN_LIBRARIES[module_name]

        with open(module_path) as file:
          _, error = run(module_path, file.read())
          if error:
            return response.failure(error)

    return response.success(Number(None, context))
