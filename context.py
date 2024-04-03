class Context:
  """
    Описание:
      Класс, экземпляр которого хранит переменные. Используется в главном процессе, функциях и классах

    Поля класса:
      name (строка): название для отображения ошибок
      variables (словарь): набор переменных (по умолчанию - пустой словарь)
      parent (Context): родительский контекст, для обращения к переменным выше уровнем (по умолчанию - None)
  """

  def __init__(self, name: str, variables: dict = {}, parent: super | None = None, parent_position=None):
    self.name = name
    self.variables: dict = variables.copy()
    self.parent: Context = parent
    self.parent_position = parent_position

  def __repr__(self):
    """
      Описание:
        Репрезентация - словарь variables

      Аргументы: -

      Возвращаемое значение:
        Словарь: переменные из хранилища
    """
    return self.variables

  def __str__(self):
    """
      Описание:
        Репрезентация - словарь variables, переведённый в строку

      Аргументы: -

      Возвращаемое значение:
        Строка: переменные из хранилища
    """
    return str(self.variables)

  def get_variable(self, name: str, default_value=None):
    """
      Описание:
        Метод для получения переменной по строке name. Если переменная не была найдена, то будет возвращено default_value

      Аргументы:
        name (строка): название искомой переменной
        default_value (Value):

      Возвращаемое значение:
        Value: присвоенное значение
    """
    value = self.variables.get(name, None)

    if value == None and self.parent:
      value = self.parent.get_variable(name)

    if value == None and default_value:
      return default_value

    return value

  def set_variable(self, name: str, value):
    """
      Описание:
        Метод для записи в переменную name значения value

      Аргументы:
        name (строка): название создаваемой переменной
        value (Value): присваиваемое переменной значение

      Возвращаемое значение: -
    """
    self.variables[name] = value

  def set_many_variables(self, variables):
    """
      Описание:
        Метод для записи значений в несколько переменных

      Аргументы:
        variables (массив массивов из массива строк и Value): массив из пар - массива строк (имём) и значения, которое будет им присвоено

      Возвращаемое значение: -
    """
    for names, value in variables:
      for name in names:
        self.set_variable(name, value)

  def delete_variable(self, name: str):
    """
      Описание:
        Метод для удаления переменных

      Аргументы:
        name (строка): имя удаляемой переменной

      Возвращаемое значение: -
    """
    del self.variables[name]
