from os import name as os_name
from os.path import realpath
from pathlib import Path

from classes import *
from loggers import *
from nodes import *
from tokens import *

FILE_EXTENSIONS = ["корс", "kors"]
PATH_SEPARATOR = "\\" if os_name == "nt" else "/"
LANGAUGE_PATH = __file__.rsplit(PATH_SEPARATOR, 1)[0]
BUILDIN_LIBRARIES = [
  str(file).rsplit(PATH_SEPARATOR, 1)[1]
  for file_extension in FILE_EXTENSIONS
  for file in Path(LANGAUGE_PATH).glob(f"*.{file_extension}")
]


class Interpreter:
  def __init__(self, file_name):
    self.file_path = realpath(file_name)
    self.script_location, self.file_name = self.file_path.rsplit(PATH_SEPARATOR, 1)

  def interpret(self, node, context: Context):
    visitor = getattr(self, f"interpret_{node.__class__.__name__}", self.no_interpret_method)
    return visitor(node, context)

  def no_interpret_method(self, node, _):
    raise Exception(f"Метод interpret_{type(node).__name__} не объявлен")

  def interpret_NumberNode(self, node: NumberNode, context: Context):
    return RuntimeLogger().success(Number(node.token.value, context).set_position(node.position_start, node.position_end))

  def interpret_StringNode(self, node: StringNode, context: Context):
    return RuntimeLogger().success(String(node.token.value, context).set_position(node.position_start, node.position_end))

  def interpret_DictionaryNode(self, node: DictionaryNode, context: Context):
    logger = RuntimeLogger()
    dictionary = Dictionary([], context)

    for key_node, element_node in node.elements:
      key = logger.register(self.interpret(key_node, context))
      if logger.should_return():
        return logger

      value = logger.register(self.interpret(element_node, context))
      if logger.should_return():
        return logger

      dictionary.set(key, value)
      if logger.should_return():
        return logger

    return logger.success(dictionary.set_position(node.position_start, node.position_end))

  def interpret_ListNode(self, node: ListNode, context: Context):
    logger = RuntimeLogger()
    elements = []

    for element_node in node.elements:
      element = logger.register(self.interpret(element_node, context))
      if logger.should_return():
        return logger

      elements += [element]

    return logger.success(List(elements, context).set_position(node.position_start, node.position_end))

  def interpret_BinaryOperationNode(self, node: BinaryOperationNode, context: Context):
    logger = RuntimeLogger()
    error = None

    left: Value = logger.register(self.interpret(node.left_node, context))
    if logger.should_return():
      return logger

    if node.operator.check_keyword(AND) and not left.is_true(): return logger.success(Number(0, context))
    elif node.operator.check_keyword(OR) and left.is_true():    return logger.success(Number(1, context))

    right: Value = logger.register(self.interpret(node.right_node, context))
    if logger.should_return():
      return logger

    if   node.operator.check_type(ADDITION):       result, error = left.addition(right)
    elif node.operator.check_type(SUBTRACTION):    result, error = left.subtraction(right)
    elif node.operator.check_type(MULTIPLICATION): result, error = left.multiplication(right)
    elif node.operator.check_type(DIVISION):       result, error = left.division(right)
    elif node.operator.check_type(POWER):          result, error = left.power(right)
    elif node.operator.check_type(ROOT):           result, error = left.root(right)

    elif node.operator.check_type(EQUAL):          result, error = left.equal(right)
    elif node.operator.check_type(NOT_EQUAL):      result, error = left.not_equal(right)
    elif node.operator.check_type(LESS):           result, error = left.less(right)
    elif node.operator.check_type(MORE):           result, error = left.more(right)
    elif node.operator.check_type(LESS_OR_EQUAL):  result, error = left.less_or_equal(right)
    elif node.operator.check_type(MORE_OR_EQUAL):  result, error = left.more_or_equal(right)

    elif node.operator.check_keyword(AND):         result, error = left.both(right)
    elif node.operator.check_keyword(OR):          result, error = left.some(right)

    else:
      return logger.failure(RuntimeError(
        node.left_node.position_start, node.right_node.position_end,
        "Неизвестная операция", context
      ))

    if error:
      return logger.failure(error)

    return logger.success(result.set_position(node.position_start, node.position_end))

  def interpret_UnaryOperationNode(self, node: UnaryOperationNode, context: Context):
    logger = RuntimeLogger()
    error = None

    result: Number = logger.register(self.interpret(node.node, context))
    if logger.should_return():
      return logger

    if node.operator.check_keyword(NOT):        result, error = result.denial()
    elif node.operator.check_type(SUBTRACTION): result, error = result.multiplication(Number(-1, context))
    elif node.operator.check_type(ROOT):        result, error = Number(2, context).root(result)

    elif node.operator.check_type(INCREMENT, DECREMENT):
      operation, method = [
        [lambda a, b: a - b, result.subtraction],
        [lambda a, b: a + b, result.addition]
      ][node.operator.check_type(INCREMENT)]

      logger.register(self.interpret(VariableAssignNode(node.node.variable, [], NumberNode(Token(INTEGER, operation(result.value, 1)))), context))

      # Проверка повышенного приоритета
      if node.operator.value:
        result, error = method(Number(1, context))

    if error:
      return logger.failure(error)

    return logger.success(result.set_position(node.position_start, node.position_end))

  def interpret_VariableAccessNode(self, node: VariableAccessNode, context: Context):
    logger = RuntimeLogger()
    variable = node.variable
    value = context.get_variable(variable.value)

    if value == None:
      return logger.failure(BadIdentifierError(
        node.variable.position_start, node.variable.position_end,
        f"Переменная \"{variable.value}\" не найдена"
      ))

    if node.keys:
      keys = node.keys.copy()

      while keys:
        if not isinstance(value, String | Dictionary | List):
          return logger.failure(InvalidSyntaxError(
            variable.position_start, variable.position_end,
            f"Из типа \"{repr(value).split('(')[0]}\" нельзя взять элемент"
          ))

        key, *keys = keys
        if not isinstance(value, Object):
          key = logger.register(self.interpret(key, context))
        else:
          if not isinstance(key, VariableAccessNode) and not key.token.check_type(IDENTIFIER, KEYWORD):
            return logger.failure(InvalidKeyError(
              key.token.position_start, key.token.position_end,
              "Ключ должен быть Идентификатором"
            ))

          key = logger.register(self.interpret(StringNode(key.variable), context))

        if logger.should_return():
          return logger

        if isinstance(value, Dictionary) and not isinstance(key, Number | String):
          return logger.failure(InvalidSyntaxError(key.position_start, key.position_end, "Ключ должен иметь тип Число или Строка"))
        if isinstance(value, List | String) and not isinstance(key, Number):
          return logger.failure(InvalidSyntaxError(key.position_start, key.position_end, "Индекс должен иметь тип Число"))

        is_dictionary = isinstance(value, Dictionary)
        list_value = value
        value = value.get(key)

        if value == None:
          if is_dictionary:
            return logger.failure(InvalidKeyError(key.position_start, key.position_end, key))

          return logger.failure(IndexOutOfRangeError(
            key.position_start, key.position_end,
            f"Длина массива - {len(list_value.value)}, индекс - {key}"
          ))

    return logger.success(value.set_context(context).set_position(node.position_start, node.position_end))

  def interpret_VariableAssignNode(self, node: VariableAssignNode, context: Context):
    logger = RuntimeLogger()
    variable = node.variable.copy()

    value = logger.register(self.interpret(node.value, context))
    if logger.should_return():
      return logger

    if node.keys:
      item = context.get_variable(variable.value)
      if item == None:
        return logger.failure(BadIdentifierError(variable.position_start, variable.position_end, variable.value))

      items = [item.copy()]
      keys = []

      for key in node.keys:
        if not isinstance(items[0], Object):
          key = logger.register(self.interpret(key, context))
          if logger.should_return():
            return logger
        else:
          if not isinstance(key, VariableAccessNode) and not key.token.check_type(IDENTIFIER, KEYWORD):
            return logger.failure(InvalidKeyError(
              key.token.position_start, key.token.position_end,
              "Ключ должен быть Идентификатором"
            ))
          key = logger.register(self.interpret(StringNode(key.variable), context))

        keys += [key]

        if len(keys) == len(node.keys):
          break

        if -len(items[0].value) < key.value >= len(items[0].value):
          return logger.failure(IndexOutOfRangeError(node.position_start, node.position_end, key))

        item = items[0].get(key).copy()
        if not isinstance(item, String | Dictionary | List | Object):
          return logger.failure(InvalidSyntaxError(
            node.variable.position_start, node.keys[-1].position_end,
            f"Из типа \"{repr(item).split('(')[0]}\" нельзя взять элемент"
          ))
        elif isinstance(items[0], String | List) and not isinstance(key, Number):
          return logger.failure(InvalidSyntaxError(
            node.variable.position_start, node.keys[-1].position_end,
            f"Из типа \"{repr(item).split('(')[0]}\" можно взять элемент только по индексу"
          ))
        elif isinstance(items[0], Dictionary) and not isinstance(key, Number | String):
          return logger.failure(InvalidSyntaxError(
            node.variable.position_start, node.keys[-1].position_end,
            f"Ключ должен быть Числом или Строкой, не {repr(key).split("(")}"
          ))

        items.insert(0, item)

      items.insert(0, value)

      for key in keys[::-1]:
        value = items.pop(0)
        if isinstance(items[0], String) and not isinstance(value, String):
          return logger.failure(InvalidSyntaxError(
            node.variable.position_start, node.variable.position_end,
            f"Тип \"{repr(value).split('(')[0]}\" не может быть записан в строку"
          ))
        elif isinstance(items[0], List | String) and not isinstance(key, Number):
          return logger.failure(InvalidSyntaxError(
            node.variable.position_start, node.variable.position_end,
            "Индекс должен иметь тип Число"
          ))
        elif isinstance(items[0], Dictionary) and not isinstance(key, Number | String):
          return logger.failure(InvalidSyntaxError(
            node.variable.position_start, node.variable.position_end,
            "Ключ должен иметь тип Число или Строка"
          ))
        elif isinstance(items[0], List) and -len(items[0].value) < key.value >= len(items[0].value):
          return logger.failure(IndexOutOfRangeError(node.position_start, node.position_end, key))

        items[0].set(key, value)

      value = items[0]

    context.set_variable(variable.value, value)
    return logger.success(value)

  def interpret_CheckNode(self, node: CheckNode, context: Context):
    logger = RuntimeLogger()
    done = False

    for case in node.cases:
      if not done and logger.register(self.interpret(case[0], context)).value:
        done = True

      logger.register(self.interpret(IfNode([case], None), context))
      if logger.should_return() and not logger.break_loop:
        return logger

      if logger.break_loop:
        break

    if not done and node.else_case:
      logger.register(self.interpret(node.else_case[0], context))
      if logger.should_return():
        return logger

    return logger.success(Number(None, context))

  def interpret_IfNode(self, node: IfNode, context: Context):
    logger = RuntimeLogger()

    for condition, expression, return_null in node.cases:
      condition_value = logger.register(self.interpret(condition, context))
      if logger.should_return():
        return logger

      if condition_value.is_true():
        expression_value = logger.register(self.interpret(expression, context))

        if logger.should_return():
          return logger

        return logger.success(Number(None, context) if return_null else expression_value)

    if node.else_case:
      expression, return_null = node.else_case

      else_case_value = logger.register(self.interpret(expression, context))
      if logger.should_return():
        return logger

      return logger.success(Number(None, context) if return_null else else_case_value)

    return logger.success(Number(None, context))

  def interpret_ForNode(self, node: ForNode, context: Context):
    logger = RuntimeLogger()
    elements = []

    start_value: Number | List | String = logger.register(self.interpret(node.start_node, context))
    if logger.should_return():
      return logger

    if not isinstance(start_value, Number | List | String):
      return logger.failure(InvalidSyntaxError(
        start_value.position_start, start_value.position_end,
        "Ожидались число, список или строка"
      ))

    if node.end_node:
      end_value = logger.register(self.interpret(node.end_node, context))
      if logger.should_return():
        return logger

      if not isinstance(end_value, Number):
        return logger.failure(InvalidSyntaxError(end_value.position_start, end_value.position_end, "Ожидалось число"))
    else:
      end_value = Number(None, context)

    if node.step_node:
      step_value = logger.register(self.interpret(node.step_node, context))
      if logger.should_return():
        return logger

      if not isinstance(step_value, Number):
        return logger.failure(InvalidSyntaxError(step_value.position_start, step_value.position_end, "Ожидалось число"))
    else:
      step_value = Number(1, context)

    # Случай хождения по массиву
    if end_value.value == None:
      iterator = 0
      if not isinstance(start_value, String | List):
        return logger.failure(InvalidSyntaxError(start_value.position_start, start_value.position_end, "Ожидались строка или список"))
    else:
      iterator = start_value.value

    while iterator < len(start_value.value) if end_value.value == None else iterator < end_value.value if step_value.value > 0 else iterator > end_value.value:
      step = context.set_variable(
        node.variable_name.value,
        start_value.get(Number(iterator, context))
        if end_value.value == None else
        Number(iterator, context)
      )

      value = logger.register(self.interpret(node.body_node, context))
      if logger.should_return() and not logger.break_loop and not logger.skip_iteration:
        return logger

      elements += [value]
      iterator += step_value.value

      if logger.skip_iteration: continue
      if logger.break_loop:    break

    if node.else_case and not elements:
      expression, return_null = node.else_case
      else_case_value = logger.register(self.interpret(expression, context))
      if logger.should_return():
        return logger

      return logger.success(Number(None, context) if return_null else else_case_value)

    return logger.success(
        Number(None, context)
        if node.return_null else
        List(elements, context).set_position(node.position_start, node.position_end)
    )

  def interpret_WhileNode(self, node: WhileNode, context: Context):
    logger = RuntimeLogger()
    elements = []

    while True:
      condition = logger.register(self.interpret(node.condition_node, context))
      if logger.should_return():
        return logger

      if not condition.is_true(): break

      value = [logger.register(self.interpret(node.body_node, context))]
      if logger.should_return() and not logger.break_loop and not logger.skip_iteration:
        return logger

      elements += [value]

      if logger.skip_iteration: continue
      if logger.break_loop: break

    if node.else_case and not elements:
      expression, return_null = node.else_case
      else_case_value = logger.register(self.interpret(expression, context))
      if logger.should_return():
        return logger

      return logger.success(Number(None, context) if return_null else else_case_value)

    return logger.success(
      Number(None, context).set_position(node.position_start, node.position_end)
      if node.return_null else
      List(elements, context).set_position(node.position_start, node.position_end)
    )

  def interpret_FunctionDefinitionNode(self, node: FunctionDefinitionNode, context: Context):
    logger = RuntimeLogger()

    function_name = node.variable_name.value if node.variable_name else None
    body_node = node.body_node
    argument_names = node.argument_names
    function_value = Function(
      function_name, body_node, argument_names, node.auto_return, context
    ).set_position(node.position_start, node.position_end)

    if function_name:
      context.set_variable(function_name, function_value)

    return logger.success(function_value)

  def interpret_MethodDefinitionNode(self, node: MethodDefinitionNode, context: Context):
    logger = RuntimeLogger()

    function_name = node.variable_name.value if node.variable_name else None
    body_node = node.body_node
    argument_names = node.argument_names
    function_value = Method(
      function_name, body_node,
      argument_names, node.auto_return, context
    ).set_position(node.position_start, node.position_end)

    if node.variable_name:
      context.set_variable(function_name, function_value)

    return logger.success(function_value)

  def interpret_ClassDefinitionNode(self, node: ClassDefinitionNode, context: Context):
    logger = RuntimeLogger()
    class_name = node.variable_name.value
    methods = logger.register(self.interpret(node.body_node, context))
    parents = node.parents

    context.set_variable(class_name, Class(class_name, methods, parents, context))

    return logger.success(Number(None, context))

  def interpret_CallNode(self, node: CallNode, context: Context):
    logger = RuntimeLogger()
    arguments = []

    call_node = logger.register(self.interpret(node.call_node, context))
    if logger.should_return():
      return logger

    if isinstance(call_node, Method):
      object_node = node.call_node
      object_node.keys = []
      arguments += [logger.register(self.interpret(object_node, context))]
      if logger.should_return():
        return logger

    for argument_node in node.argument_nodes:
      if isinstance(argument_node, VariableAssignNode):
        arguments += [argument_node]
        continue

      arguments += [logger.register(self.interpret(argument_node, context))]
      if logger.should_return():
        return logger

    return_value = logger.register(call_node.execute(arguments))
    if logger.should_return():
      return logger

    if isinstance(call_node, Method):
      context.set_variable(
        object_node.variable.value,
        call_node.internal_context.get_variable(call_node.argument_names[0].variable.value)
      )

    return logger.success(return_value)

  def interpret_ReturnNode(self, node: ReturnNode, context: Context):
    logger = RuntimeLogger()

    if node.return_node:
      value = logger.register(self.interpret(node.return_node, context))
      if logger.should_return():
        return logger
    else:
      value = Number(None, context)

    return logger.return_signal(value)

  def interpret_SkipNode(self, node: SkipNode, context: Context):
    return RuntimeLogger().skip_signal()

  def interpret_BreakNode(self, node: BreakNode, context: Context):
    return RuntimeLogger().break_signal()

  def interpret_DeleteNode(self, node: DeleteNode, context: Context):
    context.delete_variable(node.variable.value)

    return RuntimeLogger().success(Number(None, context))

  def interpret_IncludeNode(self, node: IncludeNode, context: Context):
    from run import run

    logger = RuntimeLogger()
    module_name = node.module.value

    if module_name.endswith("*"):
      if PATH_SEPARATOR in module_name:
        module_name, depth = module_name.rsplit(PATH_SEPARATOR, 1)
      else:
        depth = module_name

      module_path = f"{self.script_location}{PATH_SEPARATOR}{module_name}"

      get_files = getattr(Path(module_path), "glob" if depth == "*" else "rglob")
      files = [list(map(str, get_files(f"*.{file_extension}"))) for file_extension in FILE_EXTENSIONS]
      files = [file for files_line in files for file in files_line]
      if self.file_path in files:
        files.remove(self.file_path)

      for file_path in files:
        with open(file_path) as file:
          _, error = run(file_path, file.read())
          if error:
            return logger.failure(error)
    else:
      module_path = f"{self.script_location}{PATH_SEPARATOR}{module_name.rsplit(PATH_SEPARATOR, 1)[0]}"
      files = [list(map(lambda x: str(x).rsplit(PATH_SEPARATOR, 1)[-1], Path(module_path).glob(f"*.{file_extension}"))) for file_extension in FILE_EXTENSIONS]
      files = [file for files_line in files for file in files_line]
      module_name = f"{module_name.rsplit(PATH_SEPARATOR, 1)[-1]}"

      found = False
      for file in files:
        if file.rsplit(".", 1)[0] == module_name:
          module_name = file
          found = True
          break

      if not found:
        for file in BUILDIN_LIBRARIES:
          if file.rsplit(".", 1)[0] == module_name:
            module_name = file
            module_path = LANGAUGE_PATH
            found = True
            break

      if not found:
        return logger.failure(ModuleNotFoundError(node.module.position_start, node.module.position_end, module_name))

      with open(f"{module_path}{PATH_SEPARATOR}{module_name}") as file:
        _, error = run(f"{module_path}{PATH_SEPARATOR}{module_name}", file.read())
        if error:
          return logger.failure(error)

    return logger.success(Number(None, context))
