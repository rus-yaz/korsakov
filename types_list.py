from context import Context
from errors_list import InvalidSyntaxError, RuntimeError
from runtime_response import RuntimeResponse
from nodes_list import *
from tokens_list import *


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

  def is_true(self): return False

  def addition(self, operand): return None, self.illegal_operation(operand)

  def subtraction(self, operand): return None, self.illegal_operation(operand)

  def multiplication(self, operand): return None, self.illegal_operation(operand)

  def division(self, operand): return None, self.illegal_operation(operand)

  def power(self, operand): return None, self.illegal_operation(operand)

  def root(self, operand): return None, self.illegal_operation(operand)

  def increment(self, operand): return None, self.illegal_operation(operand)

  def decrement(self, operand): return None, self.illegal_operation(operand)

  def equal(self, operand): return None, self.illegal_operation(operand)

  def not_equal(self, operand): return None, self.illegal_operation(operand)

  def less(self, operand): return None, self.illegal_operation(operand)

  def more(self, operand): return None, self.illegal_operation(operand)

  def less_or_equal(self, operand): return None, self.illegal_operation(operand)

  def more_or_equal(self, operand): return None, self.illegal_operation(operand)

  def both(self, operand): return None, self.illegal_operation(operand)

  def some(self, operand): return None, self.illegal_operation(operand)

  def denial(self): return None, self.illegal_operation()

  def execute(self, arguments): return RuntimeResponse().failure(self.illegal_operation())

  def copy(self): raise Exception("Метод копирования не определён")

  def illegal_operation(self, operand=None):
    if not operand:
      operand = self

    return RuntimeError(
      self.position_start, operand.position_end,
      f"Неизвестная операция для {self.__class__.__name__} и {operand.__class__.__name__}",
      self.context
    )


