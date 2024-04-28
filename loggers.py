from context import Context


class RuntimeLogger:
  """
    Сборщик сигналов, работающий во время исполнения программы

    Аргументы: -

    Поля класса:
      value (*Node): анализируемый нод абстрактного синтаксического дерева (по умолчанию - None)
      error (*Error): обнаруженная в ноде ошибка (по умолчанию - None)
      return_value (*Node): возвращаемое значение функции (по умолчанию - None)
      skip (булево значение): обнаружение операции пропуска итерации (по умолчанию - False)
      break (булево значение): обнаружение операции прерывания цикла (по умолчанию - False)
  """

  def __init__(self):
    self.reset()

  def reset(self):
    """
      Сброс значений сборщика на начальные

      Аргументы: -

      Возвращаемое значение: -
    """
    self.value = None
    self.error = None
    self.return_value = None
    self.skip_iteration = False
    self.break_loop = False

  def register(self, logger):
    """
      Регистрация предыдущих обработок из сборщика logger

      Аргументы:
        logger (*Logger): экземпляр логгера

      Возвращаемое значение:
        *Node: анализируемый нод абстрактного синтаксического дерева
    """
    self.error = logger.error
    self.return_value = logger.return_value
    self.skip_iteration = logger.skip_iteration
    self.break_loop = logger.break_loop
    return logger.value

  def success(self, value):
    """
      Подтверждение отсутствия ошибки в анализируемом ноде

      Аргументы:
        value (*Node): анализируемый нод синтаксического дерева

      Возвращаемое значение:
        RuntimeLogger: сам экземпляр
    """
    self.reset()
    self.value = value
    return self

  def return_signal(self, value):
    """
      Подтвеждение сигнала возврата функцией значения

      Аргументы:
        value (*Node): возвращаемое значение

      Возвращаемое значение:
        RuntimeLogger: сам экземпляр
    """
    self.reset()
    self.return_value = value
    return self

  def skip_signal(self):
    """
      Подтвеждение сигнала пропуска итерации

      Аргументы: -

      Возвращаемое значение:
        RuntimeLogger: сам экземпляр
    """
    self.reset()
    self.skip_iteration = True
    return self

  def break_signal(self):
    """
      Подтвеждение сигнала прерывания цикла

      Аргументы: -

      Возвращаемое значение:
        RuntimeLogger: сам экземпляр
    """
    self.reset()
    self.break_loop = True
    return self

  def failure(self, error):
    """
      Подтверждение ошибки в анализируемом ноде

      Аргументы:
        error (*Error): ошибка, обнаруженная в анализируемом ноде

      Возвращаемое значение:
        RuntimeLogger: сам экземпляр
    """
    self.reset()
    self.error = error
    return self

  def should_return(self):
    """
      Подтверждение сигнала, если он есть

      Аргументы: -

      Возвращаемое значение:
        *Error, *Node или булево значение: обнаруженная ошибка, возвращаемое значение функции или сигнал продолжения/прерывания цикла; если ничего не найдено, то будет возвращено False
    """
    return self.error or self.return_value or self.skip_iteration or self.break_loop


# TODO: Документация
class ParsingLogger:
  """
    Сборщик сигналов, работающий во время исполнения программы

    Аргументы: -

    Поля класса:
      error (*Error): обнаруженная в ноде ошибка (по умолчанию - None)
      node (*Node): анализируемый нод абстрактного синтаксического дерева (по умолчанию - None)
      registered_count
      next_count
  """

  def __init__(self):
    self.error = None
    self.node = None
    self.registered_count = 0
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
  """
    Класс, экземпляры которого обозначают положение элемента для отображения ошибок

    Аргументы:
      index (число): индекс элемента в очереди
      row (число): номер строки, на которой находится элемент
      column (число): номер столбец (символ), на котором находится элемент
      file (строка): название файла, в котором был обнаружен элемент
      text (строка): текст файла

    Поля класса:
      index (число): индекс элемента в очереди
      row (число): номер строки, на которой находится элемент
      column (число): номер столбец (символ), на котором находится элемент
      file (строка): название файла, в котором был обнаружен элемент
      text (строка): текст файла
  """

  def __init__(self, index: int, row: int, column: int, file: str, text: str):
    self.index = index
    self.row = row
    self.column = column
    self.file = file
    self.text = text

  def __repr__(self):
    return f"{self.row}:{self.column}"

  def next(self, char: str = None):
    """
      Метод для продвижения положения

      Аргументы:
        char (строка): символ, положение которого определяется

      Возвращаемое значение:
        Position: сам экземпляр класса
    """
    self.index += 1
    self.column += 1

    if char == "\n":
      self.row += 1
      self.column = 1

    return self

  def copy(self):
    """
      Дублирование экземпляра класса

      Аргументы: -

      Возвращаемое значение:
        Position: копия экземпляра класса
    """
    return Position(self.index, self.row, self.column, self.file, self.text)


