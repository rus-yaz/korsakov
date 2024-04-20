from context import Context
from loggers import InvalidSyntaxError, RuntimeError, RuntimeLogger
from nodes import *
from tokens import *


class Value:
  """
    Описание:
      Родительский класс типов данных в языке. Все методы обработки операций, передаваемые потомкам, возвращают сигнал ошибки о неизвестной операции

    Аргументы: -

    Поля класса:
      position_start (Position): позиция начала элемента
      position_end (Position): позиция конца элемента
  """

  def __init__(self):
    self.set_position()
    self.set_context()

  def set_position(self, position_start=None, position_end=None):
    """
      Описание:
        Установка переданных позиций начала и конца элемента

      Аргументы:
        position_start (Position): позиция начала элемента
        position_end (Position): позиция конца элемента

      Возвращаемое значение:
        Value: сам экземпляр
    """
    self.position_start = position_start
    self.position_end = position_end
    return self

  def set_context(self, context=None):
    """
      Описание:
        Установка переданного контекста

      Аргументы:
        context (Context): хранилище, в котором находится элемент

      Возвращаемое значение:
        Value: сам экземпляр
    """
    self.context = context
    return self

  def both(self, operand):
    """
      Описание:
        Логическая операция "и"

      Аргументы:
        operand (Value): второй операнд

      Возвращаемое значение:
        Number: результат логической операции "и"
        None: сигнал об отсутствии ошибки
    """
    return Number(self.is_true() and operand.is_true(), self.context), None

  def some(self, operand):
    """
      Описание:
        Логическая операция "или"

      Аргументы:
        operand (Value): второй операнд

      Возвращаемое значение:
        Number: результат логической операции "или"
        None: сигнал об отсутствии ошибки
    """
    return Number(self.is_true() or operand.is_true(), self.context), None

  def denial(self):
    """
      Описание:
        Логическая операция "не"

      Аргументы: -

      Возвращаемое значение:
        Number: результат логической операции "не"
        None: сигнал об отсутствии ошибки
    """
    return Number(not self.is_true(), self.context), None

  def illegal_operation(self, operand=None):
    """
      Описание:
        Сигнал ошибки о неизвестной оперции для операнда или пары операндов

      Аргументы:
        operand (*Value): второй операнд (по умолчанию - нуль)

      Возвращаемое значение:
        RuntimeError: сигнал ошибки о неизвестной операции над одним или двумя операндами
    """
    return RuntimeError(
      self.position_start, operand.position_end,
      f"Неизвестная операция для {self.__class__.__name__}{"и" + operand.__class__.__name__ if operand else ""}",
      self.context
    )

  def is_true(self):                 return None, self.illegal_operation()

  def addition(self, operand):       return None, self.illegal_operation(operand)

  def subtraction(self, operand):    return None, self.illegal_operation(operand)

  def multiplication(self, operand): return None, self.illegal_operation(operand)

  def division(self, operand):       return None, self.illegal_operation(operand)

  def power(self, operand):          return None, self.illegal_operation(operand)

  def root(self, operand):           return None, self.illegal_operation(operand)

  def increment(self, operand):      return None, self.illegal_operation(operand)

  def decrement(self, operand):      return None, self.illegal_operation(operand)

  def equal(self, operand):          return None, self.illegal_operation(operand)

  def not_equal(self, operand):      return None, self.illegal_operation(operand)

  def less(self, operand):           return None, self.illegal_operation(operand)

  def more(self, operand):           return None, self.illegal_operation(operand)

  def less_or_equal(self, operand):  return None, self.illegal_operation(operand)

  def more_or_equal(self, operand):  return None, self.illegal_operation(operand)