class Number(Value):
  def __init__(self, value, context):
    super().__init__()
    self.value = int(value) if isinstance(value, bool) else value
    self.context = context

  def __str__(self): return str(self.value)

  def __repr__(self): return f"Число({self.value})"

  def is_true(self): return self.value not in [0, None]

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
      return type(operand)(self.value * operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def division(self, operand):
    if isinstance(operand, Number):
      if operand.value == 0:
        return None, RuntimeError(operand.position_start, operand.position_end, "Деление на ноль", self.context)
      
      return Number(self.value / operand.value, self.context), None

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
  def __init__(self, value, context):
    super().__init__()
    self.value = value
    self.context = context

  def get(self, index: Number, default_value: Value = None):
    if -len(self.value) <= index.value < len(self.value):
      return String(self.value[index.value], self.context)
    
    return default_value

  def set(self, index: Number, value):
    self.value = self.value[:index.value] + value.value + self.value[index.value + 1:]
    return self

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
      return Number(self.is_true() and operand.is_true(), self.context), None

    return None, Value.illegal_operation(self, operand)

  def some(self, operand):
    if isinstance(operand, String):
      return Number(self.is_true() or operand.is_true(), self.context), None

    return None, Value.illegal_operation(self, operand)

  def denial(self):
    return Number(not self.is_true(), self.context), None

  def copy(self):
    copy = String(self.value, self.context)
    copy.set_position(self.position_start, self.position_end)
    return copy


class List(Value):
  def __init__(self, values: list, context):
    super().__init__()
    self.value = values.copy()
    self.context = context

  def __str__(self):
    return "%(" + ", ".join(map(str, self.value)) + ")%"

  def __repr__(self):
    return f"Список({str(self)})"

  def get(self, index: Number, default_value: Value = None):
    if -len(self.value) <= index.value < len(self.value):
      return self.value[index.value]
    return default_value

  def set(self, index: Number, value: Value):
    self.value[index.value] = value
    return self

  def is_true(self):
    return self.value != []

  def addition(self, operand):
    if isinstance(operand, List):
      return List(self.value + operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def multiplication(self, operand: Number):
    if isinstance(operand, Number):
      return List(self.value * operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def equal(self, operand):
    if isinstance(operand, List):
      return Number(self.value == operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def not_equal(self, operand):
    if isinstance(operand, List):
      return Number(self.value != operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def denial(self):
    return Number(not self.is_true(), self.context), None

  def copy(self):
    copy = List(self.value.copy(), self.context)
    copy.set_position(self.position_start, self.position_end)
    return copy


class Dictionary(Value):
  def __init__(self, value: list[list], context):
    super().__init__()
    self.value = value
    self.context = context

  def __str__(self):
    return "%(" + ", ".join(f"{key}: {value}" for key, value in self.value) + ")%"

  def __repr__(self):
    return f"Словарь({str(self)})"

  def items(self):
    return self.value.copy()

  def values(self):
    return [value for key, value in self.value]

  def keys(self):
    return [key for key, value in self.value]

  def get(self, target: String | Number, default_value: Value=None):
    for key, value in self.value:
      if key.value == target.value: return value

    return default_value

  def set(self, target: String | Number, replacement: Value):
    for index, pair in enumerate(self.value):
      if pair[0].value == target.value:
        self.value.pop(index)
        break

    self.value += [[target, replacement]]
    return self

  def is_true(self):
    return self.value != []

  def addition(self, operand):
    if isinstance(operand, Dictionary):
      result = self.copy()
      for key, value in operand.value:
        result.set(key, value)
      return result, None 

    return None, Value.illegal_operation(self, operand)

  def equal(self, operand):
    if isinstance(operand, Dictionary):
      return Number(self.value == operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def not_equal(self, operand):
    if isinstance(operand, Dictionary):
      return Number(self.value != operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def denial(self):
    return Number(not self.is_true(), self.context), None

  def copy(self):
    copy = Dictionary(self.value.copy(), self.context)
    copy.set_position(self.position_start, self.position_end)
    return copy

# TODO: после создания компилятора вырезать встроенные функции и код, связанный с ними
class Function(Value):
  def __init__(self, name, body_node, argument_names, should_auto_return, context):
    super().__init__()
    self.name = name or "/безымянная\\"
    self.body_node = body_node
    self.argument_names = argument_names
    self.should_auto_return = should_auto_return
    self.is_buildin = self.name in build_in_functions_names
    self.context = context
    self.internal_context = Context(self.name, self.context.variables, self.context, self.position_start)

    if not self.is_buildin:
      functions[self.name,] = dict.fromkeys(argument_names, Value)

  def __repr__(self):
    return f"Функция({self.name}, {List(self.get_argument_names(self.name), self.context)})"

  def check_instance(self, value, argument_name, context, type, custom_message=""):
    if isinstance(value, type):
      return False

    type_names = []
    if type == type | Number:   type_names += ["числом"]
    if type == type | String:   type_names += ["строкой"]
    if type == type | List:     type_names += ["списком"]
    if type == type | Function: type_names += ["функцией"]

    return RuntimeResponse().failure(RuntimeError(
      self.position_start, self.position_end,
      custom_message or f"Аргумент \"{argument_name}\" должен быть {', '.join(type_names)}",
      context
    ))

  def execute(self, arguments):
    response = RuntimeResponse()

    argument_names = self.get_argument_names(self.name)
    initial_variables = self.internal_context.variables.copy()
    response.register(self.check_and_populate_arguments(argument_names, arguments, self.internal_context))
    if response.should_return():
      return response

    if self.is_buildin:
      method = getattr(self, f"_{self.name}", self.no_interpret_method)
      return_value = response.register(method(self.internal_context))
      if response.should_return():
        return response
      
      self.internal_context.variables = initial_variables.copy()
        
      return response.success(return_value)
    
    from interpret import Interpreter
    interpret = Interpreter(self.name)

    argument_names = [argument_name.variable.value for argument_name in list(argument_names)]
    error, *arguments = self.get_arguments(self.internal_context, self.name)
    if error:
      return response.failure(error)

    self.internal_context.set_many_variables([[[name], value] for name, value in zip(argument_names, arguments)])

    value = response.register(interpret.interpret(self.body_node, self.internal_context))
    if response.should_return() and response.function_return_value == None:
      return response

    return_value = (value if self.should_auto_return else response.function_return_value) or response.function_return_value or Number(None, self.context)

    self.internal_context.variables = initial_variables.copy()

    return response.success(return_value)

  def check_and_populate_arguments(self, argument_names, arguments, context):
    response = RuntimeResponse()
    
    if argument_names and isinstance(list(argument_names)[0], tuple):
      position = Position(-1, 0, 0, "", "")
      temp = []
      for argument in argument_names:
          if len(argument) == 1:
            temp += [VariableAccessNode(
              Token(IDENTIFIER, argument[0], position, position),
              [], position, position
            )]
            continue
          
          temp += [VariableAssignNode(
            Token(IDENTIFIER, argument[0], position, position),
            [],
            NumberNode(Token(INTEGER, argument[1], position, position))
            if isinstance(argument[1], int) else
            NumberNode(Token(FLOAT, argument[1], position, position))
            if isinstance(argument[1], float) else
            StringNode(Token(STRING, argument[1], position, position))
            if isinstance(argument[1], str) else
            ListNode(argument[1], position, position)
            if isinstance(argument[1], list) else
            VariableAccessNode(Token(IDENTIFIER, argument[1], position, position), [], position, position),
          )]
          
      argument_names = temp

    count_of_required_arguments = 0
    for argument_name in argument_names:
      if isinstance(argument_name, VariableAssignNode):
        break

      count_of_required_arguments += 1

    if len(arguments) > len(argument_names) or len(arguments) < count_of_required_arguments:
      return response.failure(RuntimeError(
        self.position_start, self.position_end,
        f"Количество аргументов функции '{self.name}' - {len(argument_names) if len(arguments) > len(argument_names) else count_of_required_arguments}, но получено {len(arguments)}",
        self.context
      ))

    for i in range(len(arguments)):
      argument_name = list(argument_names)[i]
      if not isinstance(argument_name, tuple):
        argument_name = argument_name.variable.value
        
      argument_value = arguments[i]
      context.set_variable(argument_name, argument_value)

    return response.success(None)
  
  def get_arguments(self, context: Context, function_name, argument_names=None):
    from interpret import Interpreter

    interpreter = Interpreter(self.name)
    if argument_names == None:
      argument_names = self.get_argument_names(function_name)
    
    arguments = {}
    default_arguments = {}
    for argument in list(argument_names):
      types = argument_names[argument]

      if isinstance(argument, VariableAccessNode):
        arguments[argument.variable.value] = Value
        continue

      if isinstance(argument, tuple):
        if len(argument) == 1:
          arguments[argument[0]] = Value
          continue

        position = Position(-1, 0, 0, "", "")
        argument = VariableAssignNode(
          Token(IDENTIFIER, argument[0], position, position),
          [],
          NumberNode(Token(INTEGER, argument[1], position, position))
          if isinstance(argument[1], int) else
          NumberNode(Token(FLOAT, argument[1], position, position))
          if isinstance(argument[1], float) else
          StringNode(Token(STRING, argument[1], position, position))
          if isinstance(argument[1], str) else
          ListNode(argument[1], position, position)
          if isinstance(argument[1], list) else
          VariableAccessNode(Token(IDENTIFIER, argument[1], position, position), [], position, position),
        )
      
      argument, default_value = argument.variable.value, argument.value_node
      arguments[argument] = types

      default_arguments[argument] = RuntimeResponse().register(interpreter.interpret(default_value, context))
      
    values = []
    for argument_name in arguments:
      argument = context.get_variable(argument_name, default_arguments.get(argument_name, Number(None, context)))
      error = self.check_instance(argument, argument_name, context, arguments[argument_name])
      if error:
        return error, *([Number(None, context)] * len(arguments))

      values += [argument]

    return None, *values

  def get_argument_names(self, function_name):
    for function_names, arguments in functions.items():
      if function_name in function_names:
        return arguments

  def no_interpret_method(self):
    raise Exception(f"Метод _{self.name} не объявлен")

  def copy(self):
    copy = Function(
      self.name, self.body_node,
      self.argument_names, self.should_auto_return,
      self.context
    )
    copy.set_position(self.position_start, self.position_end)
    return copy

  # BuildIn Functions

  def _print(self, context: Context):
    error, value = self.get_arguments(context, "print")
    if error:
      return error
    
    value: Number | String | List | Dictionary

    print(str(value))

    return RuntimeResponse().success(Number(None, context))

  def _error(self, context: Context):
    error, value = self.get_arguments(context, "error")
    if error:
      return error
    
    value: Number | String | List | Dictionary

    return RuntimeResponse().failure(RuntimeError(
      self.position_start, self.position_end,
      str(value.value), context, False
    ))

  def _input(self, context: Context):
    error, value = self.get_arguments(context, "input")
    if error:
      return error
    
    value: Number | String | List | Dictionary
    return RuntimeResponse().success(String(input(str(value.value)), context))

  def _clear(self, context: Context):
    from os import name, system

    system("cls" if name == "nt" else "clear")
    return RuntimeResponse().success(Number(None, context))

  def _type(self, context: Context):
    error, value = self.get_arguments(context, "type")
    if error:
      return error

    types = {
      "Number": "Число", "String": "Строка",
      "List": "Список", "Dictionary": "Словарь",
      "Function": "Функция", "Class": "Класс",
      "Object": "Объект"
    }

    return RuntimeResponse().success(String(types[value.__class__.__name__], context))

  def _to_binary(self, context: Context):
    error, number = self.get_arguments(context, "to_binary")
    if error:
      return error
    
    number: Number
    binary_value = bin(number.value)[2:]
    return RuntimeResponse().success(String(binary_value, context))

  def _to_number(self, context: Context):
    error, value, base = self.get_arguments(context, "to_number")
    if error:
      return error
    
    value: Number | String
    base: Number

    if isinstance(value, Number):
      return RuntimeResponse().success(value.copy().set_context(context))
      
    if "." in value.value:
      return RuntimeResponse().success(Number(float(value.value), context))

    return RuntimeResponse().success(Number(int(value.value, base.value), context))

  def _to_integer(self, context: Context):
    error, value, base = self.get_arguments(context, "to_integer")
    if error:
      return error
    
    value: Number | String
    base: Number

    if isinstance(value, Number):
      return RuntimeResponse().success(Number(int(value.value), context))

    return RuntimeResponse().success(Number(int(value.value, base.value), context))

  def _to_float(self, context: Context):
    error, value = self.get_arguments(context, "to_float")
    if error:
      return error
    
    value: Number | String
    return RuntimeResponse().success(Number(float(value.value), context))

  def _to_string(self, context: Context):
    error, value = self.get_arguments(context, "to_string")
    if error:
      return error
    
    value: Number | String | List | Dictionary

    if isinstance(value, Number | List | Dictionary):
      return RuntimeResponse().success(String(str(value), context))

    return RuntimeResponse().success(value.set_context(context))

  def _to_list(self, context: Context):
    error, value = self.get_arguments(context, "to_list")
    if error:
      return error
    
    value: String | List | Dictionary

    if isinstance(value, String):
      return RuntimeResponse().success(List(list(map(lambda x: String(x, context), value.value)), context))
    elif isinstance(value, Dictionary):
      return RuntimeResponse().success(List(value.keys(), context))

    return RuntimeResponse().success(value.set_context(context))

  def _to_dictionary(self, context: Context):
    error, elements = self.get_arguments(context, "to_dictionary")
    if error:
      return error
    
    elements: List = elements.value

    for item in elements:
      if not isinstance(item, List) or len(item.value) != 2:
        return RuntimeResponse().failure(InvalidSyntaxError(
          elements.position_start, elements.position_end,
          "Список должен содержать массивы, состоящие из двух элементов "
        ))

    return RuntimeResponse().success(Dictionary(elements.value, context))

  def _items(self, context: Context):
    error, elements = self.get_arguments(context, "items")
    if error:
      return error

    elements: Dictionary = elements.items()
    return RuntimeResponse().success(List(elements, context))


  def _values(self, context: Context):
    error, elements = self.get_arguments(context, "values")
    if error:
      return error

    elements: Dictionary = elements.values()
    return RuntimeResponse().success(List(elements, context))

  def _keys(self, context: Context):
    error, elements = self.get_arguments(context, "keys")
    if error:
      return error

    elements: Dictionary = elements.keys()
    return RuntimeResponse().success(List(elements, context))
  
  def _random(self, context: Context):
    from random import random

    return RuntimeResponse().success(Number(random(), context))

  def _pause(self, context: Context):
    from time import sleep

    error, time = self.get_arguments(context, "pause")
    if error:
      return error
    
    time: Number

    sleep(time.value)

    return RuntimeResponse().success(Number(None, context))

  def _time(self, context: Context):
    from time import time

    return RuntimeResponse().success(Number(time(), context))

  def _run(self, context: Context):
    from run import run

    error, file_name = self.get_arguments(context, "run")
    if error:
      return error
    
    file_name: String

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
        f"Не удалось закончить выполение кода {file_name.value}\n" + str(error),
        context
      ))

    return RuntimeResponse().success(Number(None, context))

  def _read_file(self, context: Context):
    error, file_name = self.get_arguments(context, "read_file")
    if error:
      return error
    
    file_name: String

    try: 
      with open(file_name.value) as file:
        return RuntimeResponse().success(String(file.read(), context))
    except:
      return RuntimeResponse().failure(RuntimeError(
        self.position_start, self.position_end,
        f"Не удалось открыть файл {file_name.value}",
        context
      ))

  def _change_directory(self, context: Context):
    from os import chdir

    error, path = self.get_arguments(context, "change_directory")
    if error:
      return error
    
    path: String

    chdir(path.value)

    return RuntimeResponse().success(Number(None, context))

  def _get_current_directory(self, context: Context):
    from os import getcwd

    return RuntimeResponse().success(String(getcwd(), context))

  def _exit(self, context: Context):
    error, code = self.get_arguments(context, "exit")
    if error:
      return error

    exit(code.value)

functions = {
  ("print", "показать"):                                    {("value", ""): Number | String | List | Dictionary},
  ("error", "ошибка"):                                      {("value", ""): Number | String | List | Dictionary},
  ("input", "ввести"):                                      {("value", ""): Number | String | List | Dictionary},
  ("clear", "очистить"):                                    {},
  ("type", "тип"):                                          {("value",): Value},
  ("to_binary", "в_бинарный", "к_бинарному"):               {("number",): Number},
  ("to_number", "в_число", "к_числу"):                      {("value",): Number | String, ("base", 10): Number},
  ("to_integer", "в_целое", "к_целому"):                    {("value",): Number | String, ("base", 10): Number},
  ("to_float", "в_вещественное", "к_вещественному"):        {("value",): Number | String},
  ("to_string", "в_строку", "к_строке"):                    {("value",): Number | String | List | Dictionary},
  ("to_list", "в_список", "к_списку"):                      {("value",): String | List | Dictionary},
  ("to_dictionary", "к_словарю", "в_словарь"):              {("elements",): List},
  ("items", "элементы"):                                    {("elements",): Dictionary},
  ("values", "значения"):                                   {("elements",): Dictionary},
  ("keys", "ключи"):                                        {("elements",): Dictionary},
  ("random", "случайное_число"):                            {},
  ("pause", "приостановить", "пауза"):                      {("time",): Number},
  ("time", "время"):                                        {},
  ("run", "запустить"):                                     {("file",): String},
  ("read_file", "прочитать_файл"):                          {("file_name",): String},
  ("change_directory", "сменить_дирикторию"):               {("path",): String},
  ("get_current_directory", "получить_текущую_директорию"): {},
  ("exit", "завершить", "выход"):                           {("code", 0): Number},
}
    
build_in_functions_names = [name for function_names in functions.keys() for name in function_names]

class Class(Function):
  def __init__(self, name, value, context):
    self.name = name
    self.value: Dictionary = value
    self.initial_method = self.value.get(String("__init__", context)) or self.value.get(String("__инициализация__", context))
    self.initial_method.argument_names = {argument_name: Value for argument_name in self.initial_method.argument_names}
    self.context = context

  def __repr__(self):
    return f"Класс({self.name}, {self.value})"

  def execute(self, arguments):
    response = RuntimeResponse()

    context = Context(self.name, self.context.variables, self.context, self.position_start)
    arguments = [Object(self.value.items(), context)] + arguments

    response.register(self.check_and_populate_arguments(self.initial_method.argument_names, arguments, context))
    if response.should_return():
      return response

    from interpret import Interpreter
    interpret = Interpreter(self.name)

    argument_names = [argument_name.variable.value for argument_name in self.initial_method.argument_names]
    error, *arguments = self.get_arguments(context, self.name, self.initial_method.argument_names)
    if error:
      return response.failure(error)

    context.set_many_variables([[[name], value] for name, value in zip(argument_names, arguments)])

    value = response.register(interpret.interpret(self.initial_method.body_node, context))
    if response.should_return():
      return response
    
    if response.function_return_value:
      return response.failure(InvalidSyntaxError(
        self.initial_method.position_start, self.initial_method.position_end,
        "Метод инициализации не может ничего возвращать"
      ))

    return_value = context.get_variable(argument_names[0])
    self.value = return_value

    return response.success(return_value)

class Object(Dictionary):
  def __init__(self, value, context):
    super().__init__(value, context)

  def __repr__(self):
    return f"Объект({str(self)})"

  def copy(self):
    copy = Object(self.value.copy(), self.context)
    copy.set_position(self.position_start, self.position_end)
    return copy

class Method(Function):
  def __init__(self, name, body_node, argument_names, should_auto_return, context):
    super().__init__(name, body_node, argument_names, should_auto_return, context)

  def __repr__(self):
    return f"Метод({self.name}, {list(self.get_argument_names(self.name))})"

