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
    if 0 <= self.token_index < len(self.tokens):
      self.token = self.tokens[self.token_index - 1]

  def parse(self):
    response = ParseResponse()
    result = ListNode([], self.token.position_start, self.token.position_start) 

    while not self.token.check_type(END_OF_FILE):
      result.element_nodes += [response.register(self.statement())]
      if response.error:
        return response

      response.advance(self)

    return response.success(result)

  def expression(self):
    response = ParseResponse()
    index = self.token_index

    if self.token.check_type(IDENTIFIER):
      variable = self.token
      keys = []
      
      response.advance(self)

      # Поиск ключей/индексов
      while self.token.check_type(POINT):
        response.advance(self)
        
        expression = response.register(self.term())
        if response.error:
          return response

        keys += [expression]

      # Операции с присвоением
      # +=, -=, *=, /=, **=
      operator = None
      if self.token.check_type(ADDITION, SUBTRACTION, MULTIPLICATION, DIVISION, POWER):
        operator = self.token
        response.advance(self)

      # Присвоение
      if self.token.check_type(ASSIGN):
        response.advance(self)
        expression = response.register(self.expression())
        if response.error:
          return response

        if operator:
          expression = BinaryOperationNode(
            VariableAccessNode(variable, keys, variable.position_start, variable.position_end),
            operator,
            expression
          )

        return response.success(VariableAssignNode(variable, keys, expression))

    # Обработка множественного присвоения
    # %(a, b)% = %(1, 2)%
    elif self.token.check_type(OPEN_LIST_PAREN):
      list_expression = response.register(self.list_expression())
      if response.error:
        return response

      if self.token.check_type(ASSIGN):
        response.advance(self)
        
        expression = response.register(self.list_expression())
        if response.error:
          return response

        if len(list_expression.element_nodes) != len(expression.element_nodes):
          return response.failure(InvalidSyntaxError(
            expression.position_start, expression.position_end,
            f"Недостаточно значений для распоковки: ожидалось {len(list_expression.element_nodes)}, получено {len(expression.element_nodes)}"
          ))

        variables = []
        for variable, element in zip(list_expression.element_nodes, expression.element_nodes):
          if not isinstance(variable, VariableAccessNode):
            return response.failure(InvalidSyntaxError(
              variable.position_start, variable.position_end,
              "Ожидался идентификатор"
            ))
            
          variables += [VariableAssignNode(variable.variable, variable.keys, element)]

        return response.success(ListNode(variables, list_expression.position_start, self.token.position_end.copy()))

    self.reverse(self.token_index - index)

    node = response.register(self.binary_operation(AND + OR, self.comparison_expression))
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
    left = response.register(left_function())
    if response.error:
      return response

    while self.token.check_type(*operators) or self.token.check_keyword(operators):
      left_operator = self.token
      response.advance(self)

      middle = response.register(right_function())
      if response.error:
        return response

      left = BinaryOperationNode(left, left_operator, middle)

      if operators == COMPARISONS and self.token.check_type(*COMPARISONS):
        right_operator = self.token
        response.advance(self)

        right = response.register(self.arithmetical_expression())
        if response.error:
          return response

        middle = BinaryOperationNode(middle, right_operator, right)

        left = BinaryOperationNode(
          left,
          Token(KEYWORD, "и", self.token.position_start, self.token.position_end),
          middle
        )

    return response.success(left)

  def atom(self):
    response = ParseResponse()
    token = self.token

    if token.check_type(INTEGER, FLOAT):
      response.advance(self)
      return response.success(NumberNode(token))
    elif token.check_type(STRING):
      response.advance(self)
      return response.success(StringNode(token))

    elif token.check_type(IDENTIFIER):
      if self.tokens[self.token_index - 2].check_type(POINT):
        response.advance(self)
        return response.success(VariableAccessNode(
          token, [], token.position_start, self.token.position_end
        ))

      response.advance(self)
      keys = []
      while self.token.check_type(POINT):
        response.advance(self)
        
        if self.token.check_type(IDENTIFIER, STRING, INTEGER):
          expression = self.atom()
        elif self.token.check_type(OPEN_PAREN):
          expression = self.arithmetical_expression()
        elif self.token.check_type(SUBTRACTION):
          expression = self.factor()
        else:
          return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидались идентификатор, целое число, строка или открывающая скобка",
          ))

        keys += [response.register(expression)]
        if response.error:
          return response

      return response.success(VariableAccessNode(
        token, keys, token.position_start, self.token.position_end
      ))

    elif token.check_type(OPEN_PAREN):
      response.advance(self)

      expression = response.register(self.expression())
      if response.error:
        return response

      if not self.token.check_type(CLOSED_PAREN):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `)`)"
        ))

      response.advance(self)
      return response.success(expression)

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
      return response.failure(InvalidSyntaxError(
        token.position_start, token.position_end,
        "Ожидались Идентификатор, Целое число, Дробное число, `+`, `-` или `(`)"
      ))

    expression = response.register(expression)
    if response.error:
      return response

    return response.success(expression)

  def call_expression(self):
    response = ParseResponse()
    atom = response.register(self.atom())
    if response.error:
      return response

    if not self.token.check_type(OPEN_PAREN):
      return response.success(atom)

    response.advance(self)
    argument_nodes = []

    if self.token.check_type(NEWLINE):
      response.advance(self)

    if self.token.check_type(CLOSED_PAREN):
      response.advance(self)
      return response.success(CallNode(atom, argument_nodes))

    argument_nodes += [response.register(self.expression())]
    if response.error:
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались `если` (`if`), `для` (`for`), `пока` (`while`), `функция` (`function`), Целое число, Дробное число, Идентификатор, `)`"
      ))

    while self.token.check_type(COMMA):
      response.advance(self)

      if self.token.check_type(NEWLINE):
        response.advance(self)

      argument_nodes += [response.register(self.expression())]
      if response.error:
        return response

    if self.token.check_type(NEWLINE):
      response.advance(self)

    if not self.token.check_type(CLOSED_PAREN):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `,` или `)`"
      ))

    response.advance(self)

    return response.success(CallNode(atom, argument_nodes))

  def power_root(self):
    return self.binary_operation([POWER, ROOT], self.call_expression, self.factor)

  def factor(self):
    response = ParseResponse()
    token = self.token

    if not token.check_type(SUBTRACTION, ROOT, INCREMENT, DECREMENT):
      return self.power_root()

    response.advance(self)
    factor = response.register(self.factor())
    if response.error:
      return response

    return response.success(UnaryOperationNode(token, factor))


  def term(self):
    return self.binary_operation([MULTIPLICATION, DIVISION], self.factor)

  def comparison_expression(self):
    response = ParseResponse()

    if self.token.check_keyword(NOT):
      token = self.token
      response.advance(self)

      node = response.register(self.comparison_expression())
      if response.error:
        return response

      return response.success(UnaryOperationNode(token, node))

    node = response.register(self.binary_operation(COMPARISONS, self.arithmetical_expression))
    if response.error:
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались Целое число, Дробное число, Идентификатор, `+`, `-`, `(` или `не` (`not`)"
      ))

    return response.success(node)

  def arithmetical_expression(self):
    return self.binary_operation([ADDITION, SUBTRACTION], self.term)

  def list_expression(self):
    response = ParseResponse()
    element_nodes = {}
    is_dictionary = False
    position_start = self.token.position_start.copy()

    if not self.token.check_type(OPEN_LIST_PAREN):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `%(`"
      ))

    response.advance(self)

    if self.token.check_type(NEWLINE):
      response.advance(self)

    if self.token.check_type(CLOSED_LIST_PAREN):
      response.advance(self)
      if is_dictionary:
        return response.success(DictionaryNode(
          element_nodes.items(),
          position_start,
          self.token.position_end.copy()
        ))

      return response.success(ListNode(
        list(element_nodes),
        position_start,
        self.token.position_end.copy()
      ))

    key_node = response.register(self.expression())
    if response.error:
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались `если` (`if`), `для` (`for`), `пока` (`while`), `функция` (`function`), Целое число, Дробное число, Идентификатор, `)`"
      ))

    value_node = None
    if self.token.check_type(COLON):
      is_dictionary = True
      response.advance(self)

      value_node = response.register(self.expression())
      if response.error:
        return response

    element_nodes |= {key_node: value_node}

    while self.token.check_type(COMMA):
      response.advance(self)

      if self.token.check_type(NEWLINE):
        response.advance(self)

      if self.token.check_type(CLOSED_LIST_PAREN):
        break

      key_node = response.register(self.expression())
      if response.error:
        return response

      value_node = None

      if self.token.check_type(COLON) and not is_dictionary:
        return response.failure(InvalidSyntaxError(self.token.position_start, self.token.position_end, "Ожидалась запятая (`,`)"))

      if is_dictionary:
        if not self.token.check_type(COLON):
          return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидалось двоеточие (`:`)"
          ))

        response.advance(self)

        value_node = response.register(self.expression())
        if response.error:
          return response

      element_nodes |= {key_node: value_node}

    if self.token.check_type(NEWLINE):
      response.advance(self)

    if not self.token.check_type(CLOSED_LIST_PAREN):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end.advance(),
        "Ожидались `,` или `)%`"
      ))

    response.advance(self)

    if is_dictionary:
      return response.success(DictionaryNode(
        element_nodes.items(),
        position_start,
        self.token.position_end.copy()
      ))

    return response.success(ListNode(
      list(element_nodes),
      position_start,
      self.token.position_end.copy()
    ))

  def check_expression(self):
    response = ParseResponse()
    cases = []
    else_case = None

    if not self.token.check_keyword(CHECK):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        f"Ожидалось `{CHECK}`"
      ))

    response.advance(self)

    left = response.register(self.arithmetical_expression())
    if response.error:
      return response

    operator = Token(EQUAL, None, self.token.position_start, self.token.position_end)

    if not self.token.check_type(*COMPARISONS, NEWLINE):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалась операция сравнения или перенос строки"
      ))

    if self.token.check_type(*COMPARISONS):
      operator = self.token
      response.advance(self)

      if not self.token.check_type(NEWLINE):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался перенос строки"
        ))

    response.advance(self)

    if not self.token.check_keyword(IF):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `если` (`if`)"
      ))

    while self.token.check_keyword(IF):
      response.advance(self)

      case_operator = operator
      if self.token.check_type(*COMPARISONS):
        case_operator = self.token
        response.advance(self)

      right = response.register(self.arithmetical_expression())
      if response.error:
        return response

      condition = BinaryOperationNode(left, case_operator, right)

      while self.token.check_keyword(AND, OR):
        connector = self.token
        response.advance(self)

        case_operator = operator
        if self.token.check_type(*COMPARISONS):
          case_operator = self.token
          response.advance(self)

        right = response.register(self.arithmetical_expression())
        if response.error:
          return response

        condition = BinaryOperationNode(condition, connector, BinaryOperationNode(left, case_operator, right))

      if not self.token.check_keyword(THEN):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался `то` (`then`)"
        ))

      response.advance(self)

      if not self.token.check_type(NEWLINE):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался перено строки"
        ))

      response.advance(self)

      body = []
      while not self.token.check_keyword(IF, ELSE):
        body += [response.register(self.statement())]
        if response.error:
          return response

        if isinstance(body[-1], ContinueNode):
          return response.failure(InvalidSyntaxError(
            body[-1].position_start, body[-1].position_end,
            "`продолжить` может использоваться только в цикле"
          ))

        response.advance(self)

      cases += [[condition, ListNode(body, None, None), False]]

    if not self.token.check_type(END_OF_CONSTRUCTION):
      else_case = response.register(self.else_expression())
      if response.error:
        return response

      return response.success(CheckNode(cases, else_case))

    else_case = None
    response.advance(self)

    return response.success(CheckNode(cases, else_case))

  def if_expression(self):
    response = ParseResponse()
    cases = []
    else_case = None

    if not self.token.check_keyword(IF):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        f"Ожидалось `{IF}`"
      ))

    response.advance(self)

    condition = response.register(self.expression())
    if response.error:
      return response

    if not self.token.check_keyword(THEN):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `то` (`then`)"
      ))

    response.advance(self)

    if self.token.check_type(NEWLINE):
      response.advance(self)

      statements = response.register(self.statements())
      if response.error:
        return response

      cases += [[condition, statements, True]]

      if self.token.check_type(END_OF_CONSTRUCTION):
        response.advance(self)

        return response.success(IfNode(cases, else_case))

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

    if not self.token.check_keyword(ELSE):
      return response.success(else_case)

    response.advance(self)

    if not self.token.check_type(NEWLINE):
      expression = response.register(self.statement())
      if response.error:
        return response

      return response.success([expression, False])

    response.advance(self)

    statements = response.register(self.statements())
    if response.error:
      return response

    if not self.token.check_type(END_OF_CONSTRUCTION):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидался конец конструкции (`---`, `===` или `%%%`)"
      ))

    response.advance(self)
    return response.success([statements, True])

  def for_expression(self):
    response = ParseResponse()
    else_case = None

    if not self.token.check_keyword(FOR):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидался `for`"
      ))

    response.advance(self)

    if not self.token.check_type(IDENTIFIER):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидался Идентификатор"
      ))

    variable_name = self.token
    response.advance(self)

    if self.token.check_keyword(FROM):
      response.advance(self)

      start_value = response.register(self.expression())
      if response.error:
        return response

      if not self.token.check_keyword(TO):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидалось `to`"
        ))

      response.advance(self)

      end_value = response.register(self.expression())
      if response.error:
        return response

      if self.token.check_keyword(AFTER):
        response.advance(self)

        step_value = response.register(self.expression())
        if response.error:
          return response
      else:
        step_value = None

    elif self.token.check_keyword(OF):
      response.advance(self)

      start_value = response.register(self.expression())
      if response.error:
        return response
      end_value = step_value = None

    else:
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `from` или `of`"
      ))

    if self.token.check_type(NEWLINE):
      response.advance(self)
      body = response.register(self.statements())
      if response.error:
        return response

      if self.token.check_type(END_OF_CONSTRUCTION):
        response.advance(self)
      else:
        else_case = response.register(self.else_expression())
        if response.error:
          return response

      return response.success(ForNode(
        variable_name, start_value, end_value,
        step_value, body, True, else_case
      ))

    if not self.token.check_type(COLON):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось двоеточие (`:`)"
      ))

    response.advance(self)

    body = response.register(self.statement())
    if response.error:
      return response

    return response.success(ForNode(
      variable_name, start_value,
      end_value, step_value,
      body, False, None
    ))

  def while_expression(self):
    response = ParseResponse()
    else_case = None

    if not self.token.check_keyword(WHILE):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `while`"
      ))

    response.advance(self)

    condition = response.register(self.expression())
    if response.error:
      return response

    if self.token.check_type(NEWLINE):
      response.advance(self)

      body = response.register(self.statements())
      if response.error:
        return response

      if self.token.check_type(END_OF_CONSTRUCTION):
        response.advance(self)
      else:
        else_case = response.register(self.else_expression())
        if response.error:
          return response

      return response.success(WhileNode(condition, body, True, else_case))

    if not self.token.check_type(COLON):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось двоеточие (`:`)"
      ))

    response.advance(self)

    body = response.register(self.statement())
    if response.error:
      return response

    return response.success(WhileNode(condition, body, False, None))

  def function_expression(self, is_method=False):
    response = ParseResponse()
    if not self.token.check_keyword(FUNCTION):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `функция` (`function`)"
      ))

    response.advance(self)

    variable_name = None
    if self.token.check_type(IDENTIFIER):
      variable_name = self.token
      response.advance(self)

    if not self.token.check_type(OPEN_PAREN):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        f"Ожидалось `(`{' или Идентификатор' if variable_name else ''}"
      ))

    response.advance(self)
    arguments = []

    while self.token.check_type(IDENTIFIER):
      argument = response.register(self.expression())
      if response.error:
        return response

      if arguments and isinstance(arguments[-1], VariableAssignNode) and isinstance(argument, VariableAccessNode):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался именованный аргумент"
        ))

      arguments += [argument]

      if self.token.check_type(COMMA):
        response.advance(self)

    if not self.token.check_type(CLOSED_PAREN):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидались Идентификатор или `)`"
      ))

    response.advance(self)

    if self.token.check_type(NEWLINE):
      response.advance(self)

      body: ListNode = response.register(self.statements())
      if response.error:
        return response

      if not self.token.check_type(END_OF_CONSTRUCTION):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался конец конструкции (`---`, `===` или `%%%`)"
        ))

      response.advance(self)

      if is_method:
        return response.success(MethodDefinitionNode(variable_name, arguments, body, False))

      return response.success(FunctionDefinitionNode(variable_name, arguments, body, False))

    if not self.token.check_type(COLON):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось двоеточие (`:`)"
      ))

    response.advance(self)

    return_node = response.register(self.expression())
    if response.error:
      return response

    if is_method:
      return response.success(MethodDefinitionNode(variable_name, arguments, return_node, True))

    return response.success(FunctionDefinitionNode(variable_name, arguments, return_node, True))

  def class_expression(self):
    response = ParseResponse()

    if not self.token.check_keyword(CLASS):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `класс` (`class`)"
      ))

    response.advance(self)

    if not self.token.check_type(IDENTIFIER):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось Идентификатор"
      ))

    variable_name = self.token
    response.advance(self)
    
    if not self.token.check_type(NEWLINE, OPEN_PAREN):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалися перенос строки или открывающая скобка"
      ))

    parents = []
    if self.token.check_type(OPEN_PAREN):
      response.advance(self)

      if not self.token.check_type(IDENTIFIER, CLOSED_PAREN):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидались идентификатор или закрывающая скобка"
        ))

      while self.token.check_type(IDENTIFIER):
        parents += [self.token.value]
        
        response.advance(self)
        
        if self.token.check_type(NEWLINE):
          response.advance(self)
        
        if not self.token.check_type(COMMA, CLOSED_PAREN):
          return response.failure(InvalidSyntaxError(
            self.token.position_start, self.token.position_end,
            "Ожидались запятая или закрывающая скобка"
          ))

        if self.token.check_type(COMMA):
          response.advance(self)

      if not self.token.check_type(IDENTIFIER, CLOSED_PAREN):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидались идентификатор или закрывающая скобка"
        ))

      response.advance(self)

      if not self.token.check_type(NEWLINE):
        return response.failure(InvalidSyntaxError(
          self.token.position_start, self.token.position_end,
          "Ожидался перенос строки"
        ))
      
    response.advance(self)

    if not self.token.check_keyword(FUNCTION) and not self.token.check_type(END_OF_CONSTRUCTION):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `функция` (`function`) или завершение конструкции"
      ))
    
    methods = []
    body_position_start = self.token.position_end.copy()
    
    while self.token.check_keyword(FUNCTION):
      method = response.register(self.function_expression(True))
      if response.error:
        return response

      if len(method.argument_names) < 1:
        return response.failure(InvalidSyntaxError(
          method.variable_name.position_start, method.variable_name.position_end,
          "Метод должен иметь хотя бы один аргумент, в который будет помещён сам объект"
        ))

      method_name = StringNode(method.variable_name.copy())
      methods += [[method_name, method]]
      response.advance(self)

    if not self.token.check_type(END_OF_CONSTRUCTION):
      return response.failure(InvalidSyntaxError(
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

    response.advance(self)
    body_node = DictionaryNode(methods, body_position_start, self.token.position_end.copy())

    return response.success(ClassDefinitionNode(variable_name, body_node, parents))

  def delete_expression(self):
    response = ParseResponse()

    if not self.token.check_keyword(DELETE):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `удалить` (`delete`)"
      ))

    position_start = self.token.position_start
    response.advance(self)

    if not self.token.check_type(IDENTIFIER):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидался Идентификатор"
      ))

    variable = self.token
    response.advance(self)

    return response.success(DeleteNode(variable, position_start, self.token.position_end.copy()))

  def include_statement(self):
    response = ParseResponse()

    if not self.token.check_keyword(INCLUDE):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось `включить` (`include`)"
      ))

    position_start = self.token.position_start.copy()
    response.advance(self)

    if not self.token.check_type(STRING):
      return response.failure(InvalidSyntaxError(
        self.token.position_start, self.token.position_end,
        "Ожидалось название модуля"
      ))

    module = self.token
    response.advance(self)

    return response.success(IncludeNode(module, position_start, self.token.position_end.copy()))

  def statements(self):
    response = ParseResponse()
    statements = []
    position_start = self.token.position_start.copy()

    if self.token.check_type(NEWLINE):
      response.advance(self)

    statements = [response.register(self.statement())]
    if response.error:
      return response

    more_statements = True

    while True:
      newline_count = 0
      if self.token.check_type(NEWLINE):
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
      statements, position_start,
      self.token.position_end.copy()
    ))

  def statement(self):
    response = ParseResponse()
    position_start = self.token.position_start.copy()

    if self.token.check_keyword(RETURN):
      response.advance(self)
      expression = response.try_register(self.expression())
      if not expression:
        self.reverse(response.to_reverse_count)

      return response.success(ReturnNode(expression, position_start, self.token.position_start.copy()))

    elif self.token.check_keyword(CONTINUE):
      response.advance(self)

      return response.success(ContinueNode(position_start, self.token.position_start.copy()))

    elif self.token.check_keyword(BREAK):
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
