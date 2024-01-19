from errors_list import InvalidSyntaxError
from nodes_list import *
from tokens_list import *


class Parser:
  def __init__(self, tokens: [Token]):
    self.tokens = tokens

    self.token_index = 0
    self.advance()

  def advance(self):
    if self.token_index < len(self.tokens):
      self.token: Token = self.tokens[self.token_index]

    self.token_index += 1

    return self.token

  def reverse(self, amount=1):
    self.token_index -= amount
    self.update_token()
    return self.token

  def update_token(self):
    if self.token_index >= 0 and self.token_index < len(self.tokens):
      self.token = self.tokens[self.token_index - 1]

  def parse(self):
    result = self.statements()

    if not result.error and self.token.type != END_OF_FILE:
      return result.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался математический оператор (`+`, `-`, `*`, `/`)"
      ))

    return result

  def expression(self):
    response = ParseResponse()

    if self.token.type == IDENTIFIER:
      variable = self.token
      response.advance(self)

      if self.token.type == ASSIGN:
        response.advance(self)

        expression = response.register(self.expression())
        if response.error:
          return response

        return response.success(VariableAssignNode(variable, expression))

      self.token = variable
      self.token_index -= 1

    node = response.register(self.binary_operation(
      [[KEYWORD, (AND + OR)[i]] for i in range(len(AND + OR))],
      self.comparison_expression
    ))

    if response.error:
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались Идентификатор, Целое число, Дробное число, `+`, `-` или `(`"
      ))

    return response.success(node)

  def binary_operation(self, operators, left_function, right_function=None):
    if right_function == None:
      right_function = left_function

    response = ParseResponse()
    left: Token = response.register(left_function())
    if response.error:
      return response

    while self.token.type in operators or [self.token.type, self.token.value] in operators:
      operator = self.token
      response.advance(self)

      right: Token = response.register(right_function())
      if response.error:
        return response

      left = BinaryOperationNode(left, operator, right)

    return response.success(left)

  def atom(self):
    response = ParseResponse()
    token = self.token

    if token.type in [INTEGER, FLOAT]:
      response.advance(self)
      return response.success(NumberNode(token))
    elif token.type == STRING:
      response.advance(self)
      return response.success(StringNode(token))

    elif token.type == IDENTIFIER:
      response.advance(self)
      return response.success(VariableAccessNode(token))

    elif token.type == OPEN_PAREN:
      response.advance(self)

      expression = response.register(self.expression())
      if response.error:
        return response

      if self.token.type == CLOSED_PAREN:
        response.advance(self)
        return response.success(expression)
      else:
        return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидалось `)`)"
        ))
    elif token.type == OPEN_LIST_PAREN:
      list_expression = response.register(self.list_expression())
      if response.error:
        return response
      return response.success(list_expression)

    elif token.matches_keyword(IF):
      if_expression = response.register(self.if_expression())
      if response.error:
        return response
      return response.success(if_expression)

    elif token.matches_keyword(FOR):
      for_expression = response.register(self.for_expression())
      if response.error:
        return response
      return response.success(for_expression)
    elif token.matches_keyword(WHILE):
      while_expression = response.register(self.while_expression())
      if response.error:
        return response

      return response.success(while_expression)

    elif token.matches_keyword(FUNCTION):
      function_expression = response.register(self.function_expression())
      if response.error:
        return response
      return response.success(function_expression)

    elif token.matches_keyword(INCLUDE):
      include_statement = response.register(self.include_statement())
      if response.error:
        return response

      return response.success(include_statement)

    return response.failure(InvalidSyntaxError(
      token.position_start, token.position_end,
      "Ожидались Идентификатор, Целое число, Дробное число, `+`, `-` или `(`)"
    ))

  def function_call(self):
    response = ParseResponse()
    atom = response.register(self.atom())
    if response.error:
      return response

    if self.token.type == OPEN_PAREN:
      response.advance(self)
      argument_nodes = []

      while self.token.type == NEWLINE:
        response.advance(self)

      if self.token.type == CLOSED_PAREN:
        response.advance(self)
      else:
        argument_nodes += [response.register(self.expression())]
        if response.error:
          return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидались `если` (`if`), `для` (`for`), `пока` (`while`), `функция` (`function`), Целое число, Дробное число, Идентификатор, `)`"
          ))

        while self.token.type == COMMA:
          response.advance(self)

          while self.token.type == NEWLINE:
            response.advance(self)

          argument_nodes += [response.register(self.expression())]
          if response.error:
            return response

        while self.token.type == NEWLINE:
          response.advance(self)

        if self.token.type != CLOSED_PAREN:
          return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидалось `,` или `)`"
          ))

        response.advance(self)

      return response.success(FunctionCallNode(atom, argument_nodes))

    return response.success(atom)

  def power_root(self):
    return self.binary_operation([POWER, ROOT], self.function_call, self.factor)

  def factor(self):
    response = ParseResponse()
    token = self.token

    if token.type in [SUBSTRACION, ROOT, INCREMENT, DECREMENT]:
      response.advance(self)
      factor = response.register(self.factor())

      if response.error:
        return response
      return response.success(UnaryOperationNode(token, factor))

    return self.power_root()

  def term(self):
    return self.binary_operation([MULTIPLICATION, DIVISION], self.factor)

  def comparison_expression(self):
    response = ParseResponse()

    if self.token.matches_keyword(NOT):
      token = self.token
      response.advance(self)

      node = response.register(self.comparison_expression())
      if response.error:
        return response
      return response.success(UnaryOperationNode(token, node))

    node = response.register(self.binary_operation(
        [EQUAL, NOT_EQUAL, LESS, MORE, LESS_OR_EQUAL, MORE_OR_EQUAL],
        self.arithmetical_expression
    ))

    if response.error:
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидались Целое число, Дробное число, Идентификатор, `+`, `-`, `(` или `не` (`not`)"
      ))

    return response.success(node)

  def arithmetical_expression(self):
    return self.binary_operation([ADDITION, SUBSTRACION], self.term)

  def list_expression(self):
    response = ParseResponse()
    element_nodes = []
    position_start = self.token.position_start.copy()

    if self.token.type != OPEN_LIST_PAREN:
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `%(`"
      ))

    response.advance(self)

    while self.token.type == NEWLINE:
      response.advance(self)

    if self.token.type == CLOSED_LIST_PAREN:
      response.advance(self)
    else:
      element_nodes += [response.register(self.expression())]

      if response.error:
        return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидались `если` (`if`), `для` (`for`), `пока` (`while`), `функция` (`function`), Целое число, Дробное число, Идентификатор, `)`"
        ))

      while self.token.type == COMMA:
        response.advance(self)

        while self.token.type == NEWLINE:
          response.advance(self)

        if self.token.type == CLOSED_LIST_PAREN:
          break

        element_nodes += [response.register(self.expression())]
        if response.error:
          return response

      while self.token.type == NEWLINE:
        response.advance(self)

      if self.token.type != CLOSED_LIST_PAREN:
        return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидались `,` или `)%`"
        ))

      response.advance(self)
    return response.success(ListNode(
      element_nodes,
      None,
      position_start,
      self.token.position_end.copy()
    ))

  def if_expression(self):
    response = ParseResponse()
    cases = []
    else_case = None

    if not self.token.matches_keyword(IF):
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          f"Ожидалось `{IF}`"
      ))

    response.advance(self)

    condition = response.register(self.expression())
    if response.error:
      return response

    if not self.token.matches_keyword(THEN):
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `то` (`then`)"
      ))

    response.advance(self)

    if self.token.type == NEWLINE:
      response.advance(self)

      statements = response.register(self.statements())
      if response.error:
        return response

      cases += [[condition, statements, True]]

      if self.token.type == END_OF_CONSTRUCTION:
        response.advance(self)
      else:
        else_case = response.register(self.else_expression())
        if response.error:
          return response
    else:
      expression = response.register(self.statement())
      if response.error:
        return response

      cases += [[condition, expression, False]]

      else_case = response.register(self.else_expression())
      if response.error:
        return response

    return response.success(IfNode(cases, else_case))

  def else_expression(self):
    response = ParseResponse()
    else_case = None

    if not self.token.matches_keyword(ELSE):
      return response.success(else_case)

    response.advance(self)

    if self.token.type == NEWLINE:
      response.advance(self)

      statements = response.register(self.statements())
      if response.error:
        return response

      else_case = [statements, True]

      if not self.token.type == END_OF_CONSTRUCTION:
        return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидался конец конструкции (`---`, `===` или `%%%`)"
        ))

      response.advance(self)
    else:
      expression = response.register(self.statement())
      if response.error:
        return response

      else_case = [expression, False]

    return response.success(else_case)

  def for_expression(self):
    response = ParseResponse()

    if not self.token.matches_keyword(FOR):
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался `for`"
      ))

    response.advance(self)

    if self.token.type != IDENTIFIER:
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался Идентификатор"
      ))

    variable_name = self.token
    response.advance(self)

    if self.token.matches_keyword(FROM):
      response.advance(self)

      start_value = response.register(self.expression())
      if response.error:
        return response

      if not self.token.matches_keyword(TO):
        return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидалось `to`"
        ))

      response.advance(self)

      end_value = response.register(self.expression())
      if response.error:
        return response

      if self.token.matches_keyword(AFTER):
        response.advance(self)

        step_value = response.register(self.expression())
        if response.error:
          return response
      else:
        step_value = None
    elif self.token.matches_keyword(IN):
      response.advance(self)

      start_value = response.register(self.expression())
      if response.error:
        return response
      end_value = step_value = None
    else:
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `from` или `in`"
      ))

    if self.token.type == NEWLINE:
      response.advance(self)
      body = response.register(self.statements())
      if response.error:
        return response

      if not self.token.type == END_OF_CONSTRUCTION:
        return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидался конец конструкции (`---`, `===` или `%%%`)"
        ))
      response.advance(self)

      return response.success(ForNode(
          variable_name, start_value, end_value,
          step_value, body, True
      ))

    body = response.register(self.statement())
    if response.error:
      return response

    return response.success(ForNode(
        variable_name, start_value,
        end_value, step_value,
        body, False
    ))

  def while_expression(self):
    response = ParseResponse()
    if not self.token.matches_keyword(WHILE):
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `while`"
      ))

    response.advance(self)

    condition = response.register(self.expression())
    if response.error:
      return response

    if self.token.type == NEWLINE:
      response.advance(self)

      body = response.register(self.statements())
      if response.error:
        return response

      if not self.token.type == END_OF_CONSTRUCTION:
        return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидался конец конструкции (`---`, `===` или `%%%`)"
        ))

      response.advance(self)

      return response.success(WhileNode(condition, body, True))

    body = response.register(self.statement())
    if response.error:
      return response

    return response.success(WhileNode(condition, body, False))

  def function_expression(self):
    response = ParseResponse()
    if not self.token.matches_keyword(FUNCTION):
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `функция` (`function`)"
      ))

    response.advance(self)

    variable_name = self.token if self.token.type == IDENTIFIER else None

    response.advance(self)
    if self.token.type != OPEN_PAREN:
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        f"Ожидалось `(`{' или Идентификатор' if variable_name else ''}"
      ))

    response.advance(self)

    argument_names = []

    if self.token.type == IDENTIFIER:
      argument_name = self.token.value
      postiion = self.token.position_start, self.token.position_end
      response.advance(self)

      default_values = False
      if self.token.type == ASSIGN:
        default_values = True

        response.advance(self)
        if self.token.type not in [STRING, INTEGER, FLOAT, IDENTIFIER]:
          return response.failure(InvalidSyntaxError(
              self.token.position_start, self.token.position_end,
              "Ожидались Строка, Число или Идентификатор"
          ))

        argument_name += f"={f"\"{self.token.value}\"" if self.token.type ==
                             STRING else self.token.value}"
        response.advance(self)

      argument_names += [Token(IDENTIFIER, argument_name, *postiion)]

      while self.token.type == COMMA:
        response.advance(self)

        if self.token.type != IDENTIFIER:
          return response.failure(InvalidSyntaxError(
              self.token.position_start, self.token.position_end,
              "Ожидался Идентификатор"
          ))

        argument_name = self.token.value
        postiion = self.token.position_start, self.token.position_end
        response.advance(self)

        if self.token.type == ASSIGN:
          argument_name += "="
          response.advance(self)
          if self.token.type not in [IDENTIFIER, INTEGER, FLOAT, STRING, OPEN_LIST_PAREN]:
            return response.failure(InvalidSyntaxError(
              self.token.position_start, self.token.position_end,
              "Ожидались Идентификатор, Число, Строка или Список"
            ))

          if self.token.type == OPEN_LIST_PAREN:
            argument_name += "%("
            response.advance(self)

            while self.token.type == COMMA:
              response.advance(self)
              argument_name += f"{f"\"{self.token.value}\"" if self.token.type == STRING else self.token.value}"
              response.advance(self)

            argument_name += ")%"
          else:
            argument_name += f"{f"\"{self.token.value}\"" if self.token.type == STRING else self.token.value}"

          response.advance(self)
        elif default_values:
          return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидалось значение по умолчанию"
          ))

        argument_names += [Token(IDENTIFIER, argument_name, *postiion)]

      if self.token.type != CLOSED_PAREN:
        return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидались `,` или `)`"
        ))
    else:
      if self.token.type != CLOSED_PAREN:
        return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидались Идентификатор или `)`"
        ))

    response.advance(self)

    if self.token.type != NEWLINE:
      response.advance(self)

      return_node = response.register(self.expression())

      if response.error:
        return response

      return response.success(FunctionDefinitionNode(
          variable_name, argument_names,
          return_node, True
      ))

    response.advance(self)

    body: ListNode = response.register(self.statements())
    if response.error:
      return response

    if self.token.type != END_OF_CONSTRUCTION:
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидался конец конструкции (`---`, `===` или `%%%`)"
      ))

    response.advance(self)

    return response.success(FunctionDefinitionNode(
      variable_name, argument_names,
      body, False
    ))

  def include_statement(self):
    response = ParseResponse()

    position_start = self.token.position_start.copy()

    if not self.token.matches_keyword(INCLUDE):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `включить` (`include`)"
      ))

    modules: list[str] = []

    while self.token.matches_keyword(INCLUDE):
      response.advance(self)

      if self.token.type != STRING:
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось название модуля"
        ))

      modules += [self.token]

    response.advance(self)

    return response.success(IncludeNode(modules, position_start, self.token.position_end.copy()))

  def statements(self):
    response = ParseResponse()
    statements = []
    position_start = self.token.position_start.copy()

    while self.token.type == NEWLINE:
      response.advance(self)

    statement = response.register(self.statement())
    if response.error:
      return response

    statements += [statement]

    more_statements = True

    while True:
      newline_count = 0
      while self.token.type == NEWLINE:
        response.advance(self)
        newline_count += 1

      if newline_count == 0:
        more_statements = False

      if not more_statements:
        break

      statement = response.try_register(self.statement())

      if not statement:
        self.reverse(response.to_reverse_count)
        more_statements = False
        continue

      statements += [statement]

    return response.success(ListNode(
      statements, None, position_start,
      self.token.position_end.copy()
    ))

  def statement(self):
    response = ParseResponse()
    position_start = self.token.position_start.copy()

    if self.token.matches_keyword(RETURN):
      response.advance(self)
      expression = response.try_register(self.expression())
      if not expression:
        self.reverse(response.to_reverse_count)

      return response.success(ReturnNode(expression, position_start, self.token.position_start.copy()))

    elif self.token.matches_keyword(CONTINUE):
      response.advance(self)

      return response.success(ContinueNode(position_start, self.token.position_start.copy()))

    elif self.token.matches_keyword(BREAK):
      response.advance(self)

      return response.success(BreakNode(position_start, self.token.position_start.copy()))

    expression = response.register(self.expression())
    if response.error:
      return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидались `вернуть` (`return`), `продолжить` (`continue`), `прервать` (`break`), `если` (`if`), `для` (`for`), `пока` (`while`), `функция` (`function`), `не` (`not`), Целое число, Дробное число, Идентификатор, Математический оператор (`+`, `-`, `*`, `/`) или открывающая скобка (`(`, `%(`)"
      ))

    return response.success(expression)


class ParseResponse:
  def __init__(self):
    self.error = None
    self.node = None
    self.last_registered_advance_count = 0
    self.advance_count = 0

  def advance(self, parser: Parser):
    self.register_advancement()
    parser.advance()

  def register_advancement(self):
    self.last_registered_advance_count = 1
    self.advance_count += 1

  def register(self, response):
    self.last_registered_advance_count = response.advance_count
    self.advance_count += response.advance_count
    if response.error:
      self.error = response.error

    return response.node

  def try_register(self, response):
    if response.error:
      self.to_reverse_count = response.advance_count
      return None

    return self.register(response)

  def success(self, node: NumberNode):
    self.node = node
    return self

  def failure(self, error):
    if not self.error or not self.advance_count:
      self.error = error
    return self
