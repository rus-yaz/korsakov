from typing import Optional, Union

from context import Context
from loggers import Position


class Token:
  def __init__(self, token_type: str, value: Optional[Union[str, int, float]] = None, position_start: Optional[Position] = None, position_end: Optional[Position] = None):
    self.token_type = token_type
    self.value = value

    self.position_start = None
    self.position_end = None

    if position_start:
      self.position_start = position_start.copy()
      self.position_end = position_start.copy()

    if position_end:
      self.position_end = position_end.copy()

  def __repr__(self):
    return f"Token(type={self.token_type!r}, value={self.value!r}, position_start={self.position_start}, position_end={self.position_end})"

  def copy(self):
    return Token(self.token_type, self.value, self.position_start, self.position_end)

  def check_type(self, *types):
    return self.token_type in types

  def check_keyword(self, *keywords):
    return self.value in [keyword for keywords_pair in keywords for keyword in keywords_pair]


global_context = Context("<программа>")

SPACE            = "пробел"
PERCENT          = "процент"
EXCLAMATION_MARK = "восклицательный знак"

COLON      = "двоеточие"
SEMICOLON  = "точка_с_запятой"
POINT      = "точка"
BACK_SLASH = "обратная_косая_черта"

INTEGER          = "целое_число"
FLOAT            = "дробное_число"
STRING           = "строка"
ESCAPE_SEQUENCES = {"n": "\n", "н": "\n", "t": "\t", "т": "\t"}

ADDITION       = "сумма"
SUBTRACTION    = "разность"
MULTIPLICATION = "произведение"
DIVISION       = "частное"
POWER          = "возведение_в_степень"
ROOT           = "извлечение_корня"
INCREMENT      = "увеличить_на_один"
DECREMENT      = "уменьшить_на_один"

IDENTIFIER = "идентификатор"
KEYWORD    = "ключевое_слово"
ASSIGN     = "присвоение"

EQUAL         = "равно"
NOT_EQUAL     = "не_равно"
LESS          = "меньше"
MORE          = "больше"
LESS_OR_EQUAL = "меньше_или_равно"
MORE_OR_EQUAL = "больше_или_равно"
COMPARISONS   = [EQUAL, NOT_EQUAL, LESS, MORE, LESS_OR_EQUAL, MORE_OR_EQUAL]

OPEN_PAREN        = "открывающая_скобка"
CLOSED_PAREN      = "закрывающая_скобка"
OPEN_LIST_PAREN   = "открывающая_скобка_списка"
CLOSED_LIST_PAREN = "закрывающая_скобка_списка"

NEWLINE             = "новая_строка"
END_OF_CONSTRUCTION = "конец_конструкции"
END_OF_FILE         = "конец_файла"

AND = ["и", "and"]
OR  = ["или", "or"]
NOT = ["не", "not"]

IF    = ["если", "if"]
THEN  = ["то", "then"]
ELSE  = ["иначе", "else"]

CHECK = ["проверить", "check"]
ON = ["при", "on"]

FOR   = ["для", "for"]
OF    = ["из", "of"]
FROM  = ["от", "from"]
TO    = ["до", "to"]
AFTER = ["через", "after"]

WHILE    = ["пока", "while"]
SKIP = ["пропустить", "skip"]
BREAK    = ["прервать", "break"]

CLASS    = ["класс", "class"]
FUNCTION = ["функция", "function"]
RETURN   = ["вернуть", "return"]

DELETE  = ["удалить", "delete"]
INCLUDE = ["включить", "include"]

KEYWORDS =\
  AND + OR + NOT +\
  IF + ELSE + THEN +\
  CHECK + ON +\
  FOR + OF + FROM + TO + AFTER +\
  WHILE + SKIP + BREAK +\
  CLASS + FUNCTION + RETURN +\
  DELETE + INCLUDE


def set_default_variables():
  from classes import Function, Number, functions

  global_context.set_many_variables([
    [["null", "нуль"], Number(None, global_context)],
    [["true", "истина"], Number(1, global_context)],
    [["false", "ложь"], Number(0, global_context)],
    *[
      [functions_names, Function(functions_names[0], None, None, None, global_context)]
      for functions_names in functions
    ],
  ])


set_default_variables()
