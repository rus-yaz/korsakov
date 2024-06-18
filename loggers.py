from typing import Optional

from context import Context


class RuntimeLogger:
  def __init__(self):
    self.value = None
    self.error = None
    self.return_value = None
    self.skip_iteration = False
    self.break_loop = False

  def reset(self):
    self.value = None
    self.error = None
    self.return_value = None
    self.skip_iteration = False
    self.break_loop = False

  def register(self, logger):
    self.error = logger.error
    self.return_value = logger.return_value
    self.skip_iteration = logger.skip_iteration
    self.break_loop = logger.break_loop
    return logger.value

  def success(self, value):
    self.reset()
    self.value = value
    return self

  def return_signal(self, value):
    self.reset()
    self.return_value = value
    return self

  def skip_signal(self):
    self.reset()
    self.skip_iteration = True
    return self

  def break_signal(self):
    self.reset()
    self.break_loop = True
    return self

  def failure(self, error):
    self.reset()
    self.error = error
    return self

  def should_return(self):
    return self.error or self.return_value or self.skip_iteration or self.break_loop


class ParsingLogger:
  def __init__(self):
    self.error = None
    self.node: Optional[Node] = None
    self.registered_count = 0
    self.to_reverse_count = 0
    self.next_count = 0

  def next(self, parser):
    self.registered_count = 1
    self.next_count += 1
    parser.next()

  def register(self, logger):
    self.registered_count = logger.next_count
    self.next_count += logger.next_count
    if logger.error:
      self.error = logger.error

    return logger.node

  def try_register(self, logger):
    if logger.error:
      self.to_reverse_count = logger.next_count
      return None

    return self.register(logger)

  def success(self, node):
    self.node = node
    return self

  def failure(self, error):
    if not self.error or not self.next_count:
      self.error = error

    return self


class Position:
  def __init__(self, index: int, row: int, column: int, file: str, text: str):
    self.index = index
    self.row = row
    self.column = column
    self.file = file
    self.text = text

  def __repr__(self):
    return f"Position(index={self.index}, row={self.row}, column={self.column})"

  def next(self, char: Optional[str] = None):
    self.index += 1
    self.column += 1

    if char == "\n":
      self.row += 1
      self.column = 1

    return self

  def copy(self):
    return Position(self.index, self.row, self.column, self.file, self.text)


class Error:
  def __init__(self, position_start: Position, position_end: Position, error: str, details: str = ""):
    self.position_start = position_start
    self.position_end = position_end
    self.error = error
    self.details = details

  def __repr__(self):
    result = f"Файл {self.position_start.file}, строка {self.position_start.row + 1}\n\n"
    result += f"Ошибка: {self.error}{f': {self.details}' if self.details else ''}\n"
    result += self.highlighting_with_arrows()

    return result

  def highlighting_with_arrows(self):
    result = ""
    text = self.position_start.text

    index_start = max(text.rfind("\n", 0, self.position_start.index), 0)
    index_end = text.find("\n", index_start + 1)
    if index_end < 0:
      index_end = len(text)

    line_length = self.position_end.row - self.position_start.row + 1
    for i in range(line_length):
      line = text[index_start:index_end]
      start = self.position_start.column - 1 if not i else 0
      end = self.position_end.column if i == line_length - 1 else len(line) - 1

      result += line + "\n" + " " * start + "^" * (end - start)

      index_start = index_end
      index_end = text.find("\n", index_start + 1)
      if index_end < 0:
        index_end = len(text)

    return result.replace("\t", "")


class IllegalCharacterError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неизвестный символ", details)


class BadIdentifierError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неизвестный идентификатор", details)


class BadCharacterError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неподходящий символ", details)


class InvalidSyntaxError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неверный синтаксис", details)


class InvalidKeyError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неверный ключ", details)


class IndexOutOfRangeError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Индекс вне диапазона", details)


class ModuleNotFoundError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Модуль не найден", details)


class RuntimeError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str, context: Context | None, highlight: bool = True):
    super().__init__(position_start, position_end, "Ошибка во время выполнения", details)
    self.context = context
    self.highlight = highlight

  def __repr__(self):
    result = "Ошибка\n"
    result += self.generate_traceback()
    result += f"{self.error}: {self.details}\n"
    if self.highlight:
      result += self.highlighting_with_arrows()

    return result

  def generate_traceback(self):
    traceback = ""
    position = self.position_start
    context = self.context

    while context:
      if not position:
        break
      traceback = f"  Файл {position.file}, строка {position.row + 1}, в {context.name}\n{traceback}"
      position = context.parent_position
      context = context.parent

    return f"Обратная связь (последний вызов):\n{traceback}"