class Number(Value):
  """
    Описание:
      Класс типа Число. Содержит целое или дробное число

    Аргументы:
      value (число): значение элемента
      context (Context): хранилище, в котором находится элемент

    Поля класса:
      value (число): значение элемента
      context (Context): хранилище, в котором находится элемент
  """

  def __init__(self, value, context):
    super().__init__()
    self.value = int(value) if isinstance(value, bool) else value
    self.context = context

  def __str__(self):
    return str(self.value)

  def __repr__(self):
    return f"Число({self.value})"

  def copy(self):
    """
      Описание:
        Копирование элемента

      Аргументы: -

      Возвращаемое значение:
        Number: копия самого экзмепляра
    """
    return Number(self.value, self.context).set_position(self.position_start, self.position_end)

  def is_true(self):
    """
      Описание:
        Проверка на истинность

      Аргументы: -

      Возвращаемое значение:
        Булево значение: если значение не равно нулю - истина, иначе - ложь
    """
    return self.value not in [0, None]

  def addition(self, operand):
    """
      Описание:
        Операция сложения между Number и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        Number или None: результат сложения или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(self.value + operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def subtraction(self, operand):
    """
      Описание:
        Операция сложения между Number и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        Number или None: результат вычитания или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(self.value - operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def multiplication(self, operand):
    """
      Описание:
        Операция произведения между Number и Number, String или List

      Аргументы:
        operand (Number, String или List): второй операнд

      Возвращаемое значение:
        Number, String, List или None: результат произведения или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, List | Number | String):
      return type(operand)(self.value * operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def division(self, operand):
    """
      Описание:
        Операция деления между Number и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        Number или None: результат деления или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      if operand.value == 0:
        return None, RuntimeError(operand.position_start, operand.position_end, "Деление на ноль", self.context)

      return Number(self.value / operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def power(self, operand):
    """
      Описание:
        Операция возведения в степень между Number и Number

      Аргументы:
        operand (Number): второй операнд (степень)

      Возвращаемое значение:
        Number или None: результат возведения в степень или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(self.value ** operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def root(self, operand):
    """
      Описание:
        Операция извлечения корня между Number и Number

      Аргументы:
        operand (Number): второй операнд (подкоренное выражение)

      Возвращаемое значение:
        Number или None: результат извлечения корня или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(operand.value ** (1 / self.value), self.context), None

    return None, Value.illegal_operation(self, operand)

  def equal(self, operand):
    """
      Описание:
        Операция равенства между Number и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        Number или None: результат операции равенства или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(self.value == operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def not_equal(self, operand):
    """
      Описание:
        Операция неравества между Number и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        Number или None: результат операции неравенства или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(self.value != operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def less(self, operand):
    """
      Описание:
        Операция сравнения "меньше" между Number и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        Number или None: результат операции сравнения "меньше" или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(self.value < operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def more(self, operand):
    """
      Описание:
        Операция сравнения "больше" между Number и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        Number или None: результат операции сравнения "меньше" или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(self.value > operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def less_or_equal(self, operand):
    """
      Описание:
        Операция сравнения "меньше или равно" между Number и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        Number или None: результат операции сравнения "меньше или равно" или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(self.value <= operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def more_or_equal(self, operand):
    """
      Описание:
        Операция сравнения "больше или равно" между Number и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        Number или None: результат операции сравнения "больше или равно" или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return Number(self.value >= operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)


class String(Value):
  """
    Описание:
      Класс типа Строка. Содержит строковые литералы

    Аргументы:
      value (строка): значение элемента
      context (Context): хранилище, в котором находится элемент

    Поля класса:
      value (строка): значение элемента
      context (Context): хранилище, в котором находится элемент
  """

  def __init__(self, value, context):
    super().__init__()
    self.value = value
    self.context = context

  def __str__(self):
    return self.value

  def __repr__(self):
    return f"Строка(\"{self.value}\")"

  def copy(self):
    """
      Описание:
        Копирование элемента

      Аргументы: -

      Возвращаемое значение:
        String: копия самого экзмепляра
    """
    return String(self.value, self.context).set_position(self.position_start, self.position_end)

  def is_true(self):
    """
      Описание:
        Проверка на истинность

      Аргументы: -

      Возвращаемое значение:
        Булево значение: если значение не равно пустой строке - истина, иначе - ложь
    """
    return self.value != ""

  def get(self, index: Number, default_value: Value = None):
    """
      Описание:
        Операция получения символа по индексу

      Аргументы:
        index (Number): индекс элемента
        default_value (Value): значение, которое будет отправлено в случае, если индекс выходит за рамки строки

      Возвращаемое значение:
        String или Value: символ из строки или значение по умолчанию
    """
    if -len(self.value) <= index.value < len(self.value):
      return String(self.value[index.value], self.context)

    return default_value

  def set(self, index: Number, value):
    """
      Описание:
        Операция замены символа по индексу

      Аргументы:
        index (Number): индекс символа
        value (String): заменяющий символ

      Возвращаемое значение:
        String: сам экземпляр
    """
    self.value = self.value[:index.value] + value.value + self.value[index.value + 1:]
    return self

  def addition(self, operand):
    """
      Описание:
        Операция сложения между String и String

      Аргументы:
        operand (String): второй операнд

      Возвращаемое значение:
        String или None: результат сложения или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, String):
      return String(self.value + operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def multiplication(self, operand):
    """
      Описание:
        Операция произведения между String и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        String или None: результат произведения или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return String(self.value * operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def equal(self, operand):
    """
      Описание:
        Операция равенства между String и String

      Аргументы:
        operand (String): второй операнд

      Возвращаемое значение:
        Number или None: результат операции равенства или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, String):
      return Number(self.value == operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def not_equal(self, operand):
    """
      Описание:
        Операция неравества между String и String

      Аргументы:
        operand (String): второй операнд

      Возвращаемое значение:
        Number или None: результат операции неравенства или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, String):
      return Number(self.value != operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def less(self, operand):
    """
      Описание:
        Операция сравнения "меньше" между String и String

      Аргументы:
        operand (String): второй операнд

      Возвращаемое значение:
        Number или None: результат операции сравнения "меньше" или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, String):
      return Number(self.value < operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def more(self, operand):
    """
      Описание:
        Операция сравнения "больше" между String и String

      Аргументы:
        operand (String): второй операнд

      Возвращаемое значение:
        Number или None: результат операции сравнения "меньше" или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, String):
      return Number(self.value > operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def less_or_equal(self, operand):
    """
      Описание:
        Операция сравнения "меньше или равно" между String и String

      Аргументы:
        operand (String): второй операнд

      Возвращаемое значение:
        Number или None: результат операции сравнения "меньше или равно" или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, String):
      return Number(self.value <= operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def more_or_equal(self, operand):
    """
      Описание:
        Операция сравнения "больше или равно" между String и String

      Аргументы:
        operand (String): второй операнд

      Возвращаемое значение:
        Number или None: результат операции сравнения "больше или равно" или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, String):
      return Number(self.value >= operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)


class List(Value):
  """
    Описание:
      Класс типа Список. Содержит некоторое количество элементов

    Аргументы:
      value (список): значение элемента
      context (Context): хранилище, в котором находится элемент

    Поля класса:
      value (список): значение элемента
      context (Context): хранилище, в котором находится элемент
  """

  def __init__(self, values: list, context):
    super().__init__()
    self.value = values.copy()
    self.context = context

  def __str__(self):
    return "%(" + "; ".join(map(str, self.value)) + ")%"

  def __repr__(self):
    return f"Список({str(self)})"

  def copy(self):
    """
      Описание:
        Копирование элемента

      Аргументы: -

      Возвращаемое значение:
        List: копия самого экзмепляра
    """
    return List(self.value.copy(), self.context).set_position(self.position_start, self.position_end)

  def is_true(self):
    """
      Описание:
        Проверка на истинность

      Аргументы: -

      Возвращаемое значение:
        Булево значение: если значение не равно пустому списку - истина, иначе - ложь
    """
    return self.value != []

  def get(self, index: Number, default_value: Value = None):
    """
      Описание:
        Операция получения символа по индексу

      Аргументы:
        index (Number): индекс элемента
        default_value (Value): значение, которое будет отправлено в случае, если индекс выходит за рамки строки

      Возвращаемое значение:
        Value: элемент из списка или значение по умолчанию
    """
    if -len(self.value) <= index.value < len(self.value):
      return self.value[index.value]

    return default_value

  def set(self, index: Number, value: Value):
    """
      Описание:
        Операция замены элемента по индексу

      Аргументы:
        index (Number): индекс элемента
        value (Value): заменяющий элемент

      Возвращаемое значение:
        List: сам экземпляр
    """
    self.value[index.value] = value
    return self

  def addition(self, operand):
    """
      Описание:
        Операция сложения между List и List

      Аргументы:
        operand (List): второй операнд

      Возвращаемое значение:
        List или None: результат сложения или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, List):
      return List(self.value + operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def multiplication(self, operand: Number):
    """
      Описание:
        Операция произведения между List и Number

      Аргументы:
        operand (Number): второй операнд

      Возвращаемое значение:
        List или None: результат произведения или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Number):
      return List(self.value * operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def equal(self, operand):
    """
      Описание:
        Операция равенства между List и List

      Аргументы:
        operand (List): второй операнд

      Возвращаемое значение:
        Number или None: результат операции равенства или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, List):
      return Number(self.value == operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def not_equal(self, operand):
    """
      Описание:
        Операция неравества между List и List

      Аргументы:
        operand (List): второй операнд

      Возвращаемое значение:
        Number или None: результат операции неравенства или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, List):
      return Number(self.value != operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)


class Dictionary(Value):
  """
    Описание:
      Класс типа Словарь. Содержит некоторое количество пар ключ-значение

    Аргументы:
      value (список): значение элемента
      context (Context): хранилище, в котором находится элемент

    Поля класса:
      value (список): значение элемента
      context (Context): хранилище, в котором находится элемент
  """

  def __init__(self, value: list[list], context):
    super().__init__()
    self.value = value
    self.context = context

  def __str__(self):
    return "%(" + "; ".join(f"{key}: {value}" for key, value in self.value) + ")%"

  def __repr__(self):
    return f"Словарь({str(self)})"

  def copy(self):
    """
      Описание:
        Копирование элемента

      Аргументы: -

      Возвращаемое значение:
        Dictionary: копия самого экзмепляра
    """
    return Dictionary(self.value.copy(), self.context).set_position(self.position_start, self.position_end)

  def is_true(self):
    """
      Описание:
        Проверка на истинность

      Аргументы: -

      Возвращаемое значение:
        Булево значение: если значение не равно пустому списку - истина, иначе - ложь
    """
    return self.value != []

  def get(self, target: String | Number, default_value: Value = None):
    """
      Описание:
        Операция получения значения по ключу

      Аргументы:
        key (Number или Sring): ключ
        default_value (Value): значение, которое будет отправлено в случае, если индекс выходит за рамки строки

      Возвращаемое значение:
        Value: элемент из списка или значение по умолчанию
    """
    for key, value in self.value:
      if key.value == target.value: return value

    return default_value

  def set(self, key: String | Number, value: Value):
    """
      Описание:
        Операция замены/внесения значения по ключу

      Аргументы:
        key (Number или String): ключ
        value (Value): заменяющий элемент

      Возвращаемое значение:
        Dictionary: сам экземпляр
    """
    for index, pair in enumerate(self.value):
      if pair[0].value == key.value:
        self.value.pop(index)
        break

    self.value += [[key, value]]
    return self

  def items(self):
    """
      Описание:
        Операция получения пар в виде списков из двух элементов

      Аргументы: -

      Возвращаемое значение:
        Список: пары
    """
    return self.value.copy()

  def values(self):
    """
      Описание:
        Операция получения значений в парах

      Аргументы: -

      Возвращаемое значение:
        Список: значения из пар
    """
    return [value for key, value in self.value]

  def keys(self):
    """
      Описание:
        Операция получения ключей в парах

      Аргументы: -

      Возвращаемое значение:
        List: ключи из пар
    """
    return [key for key, value in self.value]

  def addition(self, operand):
    """
      Описание:
        Операция сложения между Dictionary и Dictionary

      Аргументы:
        operand (Dictionary): второй операнд

      Возвращаемое значение:
        Dictionary или None: результат сложения или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Dictionary):
      result = self.copy()
      for key, value in operand.value:
        result.set(key, value)

      return result, None

    return None, Value.illegal_operation(self, operand)

  def equal(self, operand):
    """
      Описание:
        Операция равенства между Dictionary и Dictionary

      Аргументы:
        operand (Dictionary): второй операнд

      Возвращаемое значение:
        Number или None: результат операции равенства или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Dictionary):
      return Number(self.value == operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)

  def not_equal(self, operand):
    """
      Описание:
        Операция неравества между Dictionary и Dictionary

      Аргументы:
        operand (Dictionary): второй операнд

      Возвращаемое значение:
        Number или None: результат операции неравенства или нуль
        RuntimeError или None: сигнал ошибки или нуль
    """
    if isinstance(operand, Dictionary):
      return Number(self.value != operand.value, self.context), None

    return None, Value.illegal_operation(self, operand)


class Function(Value):
  """
    Описание:
      Класс типа Функция. Содержит набор выражений, которые нужно выполнить при вызове функции

    Аргументы:
      name (строка): название функции
      value (ListNode): список строк функции (элементы - *Node)
      argument_names (список): список аргументов со значениями по умолчанию (элементы - VariableAccessNode или VariableAssignNode)
      is_oneline (булево значение): является ли функция однострочной
      context (Context): хранилище, в котором находится элемент

    Поля класса:
      name (строка): название функции
      value (ListNode): список строк функции (элементы - *Node)
      argument_names (список): список аргументов со значениями по умолчанию (элементы - VariableAccessNode или VariableAssignNode)
      is_oneline (булево значение): является ли функция однострочной
      context (Context): хранилище, в котором находится элемент
      is_buildin (булево значение): параметр, отображающий, является ли функция встроенной
      internal_context (Context): внутреннее хранилище функции
  """
  def __init__(self, name, value, argument_names, is_oneline, context):
    super().__init__()
    self.name             = name or "<безымянная>"
    self.value            = value
    self.argument_names   = argument_names
    self.is_oneline       = is_oneline
    self.context          = context
    self.is_buildin       = self.name in build_in_functions_names
    self.internal_context = Context(self.name, self.context.variables, self.context, self.position_start)

    if not self.is_buildin:
      functions[self.name,] = dict.fromkeys(argument_names, Value)

  def __repr__(self):
    return f"Функция({self.name}; {List(self.get_argument_names(self.name), self.context)})"

  def copy(self):
    """
      Описание:
        Копирование элемента

      Аргументы: -

      Возвращаемое значение:
        Function: копия самого экзмепляра
    """
    return Function(self.name, self.value, self.argument_names, self.is_oneline, self.context).set_position(self.position_start, self.position_end)

  def execute(self, arguments):
    """
      Описание:
        Метод, отвечающий за исполнение функции

      Аргументы:
        arguments (список): список аргументов, передаваемых в функцию (элементы - VariableAccessNode и VariableAssignNode)

      Возвращаемое значение:
        RuntimeError или *Value: сигнал ошибки или возвращаемое значениее функции
    """
    logger = RuntimeLogger()

    argument_names = self.get_argument_names(self.name)
    initial_variables = self.internal_context.variables.copy()
    logger.register(self.populate_arguments(argument_names, arguments, self.internal_context))
    if logger.should_return():
      return logger

    if self.is_buildin:
      method = getattr(self, f"_{self.name}", self.no_interpret_method)
      return_value = logger.register(method(self.internal_context))
      if logger.should_return():
        return logger

      self.internal_context.variables = initial_variables.copy()

      return logger.success(return_value)

    from interpreter import Interpreter
    interpret = Interpreter(self.name)

    argument_names = [argument_name.variable.value for argument_name in list(argument_names)]
    error, *arguments = self.get_arguments(self.internal_context, self.name)
    if error:
      return logger.failure(error)

    self.internal_context.set_many_variables([[[name], value] for name, value in zip(argument_names, arguments)])

    value = logger.register(interpret.interpret(self.value, self.internal_context))
    if logger.should_return() and logger.return_value == None:
      return logger

    return_value = (value if self.is_oneline else logger.return_value) or logger.return_value or Number(None, self.context)

    self.internal_context.variables = initial_variables.copy()

    return logger.success(return_value)

  def check_instance(self, value, argument_name, context, types, custom_message=""):
    """
      Описание:
        Если тип не входит в список type, то будет возвращёт сигнал ошибки

      Аргументы:
        value (Value): проверяемое значение
        argument_name (строка): название проверяемого аргумента
        context (Context): хранилище, в котором находится элемент
        type (список): список типов, один из которых должен принадлежать тип аргумента value
        custom_message (строка): настраиваемое сообещние (по умолчанию - "")

      Возвращаемое значение:
        RuntimeError или None: сигнал об ошибке или нуль
    """
    if isinstance(value, types):
      return False

    type_names = []
    if types == types | Number:   type_names += ["числом"]
    if types == types | String:   type_names += ["строкой"]
    if types == types | List:     type_names += ["списком"]
    if types == types | Function: type_names += ["функцией"]

    return RuntimeLogger().failure(RuntimeError(
      self.position_start, self.position_end,
      custom_message or f"Аргумент \"{argument_name}\" должен быть {', '.join(type_names)}",
      context
    ))

  def populate_arguments(self, argument_names, arguments, context):
    """
      Описание:
        Метод, отвечающий за проверку и внесение значений аргументов в хранилище

      Аргументы:
        argument_names (список): названия аргументов
        arguments (список): значения аргументов
        context (Context): хранилище, в котором находится элемент

      Возвращаемое значение:
        RuntimeError или None: сигнал ошибки или нуль
    """
    from interpreter import Interpreter

    interpreter = Interpreter(self.name)

    logger = RuntimeLogger()

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

    function_positional_arguments_count = 0
    function_keyword_arguments = []
    for argument_name in argument_names:
      if isinstance(argument_name, VariableAssignNode):
        function_keyword_arguments += [argument_name.variable.value]
        continue

      function_positional_arguments_count += 1

    if len(arguments) > len(argument_names) or len(arguments) < function_positional_arguments_count:
      return logger.failure(RuntimeError(
        self.position_start, self.position_end,
        f"Количество аргументов функции '{self.name}' - {len(argument_names) if len(arguments) > len(argument_names) else function_positional_arguments_count}, но получено {len(arguments)}",
        self.context
      ))

    keywords = False
    for i in range(len(arguments)):
      argument_name = list(argument_names)[i]

      if not isinstance(argument_name, tuple):
        argument_name = argument_name.variable.value

      argument_value = arguments[i]
      if isinstance(argument_value, VariableAssignNode):
        keywords = True
        argument_name, argument_value = argument_value.variable.value, logger.register(interpreter.interpret(argument_value.value_node, context))
      elif keywords:
        return logger.failure(RuntimeError(
          argument_value.position_start, argument_value.position_end,
          "Позиционный аргумент следует за именованным",
          self.context
        ))

      context.set_variable(argument_name, argument_value)

    return logger.success(None)

  def get_arguments(self, context: Context, function_name, argument_names=None):
    """
      Описание:
        Метод для получения переменных из хранилища по именам

      Аргументы:
        context (Context): хранилище, в котором располагаются значения аргументов
        function_name (строка): название функции
        argument_names (список): названия аргументов (элементы - строки)

      Возвращаемое значение:
        RuntimeError или None: сигнал ошибки или нуль
        Неопределённое количество *Value: несколько значений, количетсво которых соответствует количеству аргументов
    """
    from interpreter import Interpreter

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

      if self.is_buildin:
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

      argument, default_value = argument.variable.value, argument.value
      arguments[argument] = types

      default_arguments[argument] = RuntimeLogger().register(interpreter.interpret(default_value, context))

    values = []
    for argument_name in arguments:
      argument = context.get_variable(argument_name, default_arguments.get(argument_name, Number(None, context)))
      error = self.check_instance(argument, argument_name, context, arguments[argument_name])
      if error:
        return error, *([Number(None, context)] * len(arguments))

      values += [argument]

    return None, *values

  def get_argument_names(self, function_name):
    """
      Описание:
        Метод для получения названий аргументов

      Аргументы:
        function_name (строка): название функции

      Возвращаемое значение:
        Список: названия аргументов функции
    """
    for function_names, arguments in functions.items():
      if function_name in function_names:
        return arguments

  def no_interpret_method(self):
    """
      Описание:
        Метод, вызывающий ошибку о том, что встроенная функция не объявлена

      Аргументы: -

      Возвращаемое значение: -
    """
    raise Exception(f"Метод _{self.name} не объявлен")

  # BuildIn Functions

  def _print(self, context: Context):
    error, value = self.get_arguments(context, "print")
    if error:
      return error

    value: Number | String | List | Dictionary

    print(str(value))

    return RuntimeLogger().success(Number(None, context))

  def _error(self, context: Context):
    error, value = self.get_arguments(context, "error")
    if error:
      return error

    value: Number | String | List | Dictionary

    return RuntimeLogger().failure(RuntimeError(
      self.position_start, self.position_end,
      str(value.value), context, False
    ))

  def _input(self, context: Context):
    error, value = self.get_arguments(context, "input")
    if error:
      return error

    value: Number | String | List | Dictionary
    return RuntimeLogger().success(String(input(str(value.value)), context))

  def _clear(self, context: Context):
    from os import name, system

    system("cls" if name == "nt" else "clear")
    return RuntimeLogger().success(Number(None, context))

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

    return RuntimeLogger().success(String(types[value.__class__.__name__], context))

  def _to_binary(self, context: Context):
    error, number = self.get_arguments(context, "to_binary")
    if error:
      return error

    number: Number
    binary_value = bin(number.value)[2:]
    return RuntimeLogger().success(String(binary_value, context))

  def _to_number(self, context: Context):
    error, value, base = self.get_arguments(context, "to_number")
    if error:
      return error

    value: Number | String
    base: Number

    if isinstance(value, Number):
      return RuntimeLogger().success(value.copy().set_context(context))

    if "." in value.value:
      return RuntimeLogger().success(Number(float(value.value), context))

    return RuntimeLogger().success(Number(int(value.value, base.value), context))

  def _to_integer(self, context: Context):
    error, value, base = self.get_arguments(context, "to_integer")
    if error:
      return error

    value: Number | String
    base: Number

    if isinstance(value, Number):
      return RuntimeLogger().success(Number(int(value.value), context))

    return RuntimeLogger().success(Number(int(value.value, base.value), context))

  def _to_float(self, context: Context):
    error, value = self.get_arguments(context, "to_float")
    if error:
      return error

    value: Number | String
    return RuntimeLogger().success(Number(float(value.value), context))

  def _to_string(self, context: Context):
    error, value = self.get_arguments(context, "to_string")
    if error:
      return error

    value: Number | String | List | Dictionary

    if isinstance(value, Number | List | Dictionary):
      return RuntimeLogger().success(String(str(value), context))

    return RuntimeLogger().success(value.set_context(context))

  def _to_list(self, context: Context):
    error, value = self.get_arguments(context, "to_list")
    if error:
      return error

    value: String | List | Dictionary

    if isinstance(value, String):
      return RuntimeLogger().success(List(list(map(lambda x: String(x, context), value.value)), context))
    elif isinstance(value, Dictionary):
      return RuntimeLogger().success(List(value.keys(), context))

    return RuntimeLogger().success(value.set_context(context))

  def _to_dictionary(self, context: Context):
    error, elements = self.get_arguments(context, "to_dictionary")
    if error:
      return error

    elements: List = elements.value

    for item in elements:
      if not isinstance(item, List) or len(item.value) != 2:
        return RuntimeLogger().failure(InvalidSyntaxError(
          elements.position_start, elements.position_end,
          "Список должен содержать массивы, состоящие из двух элементов "
        ))

    return RuntimeLogger().success(Dictionary(elements.value, context))

  def _items(self, context: Context):
    error, elements = self.get_arguments(context, "items")
    if error:
      return error

    elements: Dictionary = elements.items()
    return RuntimeLogger().success(List(elements, context))

  def _values(self, context: Context):
    error, elements = self.get_arguments(context, "values")
    if error:
      return error

    elements: Dictionary = elements.values()
    return RuntimeLogger().success(List(elements, context))

  def _keys(self, context: Context):
    error, elements = self.get_arguments(context, "keys")
    if error:
      return error

    elements: Dictionary = elements.keys()
    return RuntimeLogger().success(List(elements, context))

  def _random(self, context: Context):
    from random import random

    return RuntimeLogger().success(Number(random(), context))

  def _pause(self, context: Context):
    from time import sleep

    error, time = self.get_arguments(context, "pause")
    if error:
      return error

    time: Number

    sleep(time.value)

    return RuntimeLogger().success(Number(None, context))

  def _time(self, context: Context):
    from time import time

    return RuntimeLogger().success(Number(time(), context))

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
      return RuntimeLogger().failure(RuntimeError(
        self.position_start, self.position_end,
        f"Не удалось загрузить файл {file_name.value}\n" + str(exception),
        context
      ))

    _, error = run(file_name.value, code)

    if error:
      return RuntimeLogger().failure(RuntimeError(
        self.position_start, self.position_end,
        f"Не удалось закончить выполение кода {file_name.value}\n" + str(error),
        context
      ))

    return RuntimeLogger().success(Number(None, context))

  def _read_file(self, context: Context):
    error, file_name = self.get_arguments(context, "read_file")
    if error:
      return error

    file_name: String

    try:
      with open(file_name.value) as file:
        return RuntimeLogger().success(String(file.read(), context))
    except:
      return RuntimeLogger().failure(RuntimeError(
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

    return RuntimeLogger().success(Number(None, context))

  def _get_current_directory(self, context: Context):
    from os import getcwd

    return RuntimeLogger().success(String(getcwd(), context))

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
  """
    Описание:
      Класс типа Класс. Содержит набор выражений, которые нужно выполнить при создании экземпляра класса

    Аргументы:
      name (строка): название класса
      value (ListNode): список строк тела класса (элементы - *Node)
      parents (список): список названий родительских классов (элементы - строки)
      context (Context): хранилище, в котором находится элемент

    Поля класса:
      name (строка): название класса
      value (ListNode): список строк тела класса (элементы - *Node)
      parents (список): список названий родительских классов (элементы - строки)
      context (Context): хранилище, в котором находится элемент
      internal_context (Context): внутреннее хранилище функции
  """
  def __init__(self, name, value, parents, context):
    self.name = name
    self.value: Dictionary = value
    self.parents = parents
    self.context = context
    self.initial_method = self.value.get(String("__init__", context)) or self.value.get(String("__инициализация__", context))
    self.initial_method.argument_names = {argument_name: Value for argument_name in self.initial_method.argument_names}

  def __repr__(self):
    return f"Класс({self.name}; {self.value}; {self.parents})"

  def copy(self):
    """
      Описание:
        Копирование элемента

      Аргументы: -

      Возвращаемое значение:
        Class: копия самого экзмепляра
    """
    return Class(self.name, self.value, self.parents, self.context).set_position(self.position_start, self.position_end)

  def execute(self, arguments):
    """
      Описание:
        Метод, отвечающий за создание экземпляров класса

      Аргументы:
        arguments (список): список аргументов, передаваемых в функцию (элементы - VariableAccessNode и VariableAssignNode)

      Возвращаемое значение:
        RuntimeError или Object: сигнал ошибки или экземпляр класса
    """
    logger = RuntimeLogger()

    context = Context(self.name, self.context.variables, self.context, self.position_start)

    methods = Dictionary([], context)
    for parent in self.parents:
      parent = self.context.get_variable(parent)
      methods, error = methods.addition(parent.value)
      if error:
        return error

      method_names = [method.value for method in parent.value.keys()]
      if ("__init__" in method_names or "__инициализация__" in method_names) and len(self.initial_method.value.elements) == 0:
        self.initial_method = parent.initial_method

    methods, error = methods.addition(self.value)
    if error:
      return error

    arguments = [Object(methods.items(), context)] + arguments

    logger.register(self.populate_arguments(self.initial_method.argument_names, arguments, context))
    if logger.should_return():
      return logger

    from interpreter import Interpreter
    interpret = Interpreter(self.name)

    argument_names = [argument_name.variable.value for argument_name in self.initial_method.argument_names]
    error, *arguments = self.get_arguments(context, self.name, self.initial_method.argument_names)
    if error:
      return logger.failure(error)

    context.set_many_variables([[[name], value] for name, value in zip(argument_names, arguments)])

    value = logger.register(interpret.interpret(self.initial_method.value, context))
    if logger.should_return():
      return logger

    if logger.return_value:
      return logger.failure(InvalidSyntaxError(
        self.initial_method.position_start, self.initial_method.position_end,
        "Метод инициализации не может ничего возвращать"
      ))

    return_value = context.get_variable(argument_names[0])
    self.value = return_value

    return logger.success(return_value)


class Object(Dictionary):
  """
    Описание:
      Класс типа Объект. Содержит набор методов и полей для создаваемого экземпляра класса

    Аргументы:
      value (список): значение элемента. Набор методов и полей
      context (Context): хранилище, в котором находится элемент
  """
  def __init__(self, value, context):
    super().__init__(value, context)

  def __repr__(self):
    return f"Объект({str(self)})"

  def copy(self):
    return Object(self.value.copy(), self.context).set_position(self.position_start, self.position_end)


class Method(Function):
  """
    Описание:
      Класс типа Метод. Содержит набор выражений, которые нужно выполнить при вызове функции

    Аргументы:
      name (строка): название функции
      value (ListNode): список строк функции (элементы - *Node)
      argument_names (список): список аргументов со значениями по умолчанию (элементы - VariableAccessNode или VariableAssignNode)
      is_oneline (булево значение): является ли функция однострочной
      context (Context): хранилище, в котором находится элемент

    Поля класса:
      name (строка): название функции
      value (ListNode): список строк функции (элементы - *Node)
      argument_names (список): список аргументов со значениями по умолчанию (элементы - VariableAccessNode или VariableAssignNode)
      is_oneline (булево значение): является ли функция однострочной
      context (Context): хранилище, в котором находится элемент
      is_buildin (булево значение): параметр, отображающий, является ли функция встроенной
      internal_context (Context): внутреннее хранилище функции
  """
  def __init__(self, name, value, argument_names, is_oneline, context):
    super().__init__(name, value, argument_names, is_oneline, context)

  def __repr__(self):
    return f"Метод({self.name}; {list(self.get_argument_names(self.name))})"

  def copy(self):
    """
      Описание:
        Копирование элемента

      Аргументы: -

      Возвращаемое значение:
        Method: копия самого экзмепляра
    """
    return Method(self.name, self.value, self.argument_names, self.is_oneline, self.context).set_position(self.position_start, self.position_end)
