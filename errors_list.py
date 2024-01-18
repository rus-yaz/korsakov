from context import Context


class Position:
  def __init__(self, index: int, row: int, column: int, file, text: str):
    self.index = index
    self.row = row
    self.column = column
    self.file = file
    self.text = text

  def __repr__(self):
    return f"{self.row}:{self.column}"

  def advance(self, char: str = None):
    self.index += 1
    self.column += 1

    if char == "\n":
      self.row += 1
      self.column = 0

    return self

  def copy(self):
    return Position(self.index, self.row, self.column, self.file, self.text)


class Error:
  def __init__(self, position_start: Position, position_end: Position, name: str, details: str):
    self.position_start = position_start
    self.position_end = position_end
    self.name = name
    self.details = details

  def __repr__(self):
    result = f"Файл {self.position_start.file}, строка {self.position_start.row + 1}\n\n"
    result += f"Ошибка: {self.name}: {self.details}\n"
    result += self.highlighting_with_arrows()
    return result

  def highlighting_with_arrows(self):
    result = ""
    text = self.position_start.text

    index_start = max(text.rfind("\n", 0, self.position_start.index), 0)
    index_end = text.find("\n", index_start + 1)
    if index_end < 0:
      index_end = len(text)

    line_count = self.position_end.row - self.position_start.row + 1
    for i in range(line_count):
      line = text[index_start:index_end]
      column_start = self.position_start.column - 1 if not i else 0
      column_end = self.position_end.column if i == line_count - 1 else len(line) - 1

      result += line + "\n" + " " * column_start + "^" * (column_end - column_start)

      index_start = index_end
      index_end = text.find("\n", index_start + 1)
      if index_end < 0:
        index_end = len(text)

    return result.replace("\t", "")


class IllegalCharacterError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str):
    super().__init__(position_start, position_end, "Неизвестный символ", details)


class BadIdentifierError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str):
    super().__init__(
        position_start, position_end, "Неизвестный идентификатор", details
    )


class BadCharacterError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str):
    super().__init__(position_start, position_end, "Неподходящий символ", details)


class InvalidSyntaxError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str):
    super().__init__(position_start, position_end, "Неверный синтаксис", details)


class IndexOutOfRangeError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str):
    super().__init__(position_start, position_end, "Индекс вне массива", details)


class ModuleNotFoundError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str):
    super().__init__(position_start, position_end, "Модуль не найден", details)


class RuntimeError(Error):
  def __init__(self, position_start: Position, position_end: Position, details: str, context: Context, highlight: bool = True):
    super().__init__(position_start, position_end, "Ошибка во время выполнения", details)
    self.context = context
    self.highlight = highlight

  def __repr__(self):
    result = "Ошбика\n"
    result += self.generate_traceback()
    result += f"{self.name}: {self.details}\n"
    if self.highlight:
      result += self.highlighting_with_arrows()

    return result

  def generate_traceback(self):
    traceback = ""
    position = self.position_start
    context = self.context

    while context:
      traceback = f"  Файл {position.file}, строка {position.row + 1}, в {context.name}\n{traceback}"
      position = context.parent_position
      context = context.parent

    return f"Обратная связь (последний вызов):\n{traceback}"
