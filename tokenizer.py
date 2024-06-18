from typing import Optional

from loggers import Error, IllegalCharacterError, InvalidSyntaxError, Position
from tokens import (ADDITION, ASSIGN, BACK_SLASH, CLOSED_LIST_PAREN,
                    CLOSED_PAREN, COLON, DECREMENT, DIVISION,
                    END_OF_CONSTRUCTION, END_OF_FILE, EQUAL, ESCAPE_SEQUENCES,
                    EXCLAMATION_MARK, FLOAT, IDENTIFIER, INCREMENT, INTEGER,
                    KEYWORD, KEYWORDS, LESS, LESS_OR_EQUAL, MORE,
                    MORE_OR_EQUAL, MULTIPLICATION, NEWLINE, NOT_EQUAL,
                    OPEN_LIST_PAREN, OPEN_PAREN, PERCENT, POINT, POWER, ROOT,
                    SEMICOLON, SPACE, STRING, SUBTRACTION, Token)


class Tokenizer:
  def __init__(self, file_name: str, text: str):
    self.file_name = file_name
    self.text = text
    self.tokens: list[Token] = []
    self.reset()
    self.next()

  def reset(self):
    self.position = Position(-1, 0, 0, self.file_name, self.text)
    self.character: Optional[str] = None

  def next(self):
    self.position.next(self.character)
    self.character = self.text[self.position.index] if self.position.index < len(self.text) else None

  def tokenize(self) -> tuple[Optional[list[Token]], Optional[Error]]:
    while self.character is not None:
      token_type: Optional[str] = None
      previous_token: Optional[Token] = self.tokens[-1] if self.tokens else None
      position_start = self.position.copy()

      if self.character.isalpha() or self.character == "_":
        self.tokens += [self.make_identifier()]
        continue

      if self.character.isdigit():
        number, error = self.make_number()
        if not number or error:
          return None, error

        self.tokens += [number]
        continue

      if self.character == "\"":
        string, error = self.make_string()
        if not string or error:
          return None, error

        self.tokens += [string]
        continue

      match self.character:
        case " " | "\t": token_type = None if not self.tokens or self.tokens[-1].check_type(SPACE, NEWLINE) else SPACE
        case "\n": token_type = None if not self.tokens or self.tokens[-1].check_type(NEWLINE) else NEWLINE

        case ":": token_type = COLON
        case ";": token_type = SEMICOLON
        case ".": token_type = POINT

        case "!":
          token_type = EXCLAMATION_MARK
          if previous_token and previous_token.check_type(EXCLAMATION_MARK):
            self.tokens.pop()

            while self.character not in ["\n", None]:
              self.next()

            token_type = NEWLINE if previous_token and not self.tokens[-1].check_type(NEWLINE) else None
        case "=":
          token_type = ASSIGN
          if previous_token:
            if previous_token.check_type(EXCLAMATION_MARK):
              token_type = NOT_EQUAL
            elif previous_token.check_type(ASSIGN):
              token_type = EQUAL
            elif previous_token.check_type(MORE):
              token_type = MORE_OR_EQUAL
            elif previous_token.check_type(LESS):
              token_type = LESS_OR_EQUAL

            elif previous_token.check_type(EQUAL):
              token_type = END_OF_CONSTRUCTION

            if token_type != ASSIGN:
              position_start = previous_token.position_start
              self.tokens.pop()

        case "+":
          token_type = ADDITION
          if previous_token and previous_token.check_type(ADDITION):
            token_type = None
            self.tokens.pop()
            identifier = None
            if previous_token and self.tokens[-1].check_type(IDENTIFIER):
              identifier = self.tokens.pop()

            self.tokens += [Token(INCREMENT, not identifier, position_start, self.position.copy())]
            if identifier:
              self.tokens += [identifier]

            position_start = previous_token.position_start
        case "-":
          token_type = SUBTRACTION
          if previous_token and previous_token.check_type(SUBTRACTION):
            self.tokens.pop()
            self.next()

            if self.character != "-":
              identifier = None
              if previous_token and self.tokens[-1].check_type(IDENTIFIER):
                identifier = self.tokens.pop()

              self.tokens += [Token(DECREMENT, not identifier, position_start, self.position.copy()), identifier]
              position_start = previous_token.position_start
              continue

            token_type = END_OF_CONSTRUCTION
        case "*":
          token_type = MULTIPLICATION
          if previous_token:
            if previous_token.check_type(MULTIPLICATION):
              token_type = POWER
              position_start = previous_token.position_start
              self.tokens.pop()
            if previous_token.check_type(EXCLAMATION_MARK):
              self.tokens.pop()

              while self.character:
                if self.character == "*":
                  self.next()
                  if self.character == "!":
                    break

                  continue

                self.next()

              token_type = NEWLINE if previous_token and not self.tokens[-1].check_type(NEWLINE) else None
        case "/":
          token_type = DIVISION
          if previous_token:
            if previous_token.check_type(BACK_SLASH):
              token_type = LESS
            elif previous_token.check_type(DIVISION):
              token_type = ROOT

            if token_type != DIVISION:
              position_start = previous_token.position_start
              self.tokens.pop()

        case "\\":
          token_type = BACK_SLASH
          if previous_token and previous_token.check_type(DIVISION):
            token_type = MORE
            position_start = previous_token.position_start
            self.tokens.pop()

        case "(":
          token_type = OPEN_PAREN
          if previous_token and previous_token.check_type(PERCENT):
            token_type = OPEN_LIST_PAREN
            position_start = previous_token.position_start
            self.tokens.pop()
        case ")":
          token_type = CLOSED_PAREN

        case "%":
          token_type = PERCENT
          if previous_token:
            if previous_token.check_type(CLOSED_PAREN):
              token_type = CLOSED_LIST_PAREN
            elif len(self.tokens) > 1 and [self.tokens[-1].token_type, self.tokens[-2].token_type] == [PERCENT, PERCENT]:
              token_type = END_OF_CONSTRUCTION
              self.tokens.pop()

            if token_type != PERCENT:
              position_start = previous_token.position_start
              self.tokens.pop()

        case _:
          position_start = self.position.copy()
          char = self.character
          self.next()
          return [], IllegalCharacterError(position_start, self.position.copy(), f"`{char}`")

      self.tokens += [Token(token_type, None, position_start, self.position.copy())] if token_type else []
      self.next()

    if self.tokens:
      self.tokens += [Token(END_OF_FILE, None, self.position.copy())]

    tokens = []
    for token in self.tokens:
      if token and not token.check_type(SPACE):
        tokens += [token]

    return tokens, None

  def make_number(self):
    number = ""
    integer = (
      self.tokens and self.tokens[-1].check_type(POINT) or
      len(self.tokens) > 2 and self.tokens[-2].check_type(POINT) and self.tokens[-1].check_type(SUBTRACTION)
    )
    float_point = integer
    position_start = self.position.copy()
    position_end = self.position.copy()

    while self.character and (self.character.isdigit() or self.character in "_,"):
      if self.character == "_":
        self.next()

      if self.character == ",":
        if float_point:
          break

        float_point = True

      number += self.character
      position_end = self.position.copy()
      self.next()

    if self.character is not None and self.character.isalpha():
      return None, InvalidSyntaxError(self.position.copy(), self.position.copy(), "Ожидалось число")

    if float_point and not integer:
      return Token(FLOAT, float(number.replace(",", ".")), position_start, position_end), None

    return Token(INTEGER, int(number), position_start, position_end), None

  def make_identifier(self):
    identifier = ""
    position_start = self.position.copy()
    position_end = self.position.copy()

    while self.character is not None and (self.character.isalnum() or self.character == "_"):
      identifier += self.character
      position_end = self.position.copy()
      self.next()

    return Token(KEYWORD if identifier in KEYWORDS else IDENTIFIER, identifier, position_start, position_end)

  def make_string(self) -> tuple[Optional[Token], Optional[Error]]:
    string = ""
    position_start = self.position.copy()
    escape_sequence = False
    self.next()

    while self.character is not None and (self.character != "\"" or escape_sequence):
      if escape_sequence:
        string += ESCAPE_SEQUENCES.get(self.character, self.character)
        escape_sequence = False
      elif self.character == "\\":
        escape_sequence = True
      else:
        string += self.character

      self.next()

    if self.character != "\"":
      return None, InvalidSyntaxError(self.position.copy(), self.position.copy(), "Ожидалось `\"`")

    self.next()

    return Token(STRING, string, position_start, self.position.copy()), None
