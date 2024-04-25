from os import name as os_name
from os.path import realpath
from pathlib import Path

from nodes import *
from loggers import *
from tokens import *
from classes import *

FILE_EXTENSIONS = ["корс", "kors"]
PATH_SEPARATOR = "\\" if os_name == "nt" else "/"
LANGAUGE_PATH = __file__.rsplit(PATH_SEPARATOR, 1)[0]
BUILDIN_LIBRARIES = [
  str(file).rsplit(PATH_SEPARATOR, 1)[1]
  for file_extension in FILE_EXTENSIONS
  for file in Path(LANGAUGE_PATH).glob(f"*.{file_extension}")
]


class Compiler:
  def __init__(self, file_name):
    self.file_path = realpath(file_name)
    self.script_location, self.file_name = self.file_path.rsplit(PATH_SEPARATOR, 1)
    self.stack = {}
    self.functions = {}
    self.frames_count = 0
    self.mark_counter = 0
    self.end_mark_counter = 0
    self.lambda_functions_counter = 0
    self.code = []

  def compile(self, node, context: Context):
    visitor = getattr(self, f"compile_{node.__class__.__name__}", self.no_compile_method)
    return visitor(node, context)

  def no_compile_method(self, node, context: Context):
    raise Exception(f"Метод compile_{type(node).__name__} не объявлен")

  def new_code(self, code_lines, name_of_operation=None):
    self.code += (["", f"; {name_of_operation}"] if name_of_operation else []) + code_lines

  def compile_NumberNode(self, node: NumberNode, context: Context):
    self.new_code([
      f"push {node.token.value}"
    ], "Нод числа")

  def compile_ListNode(self, node: ListNode, context: Context):
    self.new_code([], "Начало нода массива")
    for element in node.elements:
      self.compile(element, context)
    self.new_code([], "Конец кода массива")

  def compile_BinaryOperationNode(self, node: BinaryOperationNode, context: Context):
    self.compile(node.left_node, context)
    self.compile(node.right_node, context)

    if   node.operator.check_type(ADDITION):       operation = "add rax, rbx"
    elif node.operator.check_type(SUBTRACTION):    operation = "sub rax, rbx"
    elif node.operator.check_type(MULTIPLICATION): operation = "imul rbx"
    elif node.operator.check_type(DIVISION):       operation = "idiv rbx"
    # elif node.operator.check_type(POWER):          operation = " rax, rbx"
    # elif node.operator.check_type(ROOT):           operation = " rax, rbx"

    elif node.operator.check_type(EQUAL):          operation = f"je  mark{self.mark_counter}"
    elif node.operator.check_type(NOT_EQUAL):      operation = f"jne mark{self.mark_counter}"
    elif node.operator.check_type(LESS):           operation = f"jl  mark{self.mark_counter}"
    elif node.operator.check_type(MORE):           operation = f"jg  mark{self.mark_counter}"
    elif node.operator.check_type(LESS_OR_EQUAL):  operation = f"jle mark{self.mark_counter}"
    elif node.operator.check_type(MORE_OR_EQUAL):  operation = f"jge mark{self.mark_counter}"

    elif node.operator.check_keyword(AND):         operation = "and rax, rbx"
    elif node.operator.check_keyword(OR):          operation = "or rax, rbx"

    else: operation = "push rbx"

    self.new_code([
      "pop rbx",
      "pop rax"
    ] + (["cmp rax, rbx"] if node.operator.check_type(*COMPARISONS) else []) + [
      operation
    ], "Нод бинарной операции")

    if node.operator.check_type(*COMPARISONS):
      self.new_code([
        "push 0",
        f"jmp mark{self.mark_counter + 1}",
        f"mark{self.mark_counter}:",
        "push 1",
        f"mark{self.mark_counter + 1}:"
      ])
      self.mark_counter += 2
    else:
      self.new_code(["push rax"])

  def compile_VariableAccessNode(self, node: VariableAccessNode, context: Context):
    variable = node.variable.value

    if node.keys:
      key = node.keys[0]
      self.compile(IfNode([[
        BinaryOperationNode(key, Token(LESS), NumberNode(Token(INTEGER, 0))),
        ListNode([BinaryOperationNode(key, Token(ADDITION), NumberNode(Token(INTEGER, len(self.stack[variable]))))]),
        False
      ]], [key, False]), context)

    if not isinstance(self.stack[variable], list):
      self.new_code([
        f"mov rax, [rbp - {8 * self.stack[variable]}]",
        "push rax"
      ], "Нод обращения к переменной")
    else:
      self.new_code([
        "pop rax",
        f"mov rax, [rbp - {8 * self.stack[variable][-1]} + rax*8]",
        "push rax"
      ])

  def compile_VariableAssignNode(self, node: VariableAssignNode, context: Context):
    variable = node.variable.value
    is_new = variable not in self.stack

    if not node.keys:
      if not isinstance(node.value, ListNode):
        if node.value:
          self.compile(node.value, context)

        if is_new:
          self.stack |= {variable: self.frames_count + 1}

        self.new_code([
          "pop rax",
          f"mov [rbp - {8 * self.stack[variable]}], rax",
        ], "Нод присвоения переменной")

        self.frames_count += 1

        if is_new:
          self.new_code(["sub rsp, 8"])
      else:
        if is_new:
          self.stack |= {variable: []}

        for index, value in enumerate(node.value.elements[::-1]):
          self.stack[variable] += [self.frames_count + index + 1]
          self.compile(value, context)

          self.new_code([
            "pop rax",
            f"mov [rbp - {8 * self.stack[variable][index]}], rax",
            "sub rsp, 8"
          ], "Нод присвоения переменной")

        self.frames_count += len(node.value.elements)
    else:
      self.compile(node.value, context)

      if node.keys:
        key = node.keys[0]
        self.compile(IfNode([[
          BinaryOperationNode(key, Token(LESS), NumberNode(Token(INTEGER, 0))),
          ListNode([BinaryOperationNode(key, Token(ADDITION), NumberNode(Token(INTEGER, len(self.stack[variable]))))]),
          False
        ]], [key, False]), context)

      self.new_code([
        "pop rbx",
        "pop rax",
        f"mov [rbp - {8 * self.stack[node.variable.value][-1]} + rbx*8], rax",
      ], "Нод присвоения переменной")

      self.frames_count += 1

  def compile_IfNode(self, node: IfNode, context: Context):
    self.new_code([], "Начало конструкции \"если-то-иначе\"")
    self.end_mark_counter += 1

    for condition, expression, return_null in node.cases:
      self.new_code([f"mark{self.mark_counter}:"], "Ветвь \"если\"")
      self.mark_counter += 1

      self.compile(condition, context)

      self.new_code([
        "pop rax",
        "cmp rax, 1",
        f"jne mark{self.mark_counter + 1}"
      ], "Переход к следующей ветви \"если\" или к ветви \"иначе\"")

      self.new_code([f"mark{self.mark_counter}:"], "Тело ветви \"если\"")
      self.compile(expression, context)

      self.new_code([f"jmp end_mark{self.end_mark_counter}"], "Завершение конструкции \"если-то-иначе\"")
      self.mark_counter += 1

    if node.else_case:
      expression, return_null = node.else_case

      self.new_code([f"mark{self.mark_counter}:"], "Ветвь \"иначе\"")
      self.mark_counter += 1
      self.compile(expression, context)

    self.code = list(map(lambda x: x.replace(
      f"end_mark{self.end_mark_counter}",
      f"mark{self.mark_counter}"
    ), self.code))
    self.new_code([f"mark{self.mark_counter}:"], "Завершение конструкции \"если-то-иначе\"")

    self.mark_counter += 1
    self.end_mark_counter -= 1

  def compile_ForNode(self, node: ForNode, context: Context):
    self.new_code([], "Начало конструкции \"для-иначе\"")
    self.end_mark_counter += 1

    self.compile(VariableAssignNode(node.variable_name, [], node.start_node), context)

    loop_start_mark = self.mark_counter
    self.new_code([f"mark{self.mark_counter}:"], "Ветвь \"для\"")
    self.mark_counter += 1

    self.compile(BinaryOperationNode(VariableAccessNode(node.variable_name, []), Token(LESS), node.end_node), context)

    self.new_code([
      "pop rax",
      "cmp rax, 1",
      f"jne end_mark{self.end_mark_counter}"
    ], "Переход в конец цикла при невыполнении условия")

    self.new_code([f"mark{self.mark_counter}:"], "Тело ветви \"для\"")
    self.compile(node.body_node, context)

    step = NumberNode(Token(INTEGER, 1))
    if node.step_node:
      step = node.step_node

    self.compile(VariableAssignNode(node.variable_name, [], BinaryOperationNode(VariableAccessNode(node.variable_name, []), Token(ADDITION), step)), context)

    self.new_code([f"jmp mark{loop_start_mark}"], "Возвращение к началу цикла")
    self.mark_counter += 1

    self.code = list(map(lambda x: x.replace(
      f"end_mark{self.end_mark_counter}",
      f"mark{self.mark_counter}"
    ), self.code))

    self.new_code([f"mark{self.mark_counter}:"])
    self.mark_counter += 1

    if node.else_case:
      expression, return_null = node.else_case

      self.compile(BinaryOperationNode(VariableAccessNode(node.variable_name, []), Token(EQUAL), node.start_node), context)

      self.new_code([
        "pop rax",
        "cmp rax, 1",
        f"je mark{self.mark_counter}",
        f"jmp mark{self.mark_counter + 1}",
        f"mark{self.mark_counter}:"
      ], "Обработка ветви \"иначе\"")

      self.compile(expression, context)

      self.new_code([f"mark{self.mark_counter + 1}:"])
      self.mark_counter += 2

    self.end_mark_counter -= 1

  def compile_WhileNode(self, node: WhileNode, context: Context):
    self.new_code([], "Начало конструкции \"пока-иначе\"")
    self.end_mark_counter += 1

    if node.else_case:
      self.new_code(["push 0"], "Счётчик итераций")

    loop_start_mark = self.mark_counter
    self.new_code([f"mark{self.mark_counter}:"], "Ветвь \"пока\"")
    self.mark_counter += 1

    self.compile(node.condition_node, context)

    self.new_code([
      "pop rax",
      "cmp rax, 1",
      f"jne end_mark{self.end_mark_counter}"
    ], "Переход в конец цикла при невыполнении условия")

    self.new_code([f"mark{self.mark_counter}:"], "Тело ветви \"пока\"")
    self.compile(node.body_node, context)

    if node.else_case:
      self.new_code([
        "pop rax",
        "inc rax",
        "push rax",
      ], "Увеличение счётчика итераций")

    self.new_code([f"jmp mark{loop_start_mark}"], "Возвращение к началу цикла")
    self.mark_counter += 1

    self.code = list(map(lambda x: x.replace(
      f"end_mark{self.end_mark_counter}",
      f"mark{self.mark_counter}"
    ), self.code))
    self.new_code([f"mark{self.mark_counter}:"])
    self.mark_counter += 1

    if node.else_case:
      expression, return_null = node.else_case

      self.new_code([
        "pop rax",
        "cmp rax, 0",
        f"je mark{self.mark_counter}",
        f"jmp mark{self.mark_counter + 1}",
        f"mark{self.mark_counter}:"
      ], "Переход к ветви \"иначе\", если цикл не было ни одной итерации")

      self.compile(expression, context)

      self.new_code([f"mark{self.mark_counter + 1}:"])
      self.mark_counter += 2

    self.end_mark_counter -= 1

  def compile_UnaryOperationNode(self, node: UnaryOperationNode, context: Context):
    if node.operator.check_keyword(NOT):
      self.new_code([], "Нод односторонней операции `не` (`not`)")
      self.compile(BinaryOperationNode(node.node, Token(EQUAL), NumberNode(Token(INTEGER, 0))), compile)
    elif node.operator.check_type(SUBTRACTION):
      self.new_code([], "Нод односторонней операции арифметического отрицания")
      self.compile(node.node, context)

      self.new_code(["pop rax", "neg rax", "push rax"])
    elif node.operator.check_type(INCREMENT, DECREMENT):
      operator = ["dec", "inc"][node.operator.check_type(INCREMENT)]

      self.compile(node.node, context)
      self.new_code([
        "pop rax",
        "push rax",
        f"{operator} rax",
        f"mov [rbp - {8 * self.stack[node.node.variable.value]}], rax"
      ])

      if node.operator.value:
        self.new_code([
          "pop rax",
          f"{operator} rax",
          "push rax"
        ])

  def compile_FunctionDefinitionNode(self, node: FunctionDefinitionNode, context: Context):
    function_name = node.variable_name.value if node.variable_name else f"!функция{self.lambda_functions_counter}"
    compiler = Compiler(function_name)

    function = [
      f"section \"{function_name}\" executable",
      f"{function_name}:",
      "push rbp",
      "mov rbp, rsp",
    ]

    for index, argument_name in enumerate(node.argument_names):
      compiler.new_code(["", f"mov rax, [rbp + {8 * (len(node.argument_names) - index + 1)}]", "push rax"])

      compiler.compile(VariableAssignNode(argument_name.variable, [], None), context)

    compiler.compile(node.body_node, context)

    function += compiler.code + ["pop rax", f"add rsp, {8 * len(compiler.stack)}", "pop rbp", "ret"]

    self.functions[function_name] = function

  def compile_CallNode(self, node: CallNode, context: Context):
    for argument in node.argument_nodes:
      self.compile(argument, context)

    self.new_code([
      f"call {node.call_node.variable.value}"
    ] + len(node.argument_nodes) * ["pop rbx"] + [
      "push rax"
    ], "Нод вызова функции")

  def compile_ReturnNode(self, node: ReturnNode, context: Context):
    self.compile(node.return_node, context)
