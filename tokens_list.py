from context import Context, SymbolTable
from errors_list import Position


class Token:
  def __init__(self, type: str, value: str = None, position_start: Position = None, position_end: Position = None):
    self.type = type
    self.value = value

    if position_start:
      self.position_start = position_start.copy()
      self.position_end = position_start.copy()

    if position_end:
      self.position_end = position_end.copy()

  def __repr__(self):
    return f"{self.position_start}::{self.position_end} ::: {self.type}{f':{self.value}' if self.value != None else ''}"

  def copy(self):
    return Token(self.type, self.value, self.position_start, self.position_end)

  def matches(self, type, values):
    return self.type == type and self.value in values

  def matches_keyword(self, values):
    return self.value in values


global_context = Context("<программа>")
global_symbol_table = SymbolTable()
global_context.symbol_table = global_symbol_table


def set_global_variables():
  from types_list import Number, build_in_functions

  global_symbol_table.set_many_variables([
      [["null", "нуль"], Number(None)],
      [["true", "истина"], Number(1)],
      [["false", "ложь"], Number(0)],
      *build_in_functions.items()
  ])


set_global_variables()


FILE_EXTENSION = "kors"

SPACE = "пробел"
PERCENT = "процент"
EXCLAMATION_MARK = "восклицательный знак"

INTEGER = "целое_число"
FLOAT = "дробное_число"
STRING = "строка"

ADDITION = "сумма"
SUBSTRACION = "разность"
MULTIPLICATION = "произведение"
DIVISION = "частное"
POWER = "возведение_в_степень"
ROOT = "извлечение_корня"
INCREMENT = "увеличить_на_один"
DECREMENT = "уменьшить_на_один"

IDENTIFIER = "идентификатор"
KEYWORD = "ключевое_слово"
ASSIGN = "присвоение"

EQUAL = "равно"
NOT_EQUAL = "не_равно"
LESS = "меньше"
MORE = "больше"
LESS_OR_EQUAL = "меньше_или_равно"
MORE_OR_EQUAL = "больше_или_равно"

OPEN_PAREN = "открывающая_скобка"
CLOSED_PAREN = "закрывающая_скобка"
OPEN_LIST_PAREN = "открывающая_скобка_списка"
CLOSED_LIST_PAREN = "закрывающая_скобка_списка"

COLON = "двоеточие"
COMMA = "запятая"
POINT = "точка"
BACK_SLASH = "обратная_косая_черта"

NEWLINE = "новая_строка"
END_OF_CONSTRUCTION = "конец_конструкции"
END_OF_FILE = "конец_файла"

AND = ["и", "and"]
OR = ["или", "or"]
NOT = ["не", "not"]

IF = ["если", "if"]
ELSE = ["иначе", "else"]
THEN = ["то", "then"]

FOR = ["для", "for"]
IN = ["в", "in"]
FROM = ["от", "from"]
TO = ["до", "to"]
AFTER = ["через", "after"]

WHILE = ["пока", "while"]
CONTINUE = ["продолжить", "continue"]
BREAK = ["прервать", "break"]

CHECK = ["проверить", "check"]

FUNCTION = ["функция", "function"]
RETURN = ["вернуть", "return"]

INCLUDE = ["включить", "include"]

KEYWORDS = AND + OR + NOT + IF + ELSE + \
  FOR + FROM + TO + AFTER + WHILE + FUNCTION + \
  RETURN + CONTINUE + BREAK + THEN + INCLUDE

COMPARISONS = [EQUAL, NOT_EQUAL, LESS, MORE, LESS_OR_EQUAL, MORE_OR_EQUAL]

ESCAPE_SEQUENCES = {"n": "\n", "н": "\n", "t": "\t", "т": "\t"}
