from os import name as os_name
from os.path import realpath
from pathlib import Path

from nodes import *
from tokens import *

FILE_EXTENSIONS = ["корс", "kors"]
PATH_SEPARATOR = "\\" if os_name == "nt" else "/"
LANGAUGE_PATH = __file__.rsplit(PATH_SEPARATOR, 1)[0]
BUILDIN_LIBRARIES = [
  str(file).rsplit(PATH_SEPARATOR, 1)[1]
  for file_extension in FILE_EXTENSIONS
  for file in Path(LANGAUGE_PATH).glob(f"*.{file_extension}")
]

ASSEMBLY_FUNCTIONS = {
  ("exit", "выход"): [
    "enter 0, 0",
    "mov rax, [rbp + 8 * 2]",

    "mov rbx, [rax - 8]",
    "mov rax, [rax]",

    "cmp rax, !INTEGER_IDENTIFIER",
    "je .mark0",

    "push !INTEGER_IDENTIFIER",
    "mov rax, -1",
    "push rax",
    "lea rax, [rsp + 8]",
    "push rax",
    "call error",

    ".mark0:"
    "mov rax, !SYSCALL_EXIT",
    "mov rdi, rbx",
    "syscall",
  ],
  ("error", "ошибка"): [
    "enter 0, 0",
    "mov rax, [rbp + 8 * 2]",

    "mov rbx, [rax - 8]",
    "mov rax, [rax]",

    "cmp rax, !INTEGER_IDENTIFIER",
    "je .mark0",

    "push !INTEGER_IDENTIFIER",
    "mov rax, -1",
    "push rax",
    "lea rax, [rsp + 8]",
    "push rax",
    "call error",

    ".mark0:",
    "mov rax, !SYSCALL_WRITE",
    "mov rdi, !FILE_DESCRIPTOR_ERROR",
    "mov rsi, !error_message",
    "mov rdx, !error_message_length",
    "syscall",

    "push !INTEGER_IDENTIFIER",
    "push rbx",
    "lea rax, [rsp + 8]",
    "push rax",
    "call exit",
  ],
  ("print_number", "показать_число", "показать"): [
    "enter 0, 0",
    "mov rax, [rbp + 8 * 2]",

    "mov rax, [rax - 8]",
    "mov rbx, !buffer",
    "mov rcx, !buffer_size",
    "call !number_to_buffer",

    "call !print_buffer",

    "push 10",
    "mov rax, !SYSCALL_WRITE",
    "mov rdi, !FILE_DESCRIPTOR_OUTPUT",
    "mov rsi, rsp",
    "mov rdx, 8",
    "syscall",
    "pop rax",

    "push !INTEGER_IDENTIFIER",
    "mov rax, 0",
    "push rax",
    "lea rax, [rsp + 8]",

    "leave",
    "ret",
  ],
  ("!print_buffer", ): [
    "mov rsi, !buffer",
    "mov rax, rsi",
    "call !buffer_length",
    "mov rdx, rax",

    "mov rax, !SYSCALL_WRITE",
    "mov rdi, !FILE_DESCRIPTOR_OUTPUT",
    "syscall",
    "ret",
  ],
  ("!buffer_length",): [
    "mov rbx, 0",
    "mov rcx, 0",
    ".mark0:",
    "cmp [rax + rbx], rcx",
    "je .mark1",
    "inc rbx",
    "jmp .mark0",
    ".mark1:",
    "mov rax, rbx",
    "ret",
  ],
  ("!number_to_buffer", ): [
    "mov rsi, rcx",
    "mov rcx, 0",

    ".mark0:",
    "push rbx",
    "mov rbx, 10",
    "mov rdx, 0",
    "div rbx",
    "pop rbx",
    "add rdx, !ASCII_0",
    "push rdx",
    "inc rcx",
    "cmp rax, 0",
    "je .mark1",
    "jmp .mark0",

    ".mark1:",
    "mov rdx, rcx",
    "mov rcx, 0",

    ".mark2:",
    "cmp rcx, rdx",
    "je .mark3",
    "pop rax",
    "mov [rbx + rcx], rax",
    "inc rcx",
    "jmp .mark2",

    ".mark3:",
    "cmp rcx, rdx",
    "je .mark4",
    "pop rax",
    "inc rcx",
    "jmp .mark3",

    ".mark4:",
    "ret",
  ],
}

