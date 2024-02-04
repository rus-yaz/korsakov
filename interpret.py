from os import name as os_name
from os.path import realpath
from pathlib import Path

from errors_list import *
from nodes_list import *
from tokens_list import *
from types_list import *

PATH_SEPARATOR = "\\" if os_name == "nt" else "/"
LANGAUGE_PATH = __file__.rsplit(PATH_SEPARATOR, 1)[0]
BUILDIN_LIBRARIES = [
  str(file).rsplit(PATH_SEPARATOR, 1)[1]
  for file in Path(LANGAUGE_PATH).glob(f"*.{FILE_EXTENSION}")
]


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
    dictionary = Dictionary([], context)

    for key_node, element_node in node.element_nodes:
      key = key_node if context == global_symbol_table else response.register(self.interpret(key_node, context))
      if response.should_return():
        return response

      value = element_node if context == global_symbol_table else response.register(
        self.interpret(element_node, context))
      if response.should_return():
        return response
      dictionary.set(key, value)

      if response.should_return():
        return response

    return response.success(dictionary.set_position(node.position_start, node.position_end))

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

    if node.operator.matches_keyword(AND) and not left.is_true():
      return response.success(Number(0, context))
    elif node.operator.matches_keyword(OR) and left.is_true():
      return response.success(Number(1, context))

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

    else:
      return response.failure(RuntimeError(
        node.left_node.position_start, node.right_node.position_end,
        "Неизвестная операция", context
      ))

    if error:
      return response.failure(error)

    return response.success(result.set_position(node.position_start, node.position_end))

  # TODO: переделать реализаци инкремента/декремента из-за изменения алгоритма взятия элемента по индексу
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
    variable = node.variable
    value = context.symbol_table.get_variable(variable.value)

    if value == None:
      return response.failure(BadIdentifierError(
        node.variable.position_start, node.variable.position_end,
        f"Переменная \"{variable.value}\" не найдена"
      ))

    if node.keys:
      keys = node.keys.copy()

      while keys:
        if not isinstance(value, String | Dictionary | List):
          return response.failure(InvalidSyntaxError(
            variable.position_start, variable.position_end,
            f"Из типа \"{repr(value).split('(')[0]}\" нельзя взять элемент"
          ))

        key, *keys = keys
        if not isinstance(value, Object):
          key = response.register(self.interpret(key, context))
          if response.should_return():
            return response
        else:
          if not isinstance(key, VariableAccessNode) and key.token.type not in [IDENTIFIER, KEYWORD]:
            return response.failure(InvalidKeyError(
              key.token.position_start, key.token.position_end,
              "Ключ должен быть Идентификатором"
            ))
          key = response.register(self.interpret(StringNode(key.variable), context))

        if isinstance(value, Dictionary) and not isinstance(key, Number | String):
          return response.failure(InvalidSyntaxError(
            key.position_start, key.position_end,
            "Ключ должен иметь тип Число или Строка"
          ))
        if isinstance(value, List | String) and not isinstance(key, Number):
          return response.failure(InvalidSyntaxError(
            key.position_start, key.position_end,
            "Индекс должен иметь тип Число"
          ))
        elif response.should_return():
          return response

        is_dictionary = isinstance(value, Dictionary)
        value = value.get(key)

        if value == None:
          if is_dictionary:
            return response.failure(InvalidKeyError(key.position_start, key.position_end))

          return response.failure(IndexOutOfRangeError(key.position_start, key.position_end))

    if value == None:
      return response.failure(BadIdentifierError(node.position_start, node.position_end, f"`{variable.value}`"))

    return response.success(value.set_context(context).set_position(node.position_start, node.position_end))

  def interpret_VariableAssignNode(self, node: VariableAssignNode, context: Context):
    response = RuntimeResponse()
    variable = node.variable.copy()

    value = response.register(self.interpret(node.value_node, context))
    if response.should_return():
      return response

    if node.keys:
      item = context.symbol_table.get_variable(variable.value)
      if item == None:
        return response.failure(BadIdentifierError(variable.position_start, variable.position_end, variable.value))
      
      items = [item.copy()]
      keys = []
      
      for key in node.keys:
        if not isinstance(items[0], Object):
          key = response.register(self.interpret(key, context))
          if response.should_return():
            return response
        else:
          if not isinstance(key, VariableAccessNode) and key.token.type not in [IDENTIFIER, KEYWORD]:
            return response.failure(InvalidKeyError(
              key.token.position_start, key.token.position_end,
              "Ключ должен быть Идентификатором"
            ))
          key = response.register(self.interpret(StringNode(key.variable), context))

        keys += [key]

        if len(keys) == len(node.keys):
          break 
        
        if -len(items[0].value) < key.value >= len(items[0].value):
          return response.failure(IndexOutOfRangeError(node.position_start, node.position_end, key))

        item = items[0].get(key).copy()
        if not isinstance(item, String | Dictionary | List | Object):
          return response.failure(InvalidSyntaxError(
            node.variable.position_start, node.keys[-1].position_end,
            f"Из типа \"{repr(item).split('(')[0]}\" нельзя взять элемент"
          ))
        elif isinstance(items[0], String | List) and not isinstance(key, Number):
          return response.failure(InvalidSyntaxError(
            node.variable.position_start, node.keys[-1].position_end,
            f"Из типа \"{repr(item).split('(')[0]}\" можно взять элемент только по индексу"
          ))
        elif isinstance(items[0], Dictionary) and not isinstance(key, Number | String):
          return response.failure(InvalidSyntaxError(
            node.variable.position_start, node.keys[-1].position_end,
            f"Ключ должен быть Числом или Строкой, не {repr(key).split("(")}"
          ))

        items.insert(0, item)

      items.insert(0, value)

      for key in keys[::-1]:
        value = items.pop(0)
        if isinstance(items[0], String) and not isinstance(value, String):
          return response.failure(InvalidSyntaxError(
            node.variable.position_start, node.variable.position_end,
            f"Тип \"{repr(value).split('(')[0]}\" не может быть записан в строку"
          ))
        elif isinstance(items[0], List | String) and not isinstance(key, Number):
          return response.failure(InvalidSyntaxError(
            node.variable.position_start, node.variable.position_end,
            "Индекс должен иметь тип Число"
          ))
        elif isinstance(items[0], Dictionary) and not isinstance(key, Number | String):
          return response.failure(InvalidSyntaxError(
            node.variable.position_start, node.variable.position_end,
            "Ключ должен иметь тип Число или Строка"
          ))
        elif isinstance(items[0], List) and -len(items[0].value) < key.value >= len(items[0].value):
          return response.failure(IndexOutOfRangeError(node.position_start, node.position_end, key))
        items[0].set(key, value)

      value = items[0]

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
    if not isinstance(start_value, Number | List | String):
      return response.failure(InvalidSyntaxError(
        start_value.position_start, start_value.position_end,
        "Ожидались число, список или строка"
      ))

    if node.end_node:
      end_value = response.register(self.interpret(node.end_node, context))
      if response.should_return():
        return response
      if not isinstance(end_value, Number):
        return response.failure(InvalidSyntaxError(
          end_value.position_start, end_value.position_end,
          "Ожидалось число"
        ))
    else:
      end_value = Number(None)

    if node.step_node:
      step_value = response.register(self.interpret(node.step_node, context))
      if response.should_return():
        return response
      if not isinstance(step_value, Number):
        return response.failure(InvalidSyntaxError(
          step_value.position_start, step_value.position_end,
          "Ожидалось число"
        ))
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
      if not isinstance(start_value, String | List):
        return response.failure(InvalidSyntaxError(
          start_value.position_start, start_value.position_end,
          "Ожидались строка или список"
        ))
      while index < len(start_value.value):
        context.symbol_table.set_variable(node.variable_name.value, start_value.get(Number(index)))

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
      if node.return_null else
      List(elements, context).set_position(node.position_start, node.position_end)
    )

  def interpret_FunctionDefinitionNode(self, node: FunctionDefinitionNode, context: Context):
    response = RuntimeResponse()

    function_name = node.variable_name.value if node.variable_name else None
    body_node = node.body_node
    argument_names = list(map(lambda x: x.value, node.argument_names))
    function_value = Function(function_name, body_node, argument_names, node.auto_return, context).set_position(node.position_start, node.position_end)

    if node.variable_name:
      context.symbol_table.set_variable(function_name, function_value)

    return response.success(function_value)

  def interpret_MethodDefinitionNode(self, node: MethodDefinitionNode, context: Context):
    response = RuntimeResponse()

    function_name = node.variable_name.value if node.variable_name else None
    body_node = node.body_node
    argument_names = list(map(lambda x: x.value, node.argument_names))
    function_value = Method(
      function_name, body_node,
      argument_names, node.auto_return, context
    ).set_position(node.position_start, node.position_end)

    if node.variable_name:
      context.symbol_table.set_variable(function_name, function_value)

    return response.success(function_value)

  def interpret_ClassDefinitionNode(self, node: ClassDefinitionNode, context: Context):
    response = RuntimeResponse()
    class_name = node.variable_name.value
    methods = response.register(self.interpret(node.body_node, context))
    context.symbol_table.set_variable(class_name, Class(class_name, methods, context))
    return response.success(Number(None, context))

  def interpret_CallNode(self, node: CallNode, context: Context):
    response = RuntimeResponse()
    arguments = []

    call_node = response.register(self.interpret(node.call_node, context))

    if isinstance(call_node, Method):
      object_node = node.call_node
      object_node.keys = []
      first_argument = response.register(self.interpret(object_node, context))
      arguments += [first_argument]
    if response.should_return():
      return response

    for argument_node in node.argument_nodes:
      arguments += [response.register(self.interpret(argument_node, context))]
      if response.should_return():
        return response

    return_value = response.register(call_node.execute(arguments))
    if isinstance(call_node, Method):
      context.symbol_table.set_variable(object_node.variable.value, call_node.interal_context.symbol_table.get_variable(call_node.arguments_names[0]))
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

  def interpret_IncludeNode(self, node: IncludeNode, context: Context):
    from run import run

    response = RuntimeResponse()

    module_name = node.module.value

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
      module_path = f"{self.script_location}{PATH_SEPARATOR}{module_name.rsplit(PATH_SEPARATOR, 1)[0]}"
      files = list(map(lambda x: str(x).rsplit(PATH_SEPARATOR, 1)[-1], Path(module_path).glob(f"*.{FILE_EXTENSION}")))
      module_name = f"{module_name.rsplit(PATH_SEPARATOR, 1)[-1]}.{FILE_EXTENSION}"

      if module_name not in files:
        if module_name not in BUILDIN_LIBRARIES:
          return response.failure(ModuleNotFoundError(module.position_start, module.position_end, module_name))

        module_path = LANGAUGE_PATH

      with open(f"{module_path}{PATH_SEPARATOR}{module_name}") as file:
        _, error = run(f"{module_path}{PATH_SEPARATOR}{module_name}", file.read())
        if error:
          return response.failure(error)

    return response.success(Number(None, context))
