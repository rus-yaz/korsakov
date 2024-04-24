from loggers import Position


class Node:
  """
    Описание:
      Родительский класс, описывающий нод абстрактного синтаксического дерева

    Аргументы: -

    Поля класса:
      position_start (Position): начало нода
      position_end (Position): конец нода
  """
  def set_position(self, position_start, position_end):
    self.position_start = position_start
    self.position_end   = position_end


# --------------------------------------------------


class NumberNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева Number

    Аргументы:
      token (Token): токен числа

    Поля класса:
      token (Token): токен числа
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, token):
    self.token = token

    self.set_position(token.position_start, token.position_end)

  def __repr__(self):
    return f"NumberNode({self.token.value})"


class StringNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева String

    Аргументы:
      token (Token): токен строки

    Поля класса:
      token (Token): токен строки
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, token):
    self.token = token

    self.set_position(token.position_start, token.position_end)

  def __repr__(self):
    return f"StringNode(\"{self.token.value}\")"


class ListNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева List

    Аргументы:
      elements (список): список значений (элементы - *Node)
      position_start (Position): начало нода
      position_end (Position): конец нода

    Поля класса:
      elements (список): список значений (элементы - *Node)
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, elements: list, position_start=None, position_end=None):
    self.elements = elements

    self.set_position(position_start, position_end)

  def __repr__(self):
    return f"ListNode(%({'; '.join(map(str, self.elements))})%)"


class DictionaryNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева List

    Аргументы:
      elements (список): список пар ключ-значение (элементы - списки из двух элементов - ключ (*Node) и значение (*Node))
      position_start (Position): начало нода
      position_end (Position): конец нода

    Поля класса:
      elements (список): список пар ключ-значение (элементы - списки из двух элементов - ключ (*Node) и значение (*Node))
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, elements: list, position_start, position_end):
    self.elements = elements

    self.set_position(position_start, position_end)

  def __repr__(self):
    return f"DictionaryNode(%({'; '.join(f'{str(key)}: {str(value)}' for key, value in self.elements)})%)"


# --------------------------------------------------


class UnaryOperationNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева UnaryOperation

    Аргументы:
      operator (Token): токен оператора
      node (*Node): операнд

    Поля класса:
      operator (Token): токен оператора
      node (*Node): операнд
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, operator, node):
    self.operator = operator
    self.node     = node

    self.set_position(operator.position_start, node.position_end)

  def __repr__(self):
    return f"UnaryOperationNode({self.operator}; {self.node})"


class BinaryOperationNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева BinaryOperation

    Аргументы:
      left_node (*Node): левый операнд операции
      operator (Token): токен оператора
      right_node (*Node): правый операнд операции

    Поля класса:
      left_node (*Node): левый операнд операции
      operator (Token): токен оператора
      right_node (*Node): правый операнд операции
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, left_node, operator, right_node):
    self.left_node  = left_node
    self.operator   = operator
    self.right_node = right_node

    self.set_position(left_node.position_start, right_node.position_end)

  def __repr__(self):
    return f"BinaryOperationNode({self.left_node}; {self.operator}; {self.right_node})"


# --------------------------------------------------


class VariableAccessNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева VariableAccess

    Аргументы:
      variable (Token): название переменной
      keys (список): ключи/индексы (элементы - *Node, по умолчанию - пустой список)

    Поля класса:
      variable (Token): название переменной
      keys (список): ключи/индексы (элементы - *Node, по умолчанию - пустой список)
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, variable, keys: list = []):
    self.variable = variable
    self.keys     = keys

    position_end = self.variable.position_end
    if self.keys:
      position_end = self.keys[-1].position_end

    self.set_position(self.variable.position_start, position_end)

  def __repr__(self):
    return f"VariableAccessNode({self.variable.value}; {self.keys})"


class VariableAssignNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева VariableAssign

    Аргументы:
      variable (Token): название переменной
      keys (список): ключи/индексы (элементы - *Node)
      value (*Node): присваиваемое значение

    Поля класса:
      variable (Token): название переменной
      keys (список): ключи/индексы (элементы - *Node)
      value (*Node): присваиваемое значение
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, variable, keys: list, value):
    self.variable = variable
    self.keys     = keys
    self.value    = value

    self.set_position(variable.position_start, variable.position_end)

  def __repr__(self):
    return f"VariableAssignNode({self.variable.value}; {self.keys}; {self.value})"


# --------------------------------------------------


class CheckNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева Check

    Аргументы:
      cases (список): элементы - списки с элементами - условие (*Node), инструкции при выполнении условия (ListNode) и сигнал о том, что случай записан в одну строку (булево значение)
      else_case (список): элементы - инструкции (ListNode) и сигнал о том, что случай записан в одну строку (булево значение)

    Поля класса:
      cases (список): элементы - списки с элементами - условие (*Node), инструкции при выполнении условия (ListNode) и сигнал о том, что случай записан в одну строку (булево значение)
      else_case (список): элементы - инструкции (ListNode) и сигнал о том, что случай записан в одну строку (булево значение)
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, cases, else_case):
    self.cases     = cases
    self.else_case = else_case

    self.set_position(cases[0][0].position_start, (else_case or cases[-1])[0].position_end)

  def __repr__(self):
    return f"CheckNode({self.cases}; {self.else_case})"


class IfNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева Check

    Аргументы:
      cases (список): элементы - списки с элементами - условие (*Node), инструкции при выполнении условия (ListNode) и сигнал о том, что случай записан в одну строку (булево значение)
      else_case (список): элементы - инструкции (ListNode) и сигнал о том, что случай записан в одну строку (булево значение)

    Поля класса:
      cases (список): элементы - списки с элементами - условие (*Node), инструкции при выполнении условия (ListNode) и сигнал о том, что случай записан в одну строку (булево значение)
      else_case (список): элементы - инструкции (ListNode) и сигнал о том, что случай записан в одну строку (булево значение)
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, cases, else_case):
    self.cases     = cases
    self.else_case = else_case

    self.set_position(cases[0][0].position_start, (else_case or cases[-1])[0].position_end)

  def __repr__(self):
    return f"IfNode({self.cases}; {self.else_case})"


# --------------------------------------------------


class ForNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева For

    Аргументы:
      variable_name (Token): название переменной-итератора
      start_node (*Node): начало диапазона или массив для итерации
      end_node (*Node): конец диапазона
      step_node (*Node): шаг итерации
      body_node (ListNode): список инструкций
      return_null (булево значение): однострочность
      else_case (ListNode): набор инструкций, исполняемый в том случае, если итераций не было

    Поля класса:
      variable_name (Token): название переменной-итератора
      start_node (*Node): начало диапазона или массив для итерации
      end_node (*Node): конец диапазона
      step_node (*Node): шаг итерации
      body_node (ListNode): список инструкций
      return_null (булево значение): однострочность
      else_case (ListNode): набор инструкций, исполняемый в том случае, если итераций не было
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, variable_name, start_node, end_node, step_node, body_node, return_null, else_case):
    self.variable_name = variable_name
    self.start_node    = start_node
    self.end_node      = end_node
    self.step_node     = step_node
    self.body_node     = body_node
    self.return_null   = return_null
    self.else_case     = else_case

    self.set_position(variable_name.position_start, body_node.position_end)

  def __repr__(self):
    return f"ForNode({self.variable_name.value}; {self.start_node}; {self.end_node}; {self.step_node}; {self.body_node}; {self.return_null}; {self.else_case})"


class WhileNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева While

    Аргументы:
      condition_node (*Node): нод условия
      body_node (ListNode): список инструкций
      return_null (булево значение): однострочность
      else_case (ListNode): набор инструкций, исполняемый в том случае, если итераций не было

    Поля класса:
      condition_node (*Node): нод условия
      body_node (ListNode): список инструкций
      return_null (булево значение): однострочность
      else_case (ListNode): набор инструкций, исполняемый в том случае, если итераций не было
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, condition_node, body_node, return_null, else_case):
    self.condition_node = condition_node
    self.body_node      = body_node
    self.return_null    = return_null
    self.else_case      = else_case

    self.set_position(condition_node.position_start, body_node.position_end)

  def __repr__(self):
    return f"WhileNode({self.condition_node}; {self.body_node}; {self.return_null}; {self.else_case})"


# --------------------------------------------------


class FunctionDefinitionNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева FunctionDefinition

    Аргументы:
      variable_name (Token): название функции
      argument_names (список): аргументы функции (элементы - VariableAccessNode или VariableAssignNode)
      body_node (ListNode): список инструкций
      auto_return (булево значение): однострочность

    Поля класса:
      variable_name (Token): название функции
      argument_names (список): аргументы функции (элементы - VariableAccessNode или VariableAssignNode)
      body_node (ListNode): список инструкций
      auto_return (булево значение): однострочность
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, variable_name, argument_names, body_node, auto_return):
    self.variable_name  = variable_name
    self.argument_names = argument_names
    self.body_node      = body_node
    self.auto_return    = auto_return

    self.set_position((variable_name or (argument_names and argument_names[0]) or body_node).position_start, body_node.position_end)

  def __repr__(self):
    return f"FunctionDefinitionNode({self.variable_name.value}; {self.argument_names}; {self.body_node}; {self.auto_return})"


class ClassDefinitionNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева ClassDefinition

    Аргументы:
      variable_name (Token): название функции
      body_node (ListNode): список инструкций
      parents (список): аргументы функции (элементы - строки)

    Поля класса:
      variable_name (Token): название функции
      body_node (ListNode): список инструкций
      parents (список): аргументы функции (элементы - строки)
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, variable_name, body_node, parents):
    self.variable_name = variable_name
    self.body_node     = body_node
    self.parents       = parents

    self.set_position(variable_name.position_start, body_node.position_end)

  def __repr__(self):
    return f"ClassDefinitionNode({self.variable_name.value}; {self.body_node})"


class MethodDefinitionNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева MethodDefinition

    Аргументы:
      variable_name (Token): название метода
      argument_names (список): аргументы метода (элементы - VariableAccessNode или VariableAssignNode)
      body_node (ListNode): список инструкций
      auto_return (булево значение): однострочность
      class_name (строка): название класса (по умолчанию - "")
      object_name (строка): название объекта (по умолчанию - "")

    Поля класса:
      variable_name (Token): название метода
      argument_names (список): аргументы функции (элементы - VariableAccessNode или VariableAssignNode)
      body_node (ListNode): список инструкций
      auto_return (булево значение): однострочность
      class_name (строка): название класса (по умолчанию - "")
      object_name (строка): название объекта (по умолчанию - "")
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, variable_name, argument_names, body_node, auto_return, class_name="", object_name=""):
    self.variable_name  = variable_name
    self.argument_names = argument_names
    self.body_node      = body_node
    self.auto_return    = auto_return
    self.class_name     = class_name
    self.object_name    = object_name

    self.set_position((variable_name or argument_names[0] or body_node).position_start, body_node.position_end)

  def __repr__(self):
    return f"MethodDefinitionNode({self.variable_name.value}; {self.argument_names}; {self.body_node}; {self.auto_return})"


class CallNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева Call

    Аргументы:
      call_node (VariableAccess): переменная для вызова
      argument_nodes (список): переданные аргументы (элементы - *Node)

    Поля класса:
      call_node (VariableAccess): переменная для вызова
      argument_nodes (список): переданные аргументы (элементы - *Node)
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, call_node, argument_nodes):
    self.call_node      = call_node
    self.argument_nodes = argument_nodes

    self.set_position(call_node.position_start, argument_nodes[-1].position_end if argument_nodes else call_node.position_end)

  def __repr__(self):
    return f"CallNode({self.call_node}; {self.argument_nodes})"


# --------------------------------------------------


class ReturnNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева Return

    Аргументы:
      return_node (*Node): нод для возврата

    Поля класса:
      return_node (*Node): нод для возврата
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, return_node, position_start, position_end):
    self.return_node = return_node

    self.set_position(position_start, position_end)

  def __repr__(self):
    return f"ReturnNode({self.return_node})"


class ContinueNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева Continue

    Аргументы:
      position_start (Position): начало нода
      position_end (Position): конец нода

    Поля класса:
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, position_start, position_end):
    self.set_position(position_start, position_end)

  def __repr__(self):
    return f"ContinueNode"


class BreakNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева Break

    Аргументы:
      position_start (Position): начало нода
      position_end (Position): конец нода

    Поля класса:
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, position_start, position_end):
    self.set_position(position_start, position_end)

  def __repr__(self):
    return f"BreakNode"


# --------------------------------------------------

class DeleteNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева Delete

    Аргументы:
      variable (Token): название удаляемой переменной
      position_start (Position): начало нода
      position_end (Position): конец нода

    Поля класса:
      variable (Token): название удаляемой переменной
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, variable, position_start, position_end):
    self.variable = variable

    self.set_position(position_start, position_end)

  def __repr__(self):
    return f"DeleteNode({self.variable.value})"


class IncludeNode(Node):
  """
    Описание:
      Класс, описывающий нод абстрактного синтаксического дерева Include

    Аргументы:
      module (Token): название подключаемого модуля
      position_start (Position): начало нода
      position_end (Position): конец нода

    Поля класса:
      module (Token): название подключаемого модуля
      position_start (Position): начало нода
      position_end (Position): конец нода
  """

  def __init__(self, module, position_start, position_end):
    self.module = module

    self.set_position(position_start, position_end)

  def __repr__(self):
    return f"IncludeNode({self.module.value})"