BUILDIN_FUNCTIONS = {}
for function_names, function_body in ASSEMBLY_FUNCTIONS.items():
  for function_name in function_names:
    BUILDIN_FUNCTIONS[function_name] = [f'section "{function_name}" executable', f"{function_name}:"] + function_body

class Compiler:
  def __init__(self, file_name):
    self.code = []
    self.variables = {}
    self.backups = []
    self.functions = BUILDIN_FUNCTIONS.copy()
    self.counters = dict.fromkeys([
      "if", "rsp", "loop", "mark", "error", "frame", "access", "assign", "lambda"
    ], 0)
    self.counters["frame"] = 1 # Смещение с [rbp]
    self.file_path = realpath(file_name)
    self.script_location, self.file_name = self.file_path.rsplit(PATH_SEPARATOR, 1)

  def compile(self, node):
    visitor = getattr(self, f"compile_{node.__class__.__name__}", self.no_compile_method)
    return visitor(node)

  def compile_sequence(self, nodes: list):
    for node in nodes:
      self.compile(node)

  def compile_program(self, node: ListNode):
    # .enter и .leave нужны для очистки от мусора на стеке (к примеру, инкремент/декремент)

    for expression in node.elements:
      if not isinstance(expression, VariableAssignNode):
        self.enter()

      self.compile(expression)

      if not isinstance(expression, (VariableAssignNode, ReturnNode)):
        self.leave()

  def no_compile_method(self, node):
    raise SyntaxError(f"Метод compile_{type(node).__name__} не объявлен")

  def comment(self, text):
    self.code += ["", "; " + text]

  def operation(self, operator, *operands):
    self.code += [f"{operator}{' ' + ', '.join(map(str, operands))}"]

  def operations(self, *operations):
    for operator, *operands in operations:
      self.operation(operator, *operands)

  def pop(self, operand):
    self.operation("pop", operand)

  def pops(self, *operands):
    for operand in operands:
      self.pop(operand)

  def push(self, operand):
    self.operation("push", operand)

  def pushs(self, *operands):
    for operand in operands:
      self.push(operand)

  def mov(self, destination, source):
    self.operation("mov", destination, source)

  def movs(self, *operands):
    for destination, source in operands:
      self.mov(destination, source)

  def lea(self, destination, source):
    self.operation("lea", destination, source)

  def leas(self, *operands):
    for destination, source in operands:
      self.lea(destination, source)

  def jump(self, mark_index=None, mark_name="mark"):
    if mark_index is None:
      mark_index = self.counters["mark"]

    self.operation("jmp", f"{mark_name}{mark_index}")

  def mark(self, mark_index=None, mark_name="mark"):
    if mark_index is None:
      mark_index = self.counters["mark"]
      self.counters["mark"] += 1

    self.operation(f"\n{mark_name}{mark_index}:")

  def compare(self, first, second, condition, mark_index=None, mark_name="mark"):
    if mark_index is None:
      mark_index = self.counters["mark"]

    self.operations(
      ["cmp", first, second],
      [f"j{condition}", f"{mark_name}{mark_index}"]
    )

  def replace_code(self, replaceable, substitute):
    self.code = list(map(lambda x: x.replace(replaceable, substitute), self.code))

  def enter(self):
    self.backups += [[self.variables.copy(), self.counters["frame"]]]
    self.pushs("!INTEGER_IDENTIFIER", "[!rsp]")
    self.compile(VariableAssignNode(Token(STRING, f"!rsp{self.counters["rsp"]}"), [], None))
    self.mov("[!rsp]", "rsp")
    self.counters["rsp"] += 1

  def leave(self):
    self.counters["rsp"] -= 1
    self.mov("rsp", "[!rsp]")
    self.compile(VariableAccessNode(Token(STRING, f"!rsp{self.counters["rsp"]}"), []))
    self.pops("[!rsp]", "rax")
    self.operation("add", "rsp", "8 * 2")
    self.variables, self.counters["frame"] = self.backups.pop()

  def error(self, text):
    self.counters["error"] += 1
    self.comment(text)
    self.pushs("!INTEGER_IDENTIFIER", self.counters["error"])
    self.lea("rax", "[rsp + 8]")
    self.push("rax")
    self.operation("call", "error")

  def compile_NumberNode(self, node: NumberNode):
    self.comment("Нод числа")
    self.mov("rax", node.token.value)
    self.pushs("!INTEGER_IDENTIFIER", "rax")

  def compile_ListNode(self, node: ListNode):
    self.comment("Начало нода списка")

    self.comment("Начало элементов списка")
    self.compile_sequence(node.elements[::-1])
    self.comment("Конец элементов списка")

    self.comment("Количество элементов")
    self.mov("rax", f"{len(node.elements)}")
    self.pushs("!INTEGER_IDENTIFIER", "rax")

    elements_count = 0
    stack = [node.elements]
    while stack:
      current = stack.pop()
      for element in current:
        if isinstance(element, ListNode):
          stack += [element.elements]
          elements_count += 1

        elements_count += 1

    elements_count += 2

    self.comment("Полная длина")
    self.mov("rax", f"{elements_count}")
    self.pushs("!LIST_IDENTIFIER", "rax")

    self.comment("Конец нода списка")

  def compile_BinaryOperationNode(self, node: BinaryOperationNode):
    self.compile(node.left_node)
    self.compile(node.right_node)

    operator, operands = None, None

    if node.operator.check_type(ADDITION):
      operator, *operands = "add", "rax", "rbx"
    elif node.operator.check_type(SUBTRACTION):
      operator, *operands = "sub", "rax", "rbx"
    elif node.operator.check_type(MULTIPLICATION):
      operator, *operands = "imul", "rbx"
    elif node.operator.check_type(DIVISION):
      operator, *operands = "idiv", "rbx"

    elif node.operator.check_keyword(AND):
      operator, *operands = "and", "rax", "rbx"
    elif node.operator.check_keyword(OR):
      operator, *operands = "or", "rax", "rbx"

    elif node.operator.check_type(EQUAL):
      operator = "e"
    elif node.operator.check_type(NOT_EQUAL):
      operator = "ne"
    elif node.operator.check_type(LESS):
      operator = "l"
    elif node.operator.check_type(MORE):
      operator = "g"
    elif node.operator.check_type(LESS_OR_EQUAL):
      operator = "le"
    elif node.operator.check_type(MORE_OR_EQUAL):
      operator = "ge"

    if operator is None and operands is None:
      self.error("Неизвестная бинарная операция")
      return

    self.pops("rbx", "rdx", "rax", "rcx")

    self.compare("rcx", "rdx", "e")
    self.error("Несовместимые типы")
    self.mark()

    self.push("!INTEGER_IDENTIFIER")

    if operands is None:
      self.compare("rax", "rbx", operator)

      self.push(0)
      self.jump(self.counters["mark"] + 1)
      self.mark()

      self.push(1)
      self.mark()
    else:
      self.operation(operator, *operands)
      self.push("rax")

  def compile_UnaryOperationNode(self, node: UnaryOperationNode):
    if node.operator.check_keyword(NOT):
      self.comment("Нод односторонней операции `не` (`not`)")
      self.compile(BinaryOperationNode(node.node, Token(EQUAL), NumberNode(Token(INTEGER, "0"))))
    elif node.operator.check_type(SUBTRACTION):
      self.comment("Нод односторонней операции арифметического отрицания")
      self.compile(node.node)

      self.pop("rax")
      self.operation("neg", "rax")
      self.push("rax")
    elif node.operator.check_type(INCREMENT, DECREMENT):
      operator = ["dec", "inc"][node.operator.check_type(INCREMENT)]

      self.compile(node.node)

      self.pops("rax", "rbx")

      self.compare("rbx", "!INTEGER_IDENTIFIER", "e")
      self.error("Операция может быть применена только к целому числу")
      self.mark()

      self.pushs("rbx", "rax")
      self.operation(operator, "rax")
      self.pushs("rbx", "rax")

      self.compile(VariableAssignNode(node.node.variable, [], None))

      if node.operator.value:
        self.pop("rax")
        self.operation(operator, "rax")
        self.push("rax")

  def compile_VariableAccessNode(self, node: VariableAccessNode):
    variable = node.variable.value if node.variable else None

    self.comment("Нод получения переменной")
    self.counters["access"] += 1

    if variable is not None and variable not in self.variables:
      self.error(f"Переменная {variable} не объявлена")
      return

    if variable is None:
      self.pop("rcx")
    else:
      self.lea("rcx", f"[rbp - 8 * {self.variables[variable]}]")

    self.comment("Получение идентификатора переменной")

    self.movs(
      ["rax", "[rcx]"],
      ["rbx", "[rcx - 8]"]
    )
    self.compare("rax", "!INTEGER_IDENTIFIER", "ne")
    self.pushs("rax", "rbx")
    self.jump(self.counters["access"], "access_mark")

    self.mark()
    self.compare("rax", "!LIST_IDENTIFIER", "ne", self.counters["access"], "list_mark")

    if node.keys:
      keys = node.keys.copy()

      self.mov("rdi", "rcx")

      while keys:
        self.compare("rax", "!LIST_IDENTIFIER", "e")
        self.error("Индекс можно взять только у типа Список")
        self.mark()

        self.pushs("rax", "rbx", "rdi")

        key, *keys = keys
        self.compile(key)
        self.pops("rdx", "rcx")

        self.pops("rdi", "rbx", "rax")

        self.compare("rcx", "!INTEGER_IDENTIFIER", "e")
        self.error("Индекс должен иметь тип Число")
        self.mark()

        self.operation("add", "rdi", 8 * 2)
        self.mov("rsi", "[rdi - 8]")
        self.operation("add", "rdi", 8 * 2)

        self.compare("rdx", 0, "ge")
        self.operation("add", "rdx", "rsi")

        self.compare("rdx", 0, "ge")
        self.error("Индекс выходит за пределы")
        self.mark()

        self.compare("rdx", "rsi", "l")
        self.error("Индекс выходит за пределы")
        self.mark()

        self.operations(
          ["imul", "rdx", 8 * 2],
          ["add", "rdi", "rdx"]
        )

        self.movs(
          ["rax", "[rdi]"],
          ["rbx", "[rdi - 8]"]
        )

    self.replace_code(f"list_mark{self.counters["access"]}", f"mark{self.counters["mark"]}")

    self.pushs("rax", "rbx")
    self.jump(self.counters["access"], "access_mark")
    self.mark()

    self.error("Неизвестный идентификатор типа")
    self.mark(self.counters["access"], "access_mark")

    self.replace_code(f"access_mark{self.counters['access']}", f"mark{self.counters['mark']}")

    self.counters["mark"] += 1
    self.counters["access"] -= 1

  def compile_VariableAssignNode(self, node: VariableAssignNode):
    self.counters["assign"] += 1
    variable = node.variable.value
    is_new = variable not in self.variables

    self.comment("Нод присвоения переменной")

    if node.value:
      self.comment("Исполнение присваиваемого")
      self.compile(node.value)

    if is_new:
      self.variables[variable] = self.counters["frame"]

    self.comment("Проверка типа присваиваемого")

    self.pops("rbx", "rax")
    self.lea("rcx", f"[rbp - 8 * {self.variables[variable]}]")

    self.compare("rax", "!INTEGER_IDENTIFIER", "ne")

    self.movs(
      ["[rcx]", "rax"],
      ["[rcx - 8]", "rbx"]
    )

    self.jump(self.counters["assign"], "assign_mark")
    self.mark()

    self.compare("rax", "!LIST_IDENTIFIER", "ne", self.counters["mark"] + 2)
    self.pushs("rax", "rbx")

    self.operation("imul", "rbx", 2)
    self.lea("rdx", "[rsp + 8 * rbx - 8 * 1]")

    self.mov("rdi", 0)
    self.mark()

    self.compare("rbx", "rdi", "e")
    self.movs(
      ["rax", "[rdx]"],
      ["[rcx]", "rax"],
    )
    self.operations(
      ["sub", "rdx", 8],
      ["sub", "rcx", 8],
      ["inc", "rdi"],
    )
    self.jump(self.counters["mark"] - 1)
    self.mark()

    self.replace_code(f"assign_mark{self.counters["assign"]}", f"mark{self.counters["mark"]}")
    self.mark()

    if isinstance(node.value, ListNode):
      elements_count = 0
      stack = [node.value.elements]
      while stack:
        current = stack.pop()
        for element in current:
          if isinstance(element, ListNode):
            stack += [element.elements]
            elements_count += 1

          elements_count += 1

      self.counters["frame"] += (elements_count + 1) * 2
      self.variables[variable] = self.counters["frame"]
      self.operation("add", "rsp", 8 * 2)

    if is_new:
      self.counters["frame"] += 2
      self.operation("sub", "rsp", 8 * 2)

    self.counters["assign"] -= 1

  def compile_IfNode(self, node: IfNode):
    self.comment("Начало конструкции \"если-то-иначе\"")
    self.counters["if"] += 1

    for condition, case_body, return_null in node.cases:
      self.comment("Ветвь \"если\"")
      self.mark()

      self.compile(condition)

      self.comment("Переход к следующей ветви \"если\" или к ветви \"иначе\"")
      self.pops("rax", "rbx")
      self.compare("rax", 1, "ne", self.counters["if"], "if_else_mark")

      self.comment("Тело ветви \"если\"")
      self.mark()

      if isinstance(case_body, ListNode):
        self.compile_sequence(case_body.elements)
      else:
        self.compile(case_body)

      self.comment("Завершение конструкции \"если-то-иначе\"")
      self.jump(self.counters["if"], "if_end_mark")

      self.replace_code(f"if_else_mark{self.counters["if"]}", f"mark{self.counters["mark"]}")

    if node.else_case:
      body, return_null = node.else_case

      self.comment("Ветвь \"иначе\"")
      self.mark()

      if isinstance(body, ListNode):
        self.compile_sequence(body.elements)
      else:
        self.compile(body)

    self.replace_code(f"if_end_mark{self.counters["if"]}", f"mark{self.counters["mark"]}")

    self.comment("Завершение конструкции \"если-то-иначе\"")
    self.mark()

    self.counters["if"] -= 1

  def compile_ForNode(self, node: ForNode):
    self.comment("Начало конструкции \"для-иначе\"")
    self.counters["loop"] += 1

    self.enter()

    self.compile(VariableAssignNode(node.variable_name, [], node.start_node))

    loop_start_mark = self.counters["mark"]
    self.counters["mark"] += 1

    self.comment("Ветвь \"для\"")
    self.mark(self.counters["loop"], "loop_start_mark")

    self.compile(BinaryOperationNode(
      VariableAccessNode(node.variable_name, []),
      Token(LESS),
      node.end_node
    ))

    self.comment("Переход в конец цикла при невыполнении условия")
    self.pops("rax", "rbx")
    self.compare("rax", 1, "ne", self.counters["loop"], "loop_end_mark")

    self.comment("Тело ветви \"для\"")
    self.mark()

    self.compile_sequence(node.body_node.elements)

    step = NumberNode(Token(INTEGER, "1"))
    if node.step_node:
      step = node.step_node

    self.comment("Инкрементация итератора")
    self.mark(self.counters["loop"], "loop_iteration_mark")

    self.compile(VariableAssignNode(
      node.variable_name, [],
      BinaryOperationNode(VariableAccessNode(node.variable_name, []), Token(ADDITION), step)
    ))

    self.replace_code(f"loop_iteration_mark{self.counters['loop']}", f"mark{self.counters["mark"]}")
    self.counters["mark"] += 1

    self.comment("Возвращение к началу цикла")
    self.jump(self.counters["loop"], "loop_start_mark")

    self.comment("Конец цикла \"для\"")
    self.mark(self.counters["loop"], "loop_end_mark")

    self.replace_code(f"loop_start_mark{self.counters['loop']}", f"mark{loop_start_mark}")
    self.replace_code(f"loop_end_mark{self.counters['loop']}", f"mark{self.counters["mark"]}")

    self.counters["mark"] += 1
    self.counters["loop"] -= 1

    if node.else_case:
      expression, return_null = node.else_case

      self.compile(BinaryOperationNode(VariableAccessNode(node.variable_name, []), Token(EQUAL), node.start_node))

      self.comment("Обработка ветви \"иначе\"")
      self.pops("rax", "rbx")
      self.compare("rax", 1, "e")
      self.jump(self.counters["mark"] + 1)
      self.mark()

      self.compile(expression)

      self.counters["mark"] += 1
      self.mark()

    self.leave()

  def compile_WhileNode(self, node: WhileNode):
    self.comment("Начало конструкции \"пока-иначе\"")
    self.counters["loop"] += 1

    self.enter()

    if node.else_case:
      self.comment("Счётчик итераций")
      self.push(0)

    loop_start_mark = self.counters["mark"]

    self.comment("Ветвь \"пока\"")
    self.mark()

    self.compile(node.condition_node)

    self.comment("Переход в конец цикла при невыполнении условия")
    self.pops("rax", "rbx")
    self.compare("rax", 1, "ne", self.counters["loop"], "loop_end_mark")

    self.comment("Тело ветви \"пока\"")
    self.mark()

    self.compile_sequence(node.body_node.elements)

    if node.else_case:
      self.comment("Увеличение счётчика итераций")
      self.pop("rax")
      self.operation("inc", "rax")
      self.push("rax")

    self.comment("Возвращение к началу цикла")
    self.jump(loop_start_mark)
    self.counters["mark"] += 1

    self.comment("Конец цикла \"пока\"")
    self.mark(self.counters["loop"], "loop_end_mark")

    self.replace_code(f"loop_end_mark{self.counters["loop"]}", f"mark{self.counters["mark"]}")
    self.counters["mark"] += 1

    self.counters["loop"] -= 1

    if node.else_case:
      expression, return_null = node.else_case

      self.comment("Переход к ветви \"иначе\", если цикл не было ни одной итерации")
      self.pop("rax")
      self.compare("rax", 0, "e")
      self.jump(self.counters["mark"] + 1)
      self.mark()

      self.compile(expression)

      self.mark()

    self.leave()

  def compile_FunctionDefinitionNode(self, node: FunctionDefinitionNode):
    function_name = node.variable_name.value if node.variable_name else f"!функция{self.counters["lambda"]}"
    compiler = Compiler(function_name)

    function_header = [
      f"section \"{function_name}\" executable",
      f"{function_name}:",
      "enter 0, 0",
    ]

    compiler.comment("Извлечение аргументов")
    for index, argument_name in enumerate(node.argument_names):
      compiler.mov("rax", f"[rbp + 8 * (1 + {len(node.argument_names)} - {index})]")
      compiler.push("rax")

      compiler.compile(VariableAccessNode(None, []))
      compiler.compile(VariableAssignNode(argument_name.variable, [], None))

    compiler.comment("Исполнение тела функции")

    compiler.compile_program(node.body_node)
    compiler.replace_code("mark", ".mark")

    compiler.comment("Завершение функции")

    compiler.lea("rax", "[rsp + 8]")
    compiler.operations(["leave"], ["ret"])

    self.functions[function_name] = function_header + compiler.code

  def compile_CallNode(self, node: CallNode):
    self.enter()

    self.comment("Исполнение аргументов")
    for index, argument in enumerate(node.argument_nodes):
      self.compile(argument)
      self.compile(VariableAssignNode(Token(STRING, f"!{index}"), [], None))

    self.comment("Сохранение аргументов")
    for index in range(len(node.argument_nodes)):
      self.lea("rax", f"[rbp - 8 * {self.variables[f'!{index}']}]")
      self.push("rax")

    self.comment("Вызов функции")
    self.operation("call", node.call_node.variable.value)

    self.mov("r15", "rax")
    self.leave()
    self.push("r15")

    self.compile(VariableAccessNode(None, []))

  def compile_ReturnNode(self, node: ReturnNode):
    self.comment("Возвращение значения из функции")
    self.leave()
    self.compile(node.return_node)
    self.lea("rax", "[rsp + 8]")
    self.operations(["leave"], ["ret"])

  def compile_SkipNode(self, _):
    self.comment("Нод пропуска итерации")
    self.jump(self.counters["loop"], "loop_iteration_mark")

  def compile_BreakNode(self, _):
    self.comment("Нод прерывания итерации")
    self.jump(self.counters["loop"], "loop_end_mark")
