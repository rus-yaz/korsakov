from errors_list import *
from tokens_list import *


class Tokenizer:
  def __init__(self, file_name, text: str) -> None:
    self.file_name = file_name
    self.text = text
    self.reset()
    self.advance()

  def reset(self) -> None:
    self.position = Position(-1, 0, 0, self.file_name, self.text)
    self.character = None

  def advance(self) -> None:
    self.position.advance(self.character)
    self.character = self.text[self.position.index] if self.position.index < len(self.text) else None

  def tokenize(self) -> [[Token], None | Error]:
    self.tokens: list[Token] = []

    while self.character != None:
      token: Token = None
      previous_token: Token = self.tokens[-1] if self.tokens else None
      position_start = self.position.copy()

      if self.character.isdigit():
        self.tokens += [self.make_number()]
        continue
      elif self.character.isalpha() or self.character == "_":
        self.tokens += [self.make_identifier()]
        continue
      elif self.character == "\"":
        string, error = self.make_string()
        if error:
          return None, error

        self.tokens += [string]
        continue

      match self.character:
        case " " | "\t": token = None if not self.tokens or self.tokens[-1].check_type(SPACE, NEWLINE) else SPACE
        case ";" | "\n": token = None if not self.tokens or self.tokens[-1].check_type(NEWLINE) else NEWLINE

        case ":": token = COLON
        case ",": token = COMMA
        case ".": token = POINT

        case "!":
          token = EXCLAMATION_MARK
          if self.tokens and previous_token.check_type(EXCLAMATION_MARK):
            self.tokens.pop()

            while self.character not in ["\n", None]:
              self.advance()

            token = None if not self.tokens or self.tokens[-1].check_type(NEWLINE, SPACE) else NEWLINE
        case "=":
          token = ASSIGN
          if self.tokens:
            if previous_token.check_type(EXCLAMATION_MARK):
              token = NOT_EQUAL
            elif previous_token.check_type(ASSIGN):
              token = EQUAL
            elif previous_token.check_type(MORE):
              token = MORE_OR_EQUAL
            elif previous_token.check_type(LESS):
              token = LESS_OR_EQUAL

            elif previous_token.check_type(EQUAL):
              token = END_OF_CONSTRUCTION

          if token != ASSIGN:
            position_start = previous_token.position_start
            self.tokens.pop()

        case "+":
          token = ADDITION
          if self.tokens and previous_token.check_type(ADDITION):
            token = None
            self.tokens.pop()
            identifier = None
            if self.tokens and self.tokens[-1].check_type(IDENTIFIER):
              identifier = self.tokens.pop()

            self.tokens += [Token(INCREMENT, not identifier, position_start, self.position.copy()), identifier]
            position_start = previous_token.position_start
        case "-":
          token = SUBTRACTION
          if self.tokens and previous_token.check_type(SUBTRACTION):
            self.tokens.pop()
            self.advance()

            if self.character != "-":
              identifier = None
              if self.tokens and self.tokens[-1].check_type(IDENTIFIER):
                identifier = self.tokens.pop()

              self.tokens += [Token(DECREMENT, not identifier, position_start, self.position.copy()), identifier]
              position_start = previous_token.position_start
              continue

            token = END_OF_CONSTRUCTION
        case "*":
          token = MULTIPLICATION
          if self.tokens and previous_token.check_type(MULTIPLICATION):
            token = POWER
            position_start = previous_token.position_start
            self.tokens.pop()
        case "/":
          token = DIVISION
          if self.tokens:
            if previous_token.check_type(BACK_SLASH):
              token = LESS
            elif previous_token.check_type(DIVISION):
              token = ROOT

          if token != DIVISION:
            position_start = previous_token.position_start
            self.tokens.pop()

        case "\\":
          token = BACK_SLASH
          if self.tokens and previous_token.check_type(DIVISION):
            token = MORE
            position_start = previous_token.position_start
            self.tokens.pop()

        case "(":
          token = OPEN_PAREN
          if self.tokens and previous_token.check_type(PERCENT):
            token = OPEN_LIST_PAREN
            position_start = previous_token.position_start
            self.tokens.pop()
        case ")": token = CLOSED_PAREN

        case "%":
          token = PERCENT
          if self.tokens:
            if previous_token.check_type(CLOSED_PAREN):
              token = CLOSED_LIST_PAREN
            elif len(self.tokens) > 1 and [self.tokens[-1].type, self.tokens[-2].type] == [PERCENT, PERCENT]:
              token = END_OF_CONSTRUCTION
              self.tokens.pop()

          if token != PERCENT:
            position_start = previous_token.position_start
            self.tokens.pop()

        case _:
          position_start = self.position.copy()
          char = self.character
          self.advance()
          return [], IllegalCharacterError(position_start, self.position.copy(), f"`{char}`")

      self.tokens += [Token(token, None, position_start, self.position.copy())] if token else []
      self.advance()

    if self.tokens:
      self.tokens += [Token(END_OF_FILE, None, self.position.copy())]
    return list(filter(lambda token: token and not token.check_type(SPACE), self.tokens)), None

  def make_number(self):
    number = ""
    integer = (
      self.tokens and self.tokens[-1].check_type(POINT) or
      len(self.tokens) > 2 and self.tokens[-2].check_type(POINT) and self.tokens[-1].check_type(SUBTRACTION)
    )
    float_point = integer
    position_start = self.position.copy()
    position_end = self.position.copy()

    while self.character and (self.character.isdigit() or self.character in "_."):
      if self.character == "_":
        self.advance()

      if self.character == ".":
        if float_point:
          break

        float_point = True

      number += self.character
      position_end = self.position.copy()
      self.advance()

    return Token(FLOAT, float(number), position_start, position_end) if float_point and not integer else Token(INTEGER, int(number), position_start, position_end)

  def make_identifier(self):
    identifier = ""
    position_start = self.position.copy()
    position_end = self.position.copy()

    while self.character != None and (self.character.isalnum() or self.character == "_"):
      # Меня заставили
      if self.character == "ё":
        self.character = "е"

      identifier += self.character
      position_end = self.position.copy()
      self.advance()

    return Token(KEYWORD if identifier in KEYWORDS else IDENTIFIER, identifier, position_start, position_end)

  def make_string(self):
    string = ""
    position_start = self.position.copy()
    escape_sequence = False
    self.advance()

    while self.character != None and (self.character != "\"" or escape_sequence):
      if escape_sequence:
        string += ESCAPE_SEQUENCES.get(self.character, self.character)
        escape_sequence = False
      elif self.character == "\\":
        escape_sequence = True
      else:
        string += self.character

      self.advance()

    if self.character != "\"":
      return None, InvalidSyntaxError(self.position.copy(), self.position.copy(), "Ожидалось `\"`")

    self.advance()

    return Token(STRING, string, position_start, self.position.copy()), None
