class Context:
  def __init__(self, name, variables={}, parent=None, parent_position=None):
    self.name = name
    self.variables: dict = variables.copy()
    self.parent: Context = parent
    self.parent_position = parent_position

  def __repr__(self):
    return self.variables

  def __str__(self):
    return str(self.variables)

  def get_variable(self, name, default_value=None):
    value = self.variables.get(name, None)

    if value == None and self.parent:
      value = self.parent.get_variable(name)

    if value == None and default_value:
      return default_value

    return value

  def set_variable(self, name, value):
    self.variables[name] = value

  def set_many_variables(self, variables):
    for names, value in variables:
      for name in names:
        self.set_variable(name, value)

  def delete_variable(self, name):
    del self.variables[name]
