from os import name as os_name
from os import system

from context import Context, SymbolTable
from errors_list import RuntimeError
from runtime_response import RuntimeResponse


class Value:
  def __init__(self):
    self.set_position()
    self.set_context()

  def set_position(self, position_start=None, position_end=None):
    self.position_start = position_start
    self.position_end = position_end
    return self

  def set_context(self, context=None):
    self.context = context
    return self

  def is_true(self):
    return False

  def addition(self, operand):
    return None, self.illegal_operation(operand)

  def subtraction(self, operand):
    return None, self.illegal_operation(operand)

  def multiplication(self, operand):
    return None, self.illegal_operation(operand)

  def division(self, operand):
    return None, self.illegal_operation(operand)

  def power(self, operand):
    return None, self.illegal_operation(operand)

  def root(self, operand):
    return None, self.illegal_operation(operand)

  def increment(self, operand):
    return None, self.illegal_operation(operand)

  def decrement(self, operand):
    return None, self.illegal_operation(operand)

  def equal(self, operand):
    return None, self.illegal_operation(operand)

  def not_equal(self, operand):
    return None, self.illegal_operation(operand)

  def less(self, operand):
    return None, self.illegal_operation(operand)

  def more(self, operand):
    return None, self.illegal_operation(operand)

  def less_or_equal(self, operand):
    return None, self.illegal_operation(operand)

  def more_or_equal(self, operand):
    return None, self.illegal_operation(operand)

  def both(self, operand):
    return None, self.illegal_operation(operand)

  def some(self, operand):
    return None, self.illegal_operation(operand)

  def denial(self, operand):
    return None, self.illegal_operation(operand)

  def execute(self, arguments):
    return RuntimeResponse().failure(self.illegal_operation())

  def copy(self):
    raise Exception("Метод копирования не определён")

  def illegal_operation(self, operand=None):
    if not operand:
      operand = self

    return RuntimeError(
      self.position_start, operand.position_end,
      "Неизвестная операция",
      self.context
    )


