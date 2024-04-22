from loggers import InvalidSyntaxError, ParsingLogger
from nodes import *
from tokens import *


class Parser:
  def __init__(self, tokens: [Token]):
    self.tokens = tokens

    self.token_index = 0
    self.next()

  def next(self):
    if self.token_index < len(self.tokens):
      self.token: Token = self.tokens[self.token_index]

    self.token_index += 1

    return self.token

  def reverse(self, amount=1):
    self.token_index -= amount
    self.update_token()
    return self.token

  def update_token(self):
    if 0 <= self.token_index < len(self.tokens):
      self.token = self.tokens[self.token_index - 1]

  def parse(self):
    logger = ParsingLogger()
    result = ListNode([], self.token.position_start, self.token.position_start)

    while not self.token.check_type(END_OF_FILE):
      result.elements += [logger.register(self.statement())]
      if logger.error:
        return logger

      logger.next(self)

    return logger.success(result)

  def expression(self):
    logger = ParsingLogger()
    index = self.token_index

    if self.token.check_type(IDENTIFIER):
      variable = self.token
      keys = []

      logger.next(self)

      # Поиск ключей/индексов
      while self.token.check_type(POINT):
        logger.next(self)

        expression = logger.register(self.term())
        if logger.error:
          return logger

        keys += [expression]

      # Операции с присвоением
      # +=, -=, *=, /=, **=
      operator = None
      if self.token.check_type(ADDITION, SUBTRACTION, MULTIPLICATION, DIVISION, POWER):
        operator = self.token
        logger.next(self)

      # Присвоение
      if self.token.check_type(ASSIGN):
        logger.next(self)
        expression = logger.register(self.expression())
        if logger.error:
          return logger

        if operator:
          expression = BinaryOperationNode(
            VariableAccessNode(variable, keys, variable.position_start, variable.position_end),
            operator,
            expression
          )

        return logger.success(VariableAssignNode(variable, keys, expression))

    # Обработка множественного присвоения
    # %(a, b)% = %(1, 2)%
    elif self.token.check_type(OPEN_LIST_PAREN):
      list_expression = logger.register(self.list_expression())
      if logger.error:
        return logger

      if self.token.check_type(ASSIGN):
        logger.next(self)

        expression = logger.register(self.list_expression())
        if logger.error:
          return logger

        if len(list_expression.value) != len(expression.value):
          return logger.failure(InvalidSyntaxError(
            expression.position_start, expression.position_end,
            f"Недостаточно значений для распоковки: ожидалось {len(list_expression.value)}, получено {len(expression.value)}"
          ))

        variables = []
        for variable, element in zip(list_expression.value, expression.value):
          if not isinstance(variable, VariableAccessNode):
            return logger.failure(InvalidSyntaxError(
              variable.position_start, variable.position_end,
              "Ожидался идентификатор"
            ))

          variables += [VariableAssignNode(variable.variable, variable.keys, element)]

        return logger.success(ListNode(variables, list_expression.position_start, self.token.position_end.copy()))

    self.reverse(self.token_index - index)

    node = logger.register(self.binary_operation(AND + OR, self.comparison_expression))
    if logger.error:
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались Идентификатор, Целое число, Дробное число, `+`, `-` или `(`"
      ))

    return logger.success(node)

  def binary_operation(self, operators, left_function, right_function=None):
    if right_function == None:
      right_function = left_function

    logger = ParsingLogger()
    left = logger.register(left_function())
    if logger.error:
      return logger

    while self.token.check_type(*operators) or self.token.check_keyword(operators):
      left_operator = self.token
      logger.next(self)

      middle = logger.register(right_function())
      if logger.error:
        return logger

      left = BinaryOperationNode(left, left_operator, middle)

      if operators == COMPARISONS and self.token.check_type(*COMPARISONS):
        right_operator = self.token
        logger.next(self)

        right = logger.register(self.arithmetical_expression())
        if logger.error:
          return logger

        middle = BinaryOperationNode(middle, right_operator, right)

        left = BinaryOperationNode(
          left,
          Token(KEYWORD, "и", self.token.position_start, self.token.position_end),
          middle
        )

    return logger.success(left)

  def atom(self):
    logger = ParsingLogger()
    token = self.token

    if token.check_type(INTEGER, FLOAT):
      logger.next(self)
      return logger.success(NumberNode(token))
    elif token.check_type(STRING):
      logger.next(self)
      return logger.success(StringNode(token))

    elif token.check_type(IDENTIFIER):
      if self.tokens[self.token_index - 2].check_type(POINT):
        logger.next(self)
        return logger.success(VariableAccessNode(
          token, [], token.position_start, self.token.position_end
        ))

      logger.next(self)
      keys = []
      while self.token.check_type(POINT):
        logger.next(self)

        if self.token.check_type(IDENTIFIER, STRING, INTEGER):
          expression = self.atom()
        elif self.token.check_type(OPEN_PAREN):
          expression = self.arithmetical_expression()
        elif self.token.check_type(SUBTRACTION):
          expression = self.factor()
        else:
          return logger.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидались идентификатор, целое число, строка или открывающая скобка",
          ))

        keys += [logger.register(expression)]
        if logger.error:
          return logger

      return logger.success(VariableAccessNode(
        token, keys, token.position_start, self.token.position_end
      ))

    elif token.check_type(OPEN_PAREN):
      logger.next(self)

      expression = logger.register(self.expression())
      if logger.error:
        return logger

      if not self.token.check_type(CLOSED_PAREN):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `)`)"
        ))

      logger.next(self)
      return logger.success(expression)

    expression = None
    if token.check_type(OPEN_LIST_PAREN): expression = self.list_expression()
    elif token.check_keyword(CHECK):      expression = self.check_expression()
    elif token.check_keyword(IF):         expression = self.if_expression()
    elif token.check_keyword(FOR):        expression = self.for_expression()
    elif token.check_keyword(WHILE):      expression = self.while_expression()
    elif token.check_keyword(FUNCTION):   expression = self.function_expression()
    elif token.check_keyword(CLASS):      expression = self.class_expression()
    elif token.check_keyword(DELETE):     expression = self.delete_expression()
    elif token.check_keyword(INCLUDE):    expression = self.include_statement()

    if expression == None:
      return logger.failure(InvalidSyntaxError(
        token.position_start, token.position_end,
        "Ожидались Идентификатор, Целое число, Дробное число, `+`, `-` или `(`)"
      ))

    expression = logger.register(expression)
    if logger.error:
      return logger

    return logger.success(expression)

  def call_expression(self):
    logger = ParsingLogger()
    atom = logger.register(self.atom())
    if logger.error:
      return logger

    if not self.token.check_type(OPEN_PAREN):
      return logger.success(atom)

    logger.next(self)
    argument_nodes = []

    if self.token.check_type(NEWLINE):
      logger.next(self)

    if self.token.check_type(CLOSED_PAREN):
      logger.next(self)
      return logger.success(CallNode(atom, argument_nodes))

    argument_nodes += [logger.register(self.expression())]
    if logger.error:
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались `если` (`if`), `для` (`for`), `пока` (`while`), `функция` (`function`), Целое число, Дробное число, Идентификатор, `)`"
      ))

    while self.token.check_type(SEMICOLON):
      logger.next(self)

      if self.token.check_type(NEWLINE):
        logger.next(self)

      argument_nodes += [logger.register(self.expression())]
      if logger.error:
        return logger

    if self.token.check_type(NEWLINE):
      logger.next(self)

    if not self.token.check_type(CLOSED_PAREN):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `,` или `)`"
      ))

    logger.next(self)

    return logger.success(CallNode(atom, argument_nodes))

  def power_root(self):
    return self.binary_operation([POWER, ROOT], self.call_expression, self.factor)

  def factor(self):
    logger = ParsingLogger()
    token = self.token

    if not token.check_type(SUBTRACTION, ROOT, INCREMENT, DECREMENT):
      return self.power_root()

    logger.next(self)
    factor = logger.register(self.factor())
    if logger.error:
      return logger

    return logger.success(UnaryOperationNode(token, factor))

  def term(self):
    return self.binary_operation([MULTIPLICATION, DIVISION], self.factor)

  def comparison_expression(self):
    logger = ParsingLogger()

    if self.token.check_keyword(NOT):
      token = self.token
      logger.next(self)

      node = logger.register(self.comparison_expression())
      if logger.error:
        return logger

      return logger.success(UnaryOperationNode(token, node))

    node = logger.register(self.binary_operation(COMPARISONS, self.arithmetical_expression))
    if logger.error:
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались Целое число, Дробное число, Идентификатор, `+`, `-`, `(` или `не` (`not`)"
      ))

    return logger.success(node)

  def arithmetical_expression(self):
    return self.binary_operation([ADDITION, SUBTRACTION], self.term)

  def list_expression(self):
    logger = ParsingLogger()
    value = {}
    is_dictionary = False
    position_start = self.token.position_start.copy()

    if not self.token.check_type(OPEN_LIST_PAREN):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `%(`"
      ))

    logger.next(self)

    if self.token.check_type(NEWLINE):
      logger.next(self)

    if self.token.check_type(CLOSED_LIST_PAREN):
      logger.next(self)
      if is_dictionary:
        return logger.success(DictionaryNode(
          value.items(),
          position_start,
          self.token.position_end.copy()
        ))

      return logger.success(ListNode(
        list(value),
        position_start,
        self.token.position_end.copy()
      ))

    key_node = logger.register(self.expression())
    if logger.error:
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались `если` (`if`), `для` (`for`), `пока` (`while`), `функция` (`function`), Целое число, Дробное число, Идентификатор, `)`"
      ))

    value_node = None
    if self.token.check_type(COLON):
      is_dictionary = True
      logger.next(self)

      value_node = logger.register(self.expression())
      if logger.error:
        return logger

    value |= {key_node: value_node}

    while self.token.check_type(SEMICOLON):
      logger.next(self)

      if self.token.check_type(NEWLINE):
        logger.next(self)

      if self.token.check_type(CLOSED_LIST_PAREN):
        break

      key_node = logger.register(self.expression())
      if logger.error:
        return logger

      value_node = None

      if self.token.check_type(COLON) and not is_dictionary:
        return logger.failure(InvalidSyntaxError(self.token.position_start, self.token.position_end, "Ожидалась запятая (`,`)"))

      if is_dictionary:
        if not self.token.check_type(COLON):
          return logger.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидалось двоеточие (`:`)"
          ))

        logger.next(self)

        value_node = logger.register(self.expression())
        if logger.error:
          return logger

      value |= {key_node: value_node}

    if self.token.check_type(NEWLINE):
      logger.next(self)

    if not self.token.check_type(CLOSED_LIST_PAREN):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end.next(),
        "Ожидались `,` или `)%`"
      ))

    logger.next(self)

    if is_dictionary:
      return logger.success(DictionaryNode(
        value.items(),
        position_start,
        self.token.position_end.copy()
      ))

    return logger.success(ListNode(
      list(value),
      position_start,
      self.token.position_end.copy()
    ))

  def check_expression(self):
    logger = ParsingLogger()
    cases = []
    else_case = None

    if not self.token.check_keyword(CHECK):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        f"Ожидалось `{CHECK}`"
      ))

    logger.next(self)

    left = logger.register(self.arithmetical_expression())
    if logger.error:
      return logger

    operator = Token(EQUAL, None, self.token.position_start, self.token.position_end)

    if not self.token.check_type(*COMPARISONS, NEWLINE):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалась операция сравнения или перенос строки"
      ))

    if self.token.check_type(*COMPARISONS):
      operator = self.token
      logger.next(self)

      if not self.token.check_type(NEWLINE):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался перенос строки"
        ))

    logger.next(self)

    if not self.token.check_keyword(ON):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `при` (`on`)"
      ))

    while self.token.check_keyword(ON):
      logger.next(self)

      case_operator = operator
      if self.token.check_type(*COMPARISONS):
        case_operator = self.token
        logger.next(self)

      right = logger.register(self.arithmetical_expression())
      if logger.error:
        return logger

      condition = BinaryOperationNode(left, case_operator, right)

      while self.token.check_keyword(AND, OR):
        connector = self.token
        logger.next(self)

        case_operator = operator
        if self.token.check_type(*COMPARISONS):
          case_operator = self.token
          logger.next(self)

        right = logger.register(self.arithmetical_expression())
        if logger.error:
          return logger

        condition = BinaryOperationNode(condition, connector, BinaryOperationNode(left, case_operator, right))

      if not self.token.check_type(NEWLINE):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался перенос строки"
        ))

      logger.next(self)

      body = []
      while not self.token.check_keyword(ON, ELSE):
        body += [logger.register(self.statement())]
        if logger.error:
          return logger

        if isinstance(body[-1], ContinueNode):
          return logger.failure(InvalidSyntaxError(
            body[-1].position_start, body[-1].position_end,
            "`продолжить` может использоваться только в цикле"
          ))

        logger.next(self)

      cases += [[condition, ListNode(body, None, None), False]]

    if not self.token.check_type(END_OF_CONSTRUCTION):
      else_case = logger.register(self.else_expression())
      if logger.error:
        return logger

      return logger.success(CheckNode(cases, else_case))

    else_case = None
    logger.next(self)

    return logger.success(CheckNode(cases, else_case))

  def if_expression(self):
    logger = ParsingLogger()
    cases = []
    else_case = None

    if not self.token.check_keyword(IF):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        f"Ожидалось `{IF}`"
      ))

    while self.token.check_keyword(IF):
      logger.next(self)

      condition = logger.register(self.expression())
      if logger.error:
        return logger

      if not self.token.check_keyword(THEN):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `то` (`then`)"
        ))

      logger.next(self)

      if not self.token.check_type(NEWLINE):
        expression = logger.register(self.statement())
        if logger.error:
          return logger

        cases += [[condition, expression, False]]

        continue

      logger.next(self)

      statements = logger.register(self.statements())
      if logger.error:
        return logger

      cases += [[condition, statements, True]]

      if self.token.check_type(END_OF_CONSTRUCTION):
        logger.next(self)

        return logger.success(IfNode(cases, else_case))

      if self.token.check_keyword(ELSE):
        logger.next(self)
        if not self.token.check_keyword(IF):
          self.reverse()
      elif not self.token.check_type(END_OF_CONSTRUCTION):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался конец конструкции"
        ))

    else_case = logger.register(self.else_expression())
    if logger.error:
      return logger

    return logger.success(IfNode(cases, else_case))

  def else_expression(self):
    logger = ParsingLogger()
    else_case = None

    if not self.token.check_keyword(ELSE):
      return logger.success(else_case)

    logger.next(self)

    if not self.token.check_type(NEWLINE):
      expression = logger.register(self.statement())
      if logger.error:
        return logger

      return logger.success([expression, False])

    logger.next(self)

    statements = logger.register(self.statements())
    if logger.error:
      return logger

    if not self.token.check_type(END_OF_CONSTRUCTION):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидался конец конструкции (`---`, `===` или `%%%`)"
      ))

    logger.next(self)
    return logger.success([statements, True])

  def for_expression(self):
    logger = ParsingLogger()
    else_case = None

    if not self.token.check_keyword(FOR):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидался `for`"
      ))

    logger.next(self)

    if not self.token.check_type(IDENTIFIER):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидался Идентификатор"
      ))

    variable_name = self.token
    logger.next(self)

    if self.token.check_keyword(FROM):
      logger.next(self)

      start_value = logger.register(self.expression())
      if logger.error:
        return logger

      if not self.token.check_keyword(TO):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `to`"
        ))

      logger.next(self)

      end_value = logger.register(self.expression())
      if logger.error:
        return logger

      if self.token.check_keyword(AFTER):
        logger.next(self)

        step_value = logger.register(self.expression())
        if logger.error:
          return logger
      else:
        step_value = None

    elif self.token.check_keyword(OF):
      logger.next(self)

      start_value = logger.register(self.expression())
      if logger.error:
        return logger
      end_value = step_value = None

    else:
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `from` или `of`"
      ))

    if self.token.check_type(NEWLINE):
      logger.next(self)
      body = logger.register(self.statements())
      if logger.error:
        return logger

      if self.token.check_type(END_OF_CONSTRUCTION):
        logger.next(self)
      else:
        else_case = logger.register(self.else_expression())
        if logger.error:
          return logger

      return logger.success(ForNode(
        variable_name, start_value, end_value,
        step_value, body, True, else_case
      ))

    if not self.token.check_type(COLON):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось двоеточие (`:`)"
      ))

    logger.next(self)

    body = logger.register(self.statement())
    if logger.error:
      return logger

    return logger.success(ForNode(
      variable_name, start_value,
      end_value, step_value,
      body, False, None
    ))

  def while_expression(self):
    logger = ParsingLogger()
    else_case = None

    if not self.token.check_keyword(WHILE):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `while`"
      ))

    logger.next(self)

    condition = logger.register(self.expression())
    if logger.error:
      return logger

    if self.token.check_type(NEWLINE):
      logger.next(self)

      body = logger.register(self.statements())
      if logger.error:
        return logger

      if self.token.check_type(END_OF_CONSTRUCTION):
        logger.next(self)
      else:
        else_case = logger.register(self.else_expression())
        if logger.error:
          return logger

      return logger.success(WhileNode(condition, body, True, else_case))

    if not self.token.check_type(COLON):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось двоеточие (`:`)"
      ))

    logger.next(self)

    body = logger.register(self.statement())
    if logger.error:
      return logger

    return logger.success(WhileNode(condition, body, False, None))

  def function_expression(self, is_method=False):
    logger = ParsingLogger()
    if not self.token.check_keyword(FUNCTION):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `функция` (`function`)"
      ))

    logger.next(self)

    variable_name = None
    if self.token.check_type(IDENTIFIER):
      variable_name = self.token
      logger.next(self)

    if not self.token.check_type(OPEN_PAREN):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        f"Ожидалось `(`{' или Идентификатор' if variable_name else ''}"
      ))

    logger.next(self)
    arguments = []

    while self.token.check_type(IDENTIFIER):
      argument = logger.register(self.expression())
      if logger.error:
        return logger

      if arguments and isinstance(arguments[-1], VariableAssignNode) and isinstance(argument, VariableAccessNode):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался именованный аргумент"
        ))

      arguments += [argument]

      if self.token.check_type(SEMICOLON):
        logger.next(self)

    if not self.token.check_type(CLOSED_PAREN):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались Идентификатор или `)`"
      ))

    logger.next(self)

    if self.token.check_type(NEWLINE):
      logger.next(self)

      body: ListNode = logger.register(self.statements())
      if logger.error:
        return logger

      if not self.token.check_type(END_OF_CONSTRUCTION):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался конец конструкции (`---`, `===` или `%%%`)"
        ))

      logger.next(self)

      if is_method:
        return logger.success(MethodDefinitionNode(variable_name, arguments, body, False))

      return logger.success(FunctionDefinitionNode(variable_name, arguments, body, False))

    if not self.token.check_type(COLON):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось двоеточие (`:`)"
      ))

    logger.next(self)

    return_node = logger.register(self.expression())
    if logger.error:
      return logger

    if is_method:
      return logger.success(MethodDefinitionNode(variable_name, arguments, return_node, True))

    return logger.success(FunctionDefinitionNode(variable_name, arguments, return_node, True))

  def class_expression(self):
    logger = ParsingLogger()

    if not self.token.check_keyword(CLASS):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `класс` (`class`)"
      ))

    logger.next(self)

    if not self.token.check_type(IDENTIFIER):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось Идентификатор"
      ))

    variable_name = self.token
    logger.next(self)

    if not self.token.check_type(NEWLINE, OPEN_PAREN):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалися перенос строки или открывающая скобка"
      ))

    parents = []
    if self.token.check_type(OPEN_PAREN):
      logger.next(self)

      if not self.token.check_type(IDENTIFIER, CLOSED_PAREN):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидались идентификатор или закрывающая скобка"
        ))

      while self.token.check_type(IDENTIFIER):
        parents += [self.token.value]

        logger.next(self)

        if self.token.check_type(NEWLINE):
          logger.next(self)

        if not self.token.check_type(SEMICOLON, CLOSED_PAREN):
          return logger.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидались запятая или закрывающая скобка"
          ))

        if self.token.check_type(SEMICOLON):
          logger.next(self)

      if not self.token.check_type(IDENTIFIER, CLOSED_PAREN):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидались идентификатор или закрывающая скобка"
        ))

      logger.next(self)

      if not self.token.check_type(NEWLINE):
        return logger.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался перенос строки"
        ))

    logger.next(self)

    if not self.token.check_keyword(FUNCTION) and not self.token.check_type(END_OF_CONSTRUCTION):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `функция` (`function`) или завершение конструкции"
      ))

    methods = []
    body_position_start = self.token.position_end.copy()

    while self.token.check_keyword(FUNCTION):
      method = logger.register(self.function_expression(True))
      if logger.error:
        return logger

      if len(method.argument_names) < 1:
        return logger.failure(InvalidSyntaxError(
          method.variable_name.position_start, method.variable_name.position_end,
          "Метод должен иметь хотя бы один аргумент, в который будет помещён сам объект"
        ))

      method_name = StringNode(method.variable_name.copy())
      methods += [[method_name, method]]
      logger.next(self)

    if not self.token.check_type(END_OF_CONSTRUCTION):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось завершение конструкции"
      ))

    if all(key.token.value not in ["__инициализация__", "__init__"] for key, _ in methods):
      initial_method_name = Token(STRING, "__инициализация__", self.token.position_start, self.token.position_end)

      initial_method = MethodDefinitionNode(
        initial_method_name,
        [VariableAccessNode(
          Token(IDENTIFIER, "объект", self.token.position_start, self.token.position_end),
          [], self.token.position_start, self.token.position_end
        )],
        ListNode([], self.token.position_start, self.token.position_end),
        True,
        True
      )

      methods += [[StringNode(initial_method_name), initial_method]]

    logger.next(self)
    body_node = DictionaryNode(methods, body_position_start, self.token.position_end.copy())

    return logger.success(ClassDefinitionNode(variable_name, body_node, parents))

  def delete_expression(self):
    logger = ParsingLogger()

    if not self.token.check_keyword(DELETE):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `удалить` (`delete`)"
      ))

    position_start = self.token.position_start
    logger.next(self)

    if not self.token.check_type(IDENTIFIER):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидался Идентификатор"
      ))

    variable = self.token
    logger.next(self)

    return logger.success(DeleteNode(variable, position_start, self.token.position_end.copy()))

  def include_statement(self):
    logger = ParsingLogger()

    if not self.token.check_keyword(INCLUDE):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `включить` (`include`)"
      ))

    position_start = self.token.position_start.copy()
    logger.next(self)

    if not self.token.check_type(STRING):
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось название модуля"
      ))

    module = self.token
    logger.next(self)

    return logger.success(IncludeNode(module, position_start, self.token.position_end.copy()))

  def statements(self):
    logger = ParsingLogger()
    statements = []
    position_start = self.token.position_start.copy()

    if self.token.check_type(NEWLINE):
      logger.next(self)

    statements = [logger.register(self.statement())]
    if logger.error:
      return logger

    more_statements = True

    while True:
      newline_count = 0
      if self.token.check_type(NEWLINE):
        logger.next(self)
        newline_count += 1

      if newline_count == 0:
        more_statements = False

      if not more_statements:
        break

      statement = logger.try_register(self.statement())

      if not statement:
        self.reverse(logger.to_reverse_count)
        more_statements = False
        continue

      statements += [statement]

    return logger.success(ListNode(
      statements, position_start,
      self.token.position_end.copy()
    ))

  def statement(self):
    logger = ParsingLogger()
    position_start = self.token.position_start.copy()

    if self.token.check_keyword(RETURN):
      logger.next(self)
      expression = logger.try_register(self.expression())
      if not expression:
        self.reverse(logger.to_reverse_count)

      return logger.success(ReturnNode(expression, position_start, self.token.position_start.copy()))

    elif self.token.check_keyword(CONTINUE):
      logger.next(self)

      return logger.success(ContinueNode(position_start, self.token.position_start.copy()))

    elif self.token.check_keyword(BREAK):
      logger.next(self)

      return logger.success(BreakNode(position_start, self.token.position_start.copy()))

    expression = logger.register(self.expression())
    if logger.error:
      return logger.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались `вернуть` (`return`), `продолжить` (`continue`), `прервать` (`break`), `если` (`if`), `для` (`for`), `пока` (`while`), `функция` (`function`), `не` (`not`), Целое число, Дробное число, Идентификатор, Математический оператор (`+`, `-`, `*`, `/`) или открывающая скобка (`(`, `%(`)"
      ))

    return logger.success(expression)