class Error:
  """
    Описание:
      Родительский класс ошибок

    Аргументы:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки (по умолчанию: "")

    Поля класса:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки
  """

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
    """
      Описание:
        Метод для выделения места ошибки

      Аргументы: -

      Возвращаемое значение:
        Строка: подсвеченный фрагмент кода, где произошла ошибка
    """
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
  """
    Описание:
      Ошибка, описывающая обнаружение неизвестного символа

    Аргументы:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      details (строка): детали ошибки (по умолчанию: "")

    Поля класса:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки
  """

  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неизвестный символ", details)


class BadIdentifierError(Error):
  """
    Описание:
      Ошибка, описывающая обнаружение неизвестного идентификатора

    Аргументы:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      details (строка): детали ошибки (по умолчанию: "")

    Поля класса:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки
  """

  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неизвестный идентификатор", details)


class BadCharacterError(Error):
  """
    Описание:
      Ошибка, описывающая обнаружение неподходящего символа

    Аргументы:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      details (строка): детали ошибки (по умолчанию: "")

    Поля класса:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки
  """

  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неподходящий символ", details)


class InvalidSyntaxError(Error):
  """
    Описание:
      Ошибка, описывающая обнаружение неверного синтаксиса

    Аргументы:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      details (строка): детали ошибки (по умолчанию: "")

    Поля класса:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки
  """

  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неверный синтаксис", details)


class InvalidKeyError(Error):
  """
    Описание:
      Ошибка, описывающая обнаружение неверного ключа

    Аргументы:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      details (строка): детали ошибки (по умолчанию: "")

    Поля класса:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки
  """

  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Неверный ключ", details)


class IndexOutOfRangeError(Error):
  """
    Описание:
      Ошибка, описывающая обнаружение индекса, выходящего за пределы диапазона

    Аргументы:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      details (строка): детали ошибки (по умолчанию: "")

    Поля класса:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки
  """

  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Индекс вне диапазона", details)


class ModuleNotFoundError(Error):
  """
    Описание:
      Ошибка, описывающая обнаружение неизвестного модуля

    Аргументы:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      details (строка): детали ошибки (по умолчанию: "")

    Поля класса:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки
  """

  def __init__(self, position_start: Position, position_end: Position, details: str = ""):
    super().__init__(position_start, position_end, "Модуль не найден", details)


class RuntimeError(Error):
  """
    Описание:
      Ошибка, описывающая обнаружение неизвестного модуля

    Аргументы:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      details (строка): детали ошибки (по умолчанию: "")
      context (Context): контекст, в котором найдена ошибка
      highlight (bool): переменная, отвечающая за подстветку ошибки (по умолчанию: True)

    Поля класса:
      position_start (Position): начальная позиция элемента, в котором найдена ошибка
      position_end (Position): конечная позиция элемента, в котором найдена ошибка
      error (строка): текст ошибки
      details (строка): детали ошибки
      context (Context): контекст, в котором найдена ошибка
      highlight (bool): переменная, отвечающая за подстветку ошибки
  """

  def __init__(self, position_start: Position, position_end: Position, details: str, context: Context, highlight: bool = True):
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
    """
      Описание:
        Генерация обратной связи (полное сообщение об ошибке)

      Аргументы: -

      Возвращаемое значение:
        Строка: обратная связь (полное сообщение об ошибке)
    """
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
