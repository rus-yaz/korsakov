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

BUILDIN_FUNCTIONS = {
  "!error": [
    "section \"!error\" executable",
    "!error:",
    "mov rax, 1",
    "mov rdi, 1",
    "mov rsi, !error_message",
    "mov rdx, !error_message_length",
    "syscall",
    "mov rax, 60",
    "mov rdi, rbx",
    "syscall",
  ]
}


class Compiler:
  def __init__(self, file_name):
    self.code = []
    self.variables = {}
    self.backups = []
    self.functions = BUILDIN_FUNCTIONS.copy()
    self.counters = dict.fromkeys(["if", "rsp", "loop", "mark", "error", "frame", "access", "assign", "lambda"], 0)
    self.counters["frame"] = 1 # Смещение с учётом буфера по [rbp]
    self.file_path = realpath(file_name)
    self.script_location, self.file_name = self.file_path.rsplit(PATH_SEPARATOR, 1)

  def compile(self, node, context: Context):
    visitor = getattr(self, f"compile_{node.__class__.__name__}", self.no_compile_method)
    return visitor(node, context)

  def compile_sequence(self, node: ListNode, context: Context):
    for expression in node.elements:
      self.compile(expression, context)

  def no_compile_method(self, node, context: Context):
    raise Exception(f"Метод compile_{type(node).__name__} не объявлен")

  def new_code(self, code_lines, name_of_operation=None):
    self.code += (["", f"; {name_of_operation}"] if name_of_operation else []) + code_lines

  def enter(self, context):
    self.backups += [[self.variables.copy(), self.counters["frame"]]]
    self.new_code([
      "push !INTEGER_IDENTIFIER",
      "push [!rsp]"
    ])
    self.compile(VariableAssignNode(Token(STRING, f"!rsp{self.counters["rsp"]}"), [], None), context)
    self.new_code(["mov [!rsp], rsp"])
    self.counters["rsp"] += 1

  def leave(self, context):
    self.counters["rsp"] -= 1
    self.new_code(["mov rsp, [!rsp]"])
    self.compile(VariableAccessNode(Token(STRING, f"!rsp{self.counters["rsp"]}"), []), context)
    self.new_code([
      "pop [!rsp]",
      "pop rax",
      "add rsp, 8 * 2"
    ])
    self.variables, self.counters["frame"] = self.backups.pop()

  def error(self, text):
    self.counters["error"] += 1
    self.new_code([
      f"mov rbx, {self.counters["error"]}",
      "call !error"
    ], text)

  def replace_code(self, replaceable, substitute):
    self.code = list(map(lambda x: x.replace(replaceable, substitute), self.code))

  def compile_NumberNode(self, node: NumberNode, context: Context):
    self.new_code([
      "push !INTEGER_IDENTIFIER",
      f"mov rax, {node.token.value}",
      "push rax"
    ], "Нод числа")

  def compile_ListNode(self, node: ListNode, context: Context):
    self.new_code([], "Начало нода массива")

    node.elements = node.elements[::-1]
    elements_count = 0
    stack = [node.elements]
    while stack:
      current = stack.pop()
      for element in current:
        if isinstance(element, ListNode):
          stack += [element.elements]

        elements_count += 2

    self.compile_sequence(node, context)

    self.new_code([
      "push !LIST_IDENTIFIER",
      f"mov rax, {elements_count}",
      "push rax"
    ])

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

    elif node.operator.check_type(EQUAL):          operation = f"je  mark{self.counters["mark"] + 1}"
    elif node.operator.check_type(NOT_EQUAL):      operation = f"jne mark{self.counters["mark"] + 1}"
    elif node.operator.check_type(LESS):           operation = f"jl  mark{self.counters["mark"] + 1}"
    elif node.operator.check_type(MORE):           operation = f"jg  mark{self.counters["mark"] + 1}"
    elif node.operator.check_type(LESS_OR_EQUAL):  operation = f"jle mark{self.counters["mark"] + 1}"
    elif node.operator.check_type(MORE_OR_EQUAL):  operation = f"jge mark{self.counters["mark"] + 1}"

    elif node.operator.check_keyword(AND):         operation = "and rax, rbx"
    elif node.operator.check_keyword(OR):          operation = "or rax, rbx"

    else: operation = "push rbx"

    self.new_code([
      "pop rbx",
      "pop rdx",
      "pop rax",
      "pop rcx",
      "cmp rcx, rdx",
      f"je mark{self.counters["mark"]}"
    ])

    self.error("Несовместимые типы")

    self.new_code([f"mark{self.counters["mark"]}:"])
    self.counters["mark"] += 1

    self.new_code(["push !INTEGER_IDENTIFIER"])

    if node.operator.check_type(*COMPARISONS):
      self.new_code(["cmp rax, rbx"])

    self.new_code([operation])

    if node.operator.check_type(*COMPARISONS):
      self.new_code([
        "push 0",
        f"jmp mark{self.counters["mark"] + 1}",
        f"mark{self.counters["mark"]}:",
        "push 1",
        f"mark{self.counters["mark"] + 1}:"
      ])
      self.counters["mark"] += 2
    else:
      self.new_code(["push rax"])

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
        "pop rax", # Значение
        "pop rbx", # Идентификатор
        f"cmp rbx, !INTEGER_IDENTIFIER",
        f"je mark{self.counters["mark"]}"
      ])

      self.error("Операция может быть применена только к целому числу")

      self.new_code([
        f"mark{self.counters["mark"]}:",
        "push rbx",
        "push rax",
        f"{operator} rax",
        "push rbx",
        "push rax",
      ])
      self.counters["mark"] += 1

      self.compile(VariableAssignNode(node.node.variable, [], None), context)

      if node.operator.value:
        self.new_code([
          "pop rax",
          f"{operator} rax",
          "push rax"
        ])

  def compile_VariableAccessNode(self, node: VariableAccessNode, context: Context):
    variable = node.variable.value if node.variable else None

    self.new_code([], "Нод получения переменной")

    self.counters["access"] += 1

    if variable != None and variable not in self.variables:
      self.error(f"Переменная {variable} не объявлена")
      return

    self.new_code([
      f"lea rcx, [rbp - 8 * {self.variables[variable]}]"
      if variable != None else
      "pop rcx"
    ], "Получение идентификатора переменной")

    self.new_code([
      "mov rax, [rcx]",
      "mov rbx, [rcx - 8]",
    ])

    self.new_code([
      "cmp rax, !INTEGER_IDENTIFIER",
      f"jne mark{self.counters["mark"]}",
      "push rax",
      "push rbx",
      f"jmp access_mark{self.counters["access"]}",
    ])

    self.new_code([
      f"mark{self.counters["mark"]}:",
      "cmp rax, !LIST_IDENTIFIER",
      f"jne list_mark{self.counters["access"]}",
    ])
    self.counters["mark"] += 1

    if node.keys:
      keys = node.keys.copy()

      self.new_code([
        f"lea rdi, [rbp - 8 * {self.variables[variable]}]",
      ])

      while keys:
        self.new_code([
          "cmp rax, !LIST_IDENTIFIER",
          f"je mark{self.counters["mark"] + 1}",
        ])
        self.error("Индекс можно взять только у типа Список")
        self.counters["mark"] += 1

        self.new_code([
          f"mark{self.counters["mark"]}:"
        ])

        key, *keys = keys
        self.compile(key, context)

        self.new_code([
          "pop rdx",
          "imul rdx, 2",
          "pop rcx",
          "cmp rcx, !INTEGER_IDENTIFIER",
          f"je mark{self.counters["mark"] + 1}",
        ])
        self.error("Индекс должен иметь тип Число")
        self.counters["mark"] += 1

        self.new_code([
          f"mark{self.counters["mark"]}:",
          "cmp rdx, 0",
          f"jge mark{self.counters["mark"] + 1}",
          "add rdx, rbx",
          f"mark{self.counters["mark"] + 1}:",
          "cmp rdx, 0",
          f"jge mark{self.counters["mark"] + 2}",
        ])
        self.error("Индекс выходит за пределы")
        self.counters["mark"] += 2

        self.new_code([
          f"mark{self.counters["mark"]}:",
          "cmp rdx, rbx",
          f"jl mark{self.counters["mark"] + 1}"
        ])
        self.error("Индекс выходит за пределы")
        self.counters["mark"] += 1

        self.new_code([
          f"mark{self.counters["mark"]}:",
          "add rdx, 1",
          "imul rdx, 8",
          "add rdi, rdx",
          "mov rax, [rdi]",
          "mov rbx, [rdi + 8]"
        ])
        self.counters["mark"] += 1

    self.replace_code(f"list_mark{self.counters["access"]}", f"mark{self.counters["mark"]}")

    self.new_code([
      "push rbx",
      "push rax",
    ])

    self.new_code([f"jmp access_mark{self.counters["access"]}"])

    self.new_code([f"mark{self.counters["mark"]}:"])
    self.error("Неизвестный идентификатор типа")
    self.counters["mark"] += 1

    self.new_code([f"access_mark{self.counters["access"]}:"])
    self.replace_code(f"access_mark{self.counters["access"]}", f"mark{self.counters["mark"]}")

    self.counters["mark"] += 1
    self.counters["access"] -= 1

  def compile_VariableAssignNode(self, node: VariableAssignNode, context: Context):
    self.counters["assign"] += 1
    variable = node.variable.value
    is_new = variable not in self.variables

    self.new_code([], "Нод присвоения переменной")

    if node.value:
      self.compile(node.value, context)

    if is_new:
      self.variables |= {variable: self.counters["frame"]}

    self.new_code([
      "pop rbx", # Значение
      "pop rax", # Тип
    ])
    self.new_code([
      "cmp rax, !INTEGER_IDENTIFIER",
      f"jne mark{self.counters["mark"]}",
      "",
      f"lea rdx, [rbp - 8 * {self.variables[variable]}]",
      "mov [rdx], rax",
      "mov [rdx - 8], rbx",
      f"jmp assign_mark{self.counters["assign"]}"
    ])
    self.new_code([
      f"mark{self.counters["mark"]}:",
      "cmp rax, !LIST_IDENTIFIER",
      f"jne mark{self.counters["mark"] + 3}",
      "",
      f"lea rcx, [rbp - 8 * {self.variables[variable]}]",
      "lea rdx, [rsp + 8 * rbx - 8 * 1]",
      "mov rdi, 0",
      f"mark{self.counters["mark"] + 1}:",
      "cmp rbx, rdi",
      f"je mark{self.counters["mark"] + 2}",
      "mov rax, [rdx]",
      "sub rdx, 8",
      "mov [rcx], rax",
      "sub rcx, 8",
      "inc rdi",
      f"jmp mark{self.counters["mark"] + 1}",
      f"mark{self.counters["mark"] + 2}:",
      "mov rax, !LIST_IDENTIFIER",
      "mov [rcx], rax",
      "mov [rcx - 8], rbx",
      f"jmp assign_mark{self.counters["assign"]}",
    ])
    self.counters["mark"] += 3

    self.new_code([f"assign_mark{self.counters["assign"]}:"])
    self.replace_code(f"assign_mark{self.counters["assign"]}", f"mark{self.counters["mark"]}")
    self.counters["mark"] += 1

    if is_new:
      self.counters["frame"] += 2
      self.new_code(["sub rsp, 8 * 2"])

    if isinstance(node.value, ListNode):
      elements_count = 0
      stack = [node.value.elements]
      while stack:
        current = stack.pop()
        for element in current:
          if isinstance(element, ListNode):
            stack += [element.elements]

          elements_count += 1

      self.counters["frame"] += elements_count * 2
      self.variables[variable] = self.counters["frame"] - 2

    self.new_code([f"mark{self.counters["mark"]}:"])

    self.counters["mark"] += 1
    self.counters["assign"] -= 1

  def compile_IfNode(self, node: IfNode, context: Context):
    self.new_code([], "Начало конструкции \"если-то-иначе\"")
    self.counters["if"] += 1

    for condition, case_body, return_null in node.cases:
      self.new_code([f"mark{self.counters["mark"]}:"], "Ветвь \"если\"")
      self.counters["mark"] += 1

      self.compile(condition, context)

      self.new_code([
        "pop rax",
        "pop rbx",
        "cmp rax, 1",
        f"jne if_else_mark{self.counters["if"]}"
      ], "Переход к следующей ветви \"если\" или к ветви \"иначе\"")

      self.new_code([f"mark{self.counters["mark"]}:"], "Тело ветви \"если\"")
      self.counters["mark"] += 1

      if isinstance(case_body, ListNode):
        self.compile_sequence(case_body, context)
      else:
        self.compile(case_body, context)

      self.new_code([f"jmp if_end_mark{self.counters["if"]}"], "Завершение конструкции \"если-то-иначе\"")
      self.counters["mark"] += 1

      self.replace_code(f"if_else_mark{self.counters["if"]}", f"mark{self.counters["mark"]}")

    if node.else_case:
      body, return_null = node.else_case

      self.new_code([f"mark{self.counters["mark"]}:"], "Ветвь \"иначе\"")
      self.counters["mark"] += 1

      if isinstance(body, ListNode):
        self.compile_sequence(body, context)
      else:
        self.compile(body, context)

    self.replace_code(f"if_end_mark{self.counters["if"]}", f"mark{self.counters["mark"]}")

    self.new_code([f"mark{self.counters["mark"]}:"], "Завершение конструкции \"если-то-иначе\"")

    self.counters["mark"] += 1
    self.counters["if"] -= 1

  def compile_ForNode(self, node: ForNode, context: Context):
    self.new_code([], "Начало конструкции \"для-иначе\"")
    self.counters["loop"] += 1

    self.enter(context)

    self.compile(VariableAssignNode(node.variable_name, [], node.start_node), context)

    loop_start_mark = self.counters["mark"]
    self.counters["mark"] += 1

    self.new_code([f"loop_start_mark{self.counters["loop"]}:"], "Ветвь \"для\"")

    self.compile(
      BinaryOperationNode(VariableAccessNode(node.variable_name, []), Token(LESS), node.end_node),
      context
    )

    self.new_code([
      "pop rax",
      "pop rbx",
      "cmp rax, 1",
      f"jne loop_end_mark{self.counters["loop"]}"
    ], "Переход в конец цикла при невыполнении условия")

    self.new_code([f"mark{self.counters["mark"]}:"], "Тело ветви \"для\"")
    self.counters["mark"] += 1

    self.compile_sequence(node.body_node, context)

    step = NumberNode(Token(INTEGER, 1))
    if node.step_node:
      step = node.step_node

    self.new_code([f"loop_iteration_mark{self.counters["loop"]}:"], "Инкрементация итератора")

    self.compile(VariableAssignNode(
      node.variable_name, [],
      BinaryOperationNode(VariableAccessNode(node.variable_name, []), Token(ADDITION), step)
    ), context)

    self.replace_code(f"loop_iteration_mark{self.counters["loop"]}", f"mark{self.counters["mark"]}")
    self.counters["mark"] += 1

    self.new_code([f"jmp loop_start_mark{self.counters["loop"]}"], "Возвращение к началу цикла")
    self.new_code([f"loop_end_mark{self.counters["loop"]}:"], "Конец цикла \"для\"")

    self.replace_code(f"loop_start_mark{self.counters["loop"]}", f"mark{loop_start_mark}")
    self.replace_code(f"loop_end_mark{self.counters["loop"]}", f"mark{self.counters["mark"]}")

    self.counters["mark"] += 1
    self.counters["loop"] -= 1

    if node.else_case:
      expression, return_null = node.else_case

      self.compile(BinaryOperationNode(VariableAccessNode(node.variable_name, []), Token(EQUAL), node.start_node), context)

      self.new_code([
        "pop rax",
        "pop rbx",
        "cmp rax, 1",
        f"je mark{self.counters["mark"]}",
        f"jmp mark{self.counters["mark"] + 1}",
        f"mark{self.counters["mark"]}:"
      ], "Обработка ветви \"иначе\"")
      self.counters["mark"] += 1

      self.compile(expression, context)

      self.new_code([f"mark{self.counters["mark"] + 1}:"])
      self.counters["mark"] += 2

    self.leave(context)

  def compile_WhileNode(self, node: WhileNode, context: Context):
    self.new_code([], "Начало конструкции \"пока-иначе\"")
    self.counters["loop"] += 1

    self.enter(context)

    if node.else_case:
      self.new_code(["push 0"], "Счётчик итераций")

    loop_start_mark = self.counters["mark"]
    self.new_code([f"mark{self.counters["mark"]}:"], "Ветвь \"пока\"")
    self.counters["mark"] += 1

    self.compile(node.condition_node, context)

    self.new_code([
      "pop rax",
      "pop rbx",
      "cmp rax, 1",
      f"jne loop_end_mark{self.counters["loop"]}"
    ], "Переход в конец цикла при невыполнении условия")

    self.new_code([f"mark{self.counters["mark"]}:"], "Тело ветви \"пока\"")
    self.counters["mark"] += 1

    self.compile_sequence(node.body_node, context)

    if node.else_case:
      self.new_code([
        "pop rax",
        "inc rax",
        "push rax",
      ], "Увеличение счётчика итераций")

    self.new_code([f"jmp mark{loop_start_mark}"], "Возвращение к началу цикла")
    self.counters["mark"] += 1

    self.new_code([f"loop_end_mark{self.counters["loop"]}:"], "Конец цикла \"пока\"")

    self.replace_code(f"loop_end_mark{self.counters["loop"]}", f"mark{self.counters["mark"]}")
    self.counters["mark"] += 1

    self.counters["loop"] -= 1

    if node.else_case:
      expression, return_null = node.else_case

      self.new_code([
        "pop rax",
        "cmp rax, 0",
        f"je mark{self.counters["mark"]}",
        f"jmp mark{self.counters["mark"] + 1}",
        f"mark{self.counters["mark"]}:"
      ], "Переход к ветви \"иначе\", если цикл не было ни одной итерации")
      self.counters["mark"] += 1

      self.compile(expression, context)

      self.new_code([f"mark{self.counters["mark"] + 1}:"])
      self.counters["mark"] += 2

    self.leave(context)

  def compile_FunctionDefinitionNode(self, node: FunctionDefinitionNode, context: Context):
    function_name = node.variable_name.value if node.variable_name else f"!функция{self.counters["lambda"]}"
    compiler = Compiler(function_name)

    function = [
      f"section \"{function_name}\" executable",
      f"{function_name}:",
      "enter 0, 0",
    ]

    for index, argument_name in enumerate(node.argument_names):
      compiler.new_code([
        f"mov rax, [rbp + 8 * (2 + {len(node.argument_names)} - {index} - 1)]",
        "push rax"
      ])
      compiler.compile(VariableAccessNode(None, []), context)
      compiler.compile(VariableAssignNode(argument_name.variable, [], None), context)

    compiler.compile_sequence(node.body_node, context)

    compiler.replace_code("mark", ".mark")

    function += compiler.code + ["lea rax, [rsp + 8]", "leave", "ret"]

    self.functions[function_name] = function

  def compile_CallNode(self, node: CallNode, context: Context):
    self.enter(context)
    for index, argument in enumerate(node.argument_nodes):
      self.compile(argument, context)
      self.compile(VariableAssignNode(Token(STRING, f"!{index}"), [], None), context)

    for index in range(len(node.argument_nodes)):
      self.new_code([
        f"lea rax, [rbp - 8 * {self.variables[f"!{index}"]}]",
        "push rax"
      ])

    self.new_code([
      f"call {node.call_node.variable.value}",
      "mov r15, rax"
    ])
    self.leave(context)
    self.new_code(["push r15"])

    self.compile(VariableAccessNode(None, []), context)

  def compile_ReturnNode(self, node: ReturnNode, context: Context):
    self.compile(node.return_node, context)

  def compile_SkipNode(self, node: SkipNode, context: Context):
    self.new_code([f"jmp loop_iteration_mark{self.counters["loop"]}"], "Нод пропуска итерации")

  def compile_BreakNode(self, node: BreakNode, context: Context):
    self.new_code([f"jmp loop_end_mark{self.counters["loop"]}"], "Нод прерывания функции")