class Number(Value):
  def __init__(self, value=0, context=None):
    super().__init__()
    self.value = int(value) if isinstance(value, bool) else value
    self.context = context

  def __str__(self):
    return str(self.value)

  def __repr__(self):
    return f"Число({self.value})"

  def is_true(self):
    return self.value != 0

  def addition(self, operand):
    if isinstance(operand, Number):
      return Number(self.value + operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def subtraction(self, operand):
    if isinstance(operand, Number):
      return Number(self.value - operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def multiplication(self, operand):
    if isinstance(operand, List | Number | String):
      return Number(self.value * operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def division(self, operand):
    if isinstance(operand, Number):
      if operand.value:
        return Number(self.value / operand.value, self.context), None

      return None, RuntimeError(
        operand.position_start, operand.position_end,
        "Деление на ноль",
        self.context
      )

    return None, Value.illegal_operation(self, operand)

  def power(self, operand):
    if isinstance(operand, Number):
      return Number(self.value ** operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def root(self, operand):
    if isinstance(operand, Number):
      return Number(operand.value ** (1 / self.value), self.context), None

    return None, Value.illegal_operation(self, operand)

  def equal(self, operand):
    if isinstance(operand, Number):
      return Number(self.value == operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def not_equal(self, operand):
    if isinstance(operand, Number):
      return Number(self.value != operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def less(self, operand):
    if isinstance(operand, Number):
      return Number(self.value < operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def more(self, operand):
    if isinstance(operand, Number):
      return Number(self.value > operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def less_or_equal(self, operand):
    if isinstance(operand, Number):
      return Number(self.value <= operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def more_or_equal(self, operand):
    if isinstance(operand, Number):
      return Number(self.value >= operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def both(self, operand):
    if isinstance(operand, Number):
      return Number(self.value and operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def some(self, operand):
    if isinstance(operand, Number):
      return Number(self.value or operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def denial(self):
    return Number(not self.is_true(), self.context), None

  def copy(self):
    copy = Number(self.value, self.context)
    copy.set_position(self.position_start, self.position_end)
    return copy


class String(Value):
  def __init__(self, value="", context=None):
    super().__init__()
    self.value = value
    self.context = context

  def __str__(self):
    return self.value

  def __repr__(self):
    return f"Строка(\"{self.value}\")"

  def is_true(self):
    return self.value != ""

  def addition(self, operand):
    if isinstance(operand, String):
      return String(self.value + operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def multiplication(self, operand):
    if isinstance(operand, Number):
      return String(self.value * operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def division(self, operand):
    if isinstance(operand, Number):
      return String(self.value[operand.value], self.context), None

    return None, Value.illegal_operation(self, operand)

  def equal(self, operand):
    if isinstance(operand, String):
      return Number(self.value == operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def not_equal(self, operand):
    if isinstance(operand, String):
      return Number(self.value != operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def less(self, operand):
    if isinstance(operand, String):
      return Number(self.value < operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def more(self, operand):
    if isinstance(operand, String):
      return Number(self.value > operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def less_or_equal(self, operand):
    if isinstance(operand, String):
      return Number(self.value <= operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def more_or_equal(self, operand):
    if isinstance(operand, String):
      return Number(self.value >= operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def both(self, operand):
    if isinstance(operand, String):
      return Number(self.value and operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def some(self, operand):
    if isinstance(operand, String):
      return Number(self.value or operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def denial(self):
    return Number(not self.is_true(), self.context), None

  def copy(self):
    copy = String(self.value, self.context)
    copy.set_position(self.position_start, self.position_end)
    return copy


class List(Value):
  def __init__(self, elements, context=None):
    super().__init__()
    self.value: list = [element.value if hasattr(
      element, "value") else element for element in elements]
    self.elements: dict = {index: element for index,
                           element in enumerate(elements)}
    self.context = context

  def __str__(self):
    return "%(" + ", ".join(map(str, self.value)) + ")%"

  def __repr__(self):
    return f"Список({self.value})"

  def is_true(self):
    return self.value != []

  def addition(self, operand):
    if isinstance(operand, List):
      elements = self.value.copy()
      elements += operand.value.copy()

      return List(elements, self.context), None

    return None, Value.illegal_operation(self, operand)

  def multiplication(self, operand):
    if isinstance(operand, Number):
      previous_list = new_list = self.value.copy()
      for _ in range(1, operand.value):
        new_list += previous_list

      return List(new_list, self.context), None

    return None, Value.illegal_operation(self, operand)

  def equal(self, operand):
    if isinstance(operand, List):
      return Number(self.value == operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def not_equal(self, operand):
    if isinstance(operand, List):
      return Number(self.value != operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def denial(self, operand):
    return Number(not self.is_true(), self.context), None

  def copy(self):
    copy = List(self.value, self.context)
    copy.set_position(self.position_start, self.position_end)
    return copy


functions = {}


class Function(Value):
  def __init__(self, name, body_node=None, arguments=None, should_auto_return=None, context=None):
    from tokens_list import global_context

    super().__init__()
    self.name = name or "<безымянная>"
    self.body_node = body_node
    self.arguments = arguments
    self.should_auto_return = should_auto_return
    self.is_buildin = self.name in build_in_functions_names
    self.context = context or global_context

    if not self.is_buildin:
      self.arguments = None
      functions[self.name, ] = dict.fromkeys(arguments, Value)

  def __repr__(self):
    return f"Функция({self.name}, {list(self.get_arguments_names(self.name))})"

  def get_arguments_names(self, function_name):
    for function_names, arguments in functions.items():
      if function_name in function_names:
        return arguments

  def get_arguments(self, context: Context, function_name):
    arguments_names = self.get_arguments_names(function_name)

    arguments = {}
    default_arguments = {}
    for argument in list(arguments_names):
      if "=" not in argument:
        arguments[argument] = Value
        continue

      types = arguments_names[argument]
      argument, default_value = argument.split("=")
      default_value: str
      arguments[argument] = types

      if default_value[0] == "\"":
        default_arguments[argument] = String(default_value[1:-1])
      elif default_value[0].isdigit() or default_value[0] == "-":
        default_arguments[argument] = Number(
          float(default_value)
          if "." in default_value else
          int(default_value)
        )
      elif default_value[0] == "%":
        default_arguments[argument] = List(
          eval(default_value.replace("%(", "[").replace(")%", "]")))
      else:
        default_arguments[argument] = context.symbol_table.get_variable(
          default_value)

    values = []
    for argument_name in arguments:
      argument = context.symbol_table.get_variable(
        argument_name, default_arguments.get(argument_name, Number(None)))
      error = self.check_instance(
        argument, argument_name, context, arguments[argument_name])
      if error:
        return error, [Number(None)] * len(arguments)

      values += [argument]

    return None, *values

  def check_instance(self, value, argument_name, context, type, custom_message=""):
    if isinstance(value, type):
      return False

    type_names = []
    if type == type | Number:
      type_names += ["числом"]
    if type == type | String:
      type_names += ["строкой"]
    if type == type | List:
      type_names += ["списком"]
    if type == type | Function:
      type_names += ["функцией"]

    return RuntimeResponse().failure(RuntimeError(
      self.position_start, self.position_end,
      custom_message or f"Аргумент \"{argument_name.rstrip("?")}\" должен быть {
        ', '.join(type_names)}",
      context
    ))

  def execute(self, arguments):
    response = RuntimeResponse()

    context = Context(self.name, self.context, self.position_start)
    context.symbol_table = SymbolTable(parent=context.parent.symbol_table)

    method = getattr(
      self, f"_{self.name}", self.no_interpret_method) if self.is_buildin else self

    response.register(self.check_and_populate_arguments(
      self.get_arguments_names(self.name), arguments, context))
    if response.should_return():
      return response

    if self.is_buildin:
      return_value = response.register(method(context))
      if response.should_return():
        return response

      return response.success(return_value)
    else:
      from interpret import Interpreter
      interpret = Interpreter(self.name)

      arguments_names = [argument_name.split(
        "=")[0] for argument_name in self.get_arguments_names(self.name)]
      error, *arguments = self.get_arguments(context, self.name)
      if error:
        return response.failure(error)

      context.symbol_table.set_many_variables(
        [[[name], value] for name, value in zip(arguments_names, arguments)])

      value = response.register(interpret.interpret(self.body_node, context))
      if response.should_return() and response.function_return_value == None:
        return response

      return_value = (
          value if self.should_auto_return else response.function_return_value
      ) or response.function_return_value or Number(None)

      return response.success(return_value)

  def check_and_populate_arguments(self, argument_names, arguments, context):
    response = RuntimeResponse()

    response.register(self.check_arguments(arguments, argument_names))
    if response.should_return():
      return response

    self.populate_arguments(argument_names, arguments, context)

    return response.success(None)

  def check_arguments(self, arguments, argument_names):
    response = RuntimeResponse()

    required_argument_names: list[str] = []
    for argument_name in argument_names:
      if "=" in argument_name:
        break

      required_argument_names += [argument_name]

    if len(arguments) > len(argument_names) or len(arguments) < len(required_argument_names):
      return response.failure(RuntimeError(
        self.position_start, self.position_end,
        f"Количество аргументов функции '{self.name}' - {len(argument_names if len(arguments) > len(
          argument_names) else required_argument_names)}, но получено {len(arguments)}",
        self.context
      ))

    return response.success(None)

  def populate_arguments(self, argument_names, arguments, context: Context):
    for i in range(len(arguments)):
      argument_name = list(argument_names)[i].split("=")[0]
      argument_value = arguments[i]
      context.symbol_table.set_variable(argument_name, argument_value)

  def no_interpret_method(self):
    raise Exception(f"Метод _{self.name} не объявлен")

  def copy(self):
    copy = Function(
      self.name, self.body_node,
      self.arguments, self.should_auto_return,
      self.context
    )
    copy.set_position(self.position_start, self.position_end)
    return copy

  # BuildIn Functions

  def _print(self, context: Context):
    error, value = self.get_arguments(context, "print")
    if error:
      return error
    value: Number | String | List

    print(str(value))

    return RuntimeResponse().success(Number(None, context))
  functions[("print", "показать")] = {"value=\"\"": Number | String | List}

  def _error(self, context: Context):
    error, value = self.get_arguments(context, "error")
    if error:
      return error
    value: Number | String | List

    return RuntimeResponse().failure(RuntimeError(
      self.position_start, self.position_end,
      str(value.value), context, False
    ))
  functions[("error", "ошибка")] = {"value=\"\"": Number | String | List}

  def _input(self, context: Context):
    error, value = self.get_arguments(context, "input")
    if error:
      return error
    value: Number | String | List

    return RuntimeResponse().success(String(input(str(value.value)), context))
  functions[("input", "ввести")] = {"value=\"\"": Number | String | List}

  def _clear(self, context: Context):
    system("cls" if os_name == "nt" else "clear")
    return RuntimeResponse().success(Number(None, context))
  functions[("clear", "очистить")] = {}

  def _type(self, context: Context):
    error, value = self.get_arguments(context, "type")
    if error:
      return error

    types = {"Number": "Число", "String": "Строка",
             "List": "Список", "Function": "Функция"}

    return RuntimeResponse().success(String(types[value.__class__.__name__], context))
  functions[("type", "тип")] = {"value": Value}

  def _to_binary(self, context: Context):
    error, number = self.get_arguments(context, "to_binary")
    if error:
      return error
    number: Number

    binary_value = bin(number.value)[2:]
    return RuntimeResponse().success(String(binary_value, context))
  functions[("to_binary", "в_бинарный", "к_бинарному")] = {"number": Number}

  def _to_number(self, context: Context):
    error, value, base = self.get_arguments(context, "to_number")
    if error:
      return error
    value: Number | String
    base: Number

    if isinstance(value, Number):
      return RuntimeResponse().success(value.set_context(context))
    elif "." in value.value:
      return RuntimeResponse().success(Number(float(value.value), context))

    return RuntimeResponse().success(Number(int(value.value, base.value), context))
  functions[("to_number", "в_число", "к_числу")] = {"value": Number | String, "base=10": Number}

  def _to_integer(self, context: Context):
    error, value, base = self.get_arguments(context, "to_integer")
    if error:
      return error
    value: Number | String
    base: Number

    return RuntimeResponse().success(Number(int(value.value, base.value), context))
  functions[("to_integer", "в_целое", "к_целому")] = {"value": Number | String, "base=10": Number}

  def _to_float(self, context: Context):
    error, value = self.get_arguments(context, "to_float")
    if error:
      return error
    value: Number | String

    return RuntimeResponse().success(Number(float(value.value), context))
  functions[("to_float", "в_вещественное", "к_вещественному")] = {"value": Number | String}

  def _to_string(self, context: Context):
    error, value = self.get_arguments(context, "to_string")
    if error:
      return error
    value: Number | String | List

    if isinstance(value, Number):
      return RuntimeResponse().success(String(str(value.value), context))
    elif isinstance(value, List):
      return RuntimeResponse().success(String(f"%({', '.join(map(lambda x: str(x), value.value))})%", context))

    return RuntimeResponse().success(value.set_context(context))
  functions[("to_string", "в_строку", "к_строке")] = {"value": Number | String | List}

  def _to_list(self, context: Context):
    error, value = self.get_arguments(context, "to_list")
    if error:
      return error
    value: String | List

    if isinstance(value, String):
      return RuntimeResponse().success(List(list(map(lambda x: String(x, context), value.value)), context))

    return RuntimeResponse().success(value.set_context(context))
  functions[("to_list", "в_список", "к_списку")] = {"value": String | List}

  def _random(self, context: Context):
    from random import random

    return RuntimeResponse().success(Number(random(), context))
  functions[("random", "случайное_число")] = {}

  def _pause(self, context: Context):
    from time import sleep

    error, time = self.get_arguments(context, "pause")
    if error:
      return error
    time: Number

    sleep(time.value)

    return RuntimeResponse().success(Number(None, context))
  functions[("pause", "приостановить", "пауза")] = {"time": Number}

  def _run(self, context: Context):
    from run import run

    error, file_name = self.get_arguments(context, "run")
    if error:
      return error

    try:
      with open(file_name.value) as file:
        code = file.read()
    except Exception as exception:
      return RuntimeResponse().failure(RuntimeError(
        self.position_start, self.position_end,
        f"Не удалось загрузить файл {file_name.value}\n" + str(exception),
        context
      ))

    _, error = run(file_name.value, code)

    if error:
      return RuntimeResponse().failure(RuntimeError(
        self.position_start, self.position_end,
        f"Не удалось закончить выполение кода {file_name.value}\n" + str(
            error),
        context
      ))

    return RuntimeResponse().success(Number(None, context))
  functions[("run", "запустить")] = {"file": String}

  def _exit(self, context: Context):
    error, code = self.get_arguments(context, "exit")
    if error:
      return error

    exit(code.value)
  functions[("exit", "завершить", "выход")] = {"code=1": Number}


build_in_functions_names = [
  name for function_names in functions.keys() for name in function_names
]

build_in_functions = {
  functions_names: Function(functions_names[0])
  for functions_names in functions
}
