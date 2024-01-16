class RuntimeResponse:
  def __init__(self):
    self.reset()

  def __repr__(self):
    return f"RuntimeResponse({self.value})"

  def reset(self):
    self.value = None
    self.error = None
    self.function_return_value = None
    self.continue_loop = False
    self.break_loop = False

  def register(self, response):
    self.error = response.error
    self.function_return_value = response.function_return_value
    self.continue_loop = response.continue_loop
    self.break_loop = response.break_loop
    return response.value

  def success(self, value):
    self.reset()
    self.value = value
    return self

  def success_return(self, value):
    self.reset()
    self.function_return_value = value
    return self

  def success_continue(self):
    self.reset()
    self.continue_loop = True
    return self

  def success_break(self):
    self.reset()
    self.break_loop = True
    return self

  def failure(self, error):
    self.reset()
    self.error = error
    return self

  def should_return(self):
    return self.error or self.function_return_value or self.continue_loop or self.break_loop
