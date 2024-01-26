from code import interact
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
    visitor = getattr(self, f"interpret_{node.__class__.__name__}", self.no_interpret_method)
    return visitor(node, context)

  def no_interpret_method(self, node, context: Context) -> None:
    raise Exception(f"Метод interpret_{type(node).__name__} не объявлен")

  def interpret_NumberNode(self, node: NumberNode, context: Context) -> Number:
    return RuntimeResponse().success(Number(node.token.value, context).set_position(node.position_start, node.position_end))

  def interpret_StringNode(self, node: StringNode, context: Context):
    return RuntimeResponse().success(String(node.token.value, context).set_position(node.position_start, node.position_end))

  def interpret_DictionaryNode(self, node: DictionaryNode, context: Context):
    response = RuntimeResponse()
    elements = {}

    for key_node, element_node in node.element_nodes.items():
      key = key_node if context == global_symbol_table else response.register(self.interpret(key_node, context))
      if response.should_return():
        return response

      value = element_node if context == global_symbol_table else response.register(
        self.interpret(element_node, context))
      if response.should_return():
        return response
      elements |= {key: value}

      if response.should_return():
        return response

    return response.success(Dictionary(elements, context).set_position(node.position_start, node.position_end))

  def interpret_ListNode(self, node: ListNode, context: Context):
    response = RuntimeResponse()
    elements = []

    for element_node in node.element_nodes:
      element = element_node if context == global_symbol_table else response.register(
        self.interpret(element_node, context))
      if response.should_return():
        return response

      elements += [element]

    return response.success(List(elements, context).set_position(node.position_start, node.position_end))

  def interpret_BinaryOperationNode(self, node: BinaryOperationNode, context: Context) -> Number:
    response = RuntimeResponse()
    error = None

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

    else:
      return response.failure(RuntimeError(
        node.left_node.position_start, node.right_node.position_end,
        "Не известная операция", context
      ))

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
      response.register(self.interpret(VariableAssignNode(
        node.node.variable,
        [],
        NumberNode(Token(INTEGER, result.value + 1, result.position_start))
      ), context))
      if node.operator.value:
        result, error = result.addition(Number(1))
    elif node.operator.type == DECREMENT:
      response.register(self.interpret(VariableAssignNode(
        node.node.variable,
        [],
        NumberNode(Token(INTEGER, result.value - 1, result.position_start))
      ), context))
      if node.operator.value:
        result, error = result.subtraction(Number(1))
    elif node.operator.matches_keyword(NOT):
      result, error = result.denial()

    if error:
      return response.failure(error)

    return response.success(result.set_position(node.position_start, node.position_end))

  def interpret_VariableAccessNode(self, node: VariableAccessNode, context: Context):
    response = RuntimeResponse()
    variable_name = node.variable.value
    value = context.symbol_table.get_variable(variable_name)
    if value == None:
      return response.failure(BadIdentifierError(
        node.variable.position_start, node.variable.position_end,
        f"Переменная \"{variable_name}\" не найдена"
      ))

    if node.keys:
      keys = node.keys.copy()

      while keys:
        if not isinstance(value, String | Dictionary | List):
          return response.failure(InvalidSyntaxError(
            node.variable.position_start, node.keys[-1].position_end,
            f"Из типа \"{repr(value).split('(')[0]}\" нельзя взять элемент"
          ))

        key, *keys = keys
        key = response.register(self.interpret(key, context))
        if response.should_return():
          return response

        key = key.value

        if isinstance(value, Dictionary):
          value = value.elements.symbol_table.get_variable(key)

          if value == None:
            return response.failure(InvalidKeyError(node.position_start, node.position_end))
        elif isinstance(value, List):
          if key < 0:
            key += len(value.value)

          if key >= len(value.value):
            return response.failure(IndexOutOfRangeError(node.position_start, node.position_end))

          value = list(value.elements.values())[key]
        elif isinstance(value, String):
          if key < 0:
            key += len(value.value)

          if key >= len(value.value):
            return response.failure(IndexOutOfRangeError(node.position_start, node.position_end))

          value = String(value.value[key])

    if value == None:
      return response.failure(BadIdentifierError(node.position_start, node.position_end, f"`{variable_name}`"))

    return response.success(value.set_context(context).set_position(node.position_start, node.position_end))

  def interpret_VariableAssignNode(self, node: VariableAssignNode, context: Context):
    response = RuntimeResponse()
    variable = node.variable.copy()

    value = response.register(self.interpret(node.value_node, context))
    if response.should_return():
      return response

    if node.keys:
      keys = []
      for key in node.keys:
        key = response.register(self.interpret(key, context))
        if response.should_return():
          return response

        keys += [key.value]

      elements = context.symbol_table.get_variable(variable.value)

      if isinstance(elements, List):
        items = [list(elements.elements.values())]
      elif isinstance(elements, Dictionary):
        items = [elements.elements.copy()]

      for key in keys[:-1]:
        if key >= len(items[0]):
          return response.failure(IndexOutOfRangeError(node.position_start, node.position_end, key))

        item = items[0][key]
        if not isinstance(item, String | Dictionary | List):
          return response.failure(InvalidSyntaxError(
            node.variable.position_start, node.keys[-1].position_end,
            f"Из типа \"{repr(value).split('(')[0]}\" нельзя взять элемент"
          ))

        if isinstance(item, List):
          item = list(item.elements.values())
        if isinstance(item, Dictionary):
          item = item.elements.copy()

        items.insert(0, item)

      items.insert(0, value)

      for key in keys[::-1]:
        value = items.pop(0)
        if isinstance(value, list):
          if key < 0:
            key += len(value)

          value = List(value, context)
        if isinstance(value, dict):
          value = Dictionary(value, context)

        if isinstance(items[0], list | dict):
          items[0][key] = value
        elif isinstance(items[0], str):
          items[0] = items[0][:key] + value + items[0][key + 1:]

      if isinstance(elements, List):
        value = List(items[0], context)
      elif isinstance(elements, Dictionary):
        value = Dictionary(items[0], context)

    context.symbol_table.set_variable(variable.value, value)
    return response.success(value)

  def interpret_CheckNode(self, node: CheckNode, context: Context):
    response = RuntimeResponse()
    done = False

    for case in node.cases:
      if not done and response.register(self.interpret(case[0], context)).value:
        done = True

      response.register(self.interpret(IfNode([case], None), context))
      if response.should_return() and not response.break_loop:
        return response

      if response.break_loop:
        break

    if not done and node.else_case:
      response.register(self.interpret(node.else_case[0], context))
      if response.should_return():
        return response

    return response.success(Number(None, context))

  def interpret_IfNode(self, node: IfNode, context: Context):
    response = RuntimeResponse()

    for condition, expression, return_null in node.cases:
      condition_value = response.register(self.interpret(condition, context))
      if response.should_return():
        return response

      if condition_value.is_true():
        expression_value = response.register(self.interpret(expression, context))

        if response.should_return():
          return response

        return response.success(Number(None, context) if return_null else expression_value)

    if node.else_case:
      expression, return_null = node.else_case
      else_case_value = response.register(self.interpret(expression, context))
      if response.should_return():
        return response

      return response.success(Number(None, context) if return_null else else_case_value)

    return response.success(Number(None, context))

  def interpret_ForNode(self, node: ForNode, context: Context):
    response = RuntimeResponse()
    elements = []

    start_value: Number | List | String = response.register(self.interpret(node.start_node, context))
    if response.should_return():
      return response

    if node.end_node:
      end_value = response.register(
        self.interpret(node.end_node, context))
      if response.should_return():
        return response
    else:
      end_value = Number(None)

    if node.step_node:
      step_value = response.register(self.interpret(node.step_node, context))
      if response.should_return():
        return response
    else:
      step_value = Number(1)

    if end_value.value != None:
      counter = start_value.value

      while counter < end_value.value if step_value.value > 0 else counter > end_value.value:
        context.symbol_table.set_variable(node.variable_name.value, Number(counter))

        value = [response.register(self.interpret(node.body_node, context))]
        if response.should_return() and not response.break_loop and not response.continue_loop:
          return response

        elements += value
        counter += step_value.value

        if response.continue_loop:
          continue
        if response.break_loop:
          break
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

        elements += [value]
        index += 1

        if response.continue_loop:
          continue
        if response.break_loop:
          break

    if node.else_case and not elements:
      expression, return_null = node.else_case
      else_case_value = response.register(self.interpret(expression, context))
      if response.should_return():
        return response

      return response.success(Number(None, context) if return_null else else_case_value)

    return response.success(
        Number(None, context)
        if node.return_null else
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

      elements += [value]

      if response.continue_loop:
        continue
      if response.break_loop:
        break

    if node.else_case and not elements:
      expression, return_null = node.else_case
      else_case_value = response.register(self.interpret(expression, context))
      if response.should_return():
        return response

      return response.success(Number(None, context) if return_null else else_case_value)

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
      function_name, body_node, argument_names, node.should_auto_return, context
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
