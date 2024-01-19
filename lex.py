from errors_list import *
from tokens_list import *


class Lexer:
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

  def make_tokens(self) -> [[Token], None | Error]:
    tokens: list[Token] = []

    while self.character != None:
      token: Token = None
      previous_token: Token = tokens[-1] if tokens else None
      position_start = self.position.copy()

      if self.character.isdigit():
        tokens += [self.make_number()]
        continue
      elif self.character.isalpha() or self.character == "_":
        tokens += [self.make_identifier()]
        continue
      elif self.character == "\"":
        tokens += [self.make_string()]
        continue

      match self.character:
        case " " | "\t": token = None if tokens and previous_token.type == SPACE else SPACE
        case ";" | "\n": token = NEWLINE

        case "=":
          token = ASSIGN
          if tokens:
            if previous_token.type == EXCLAMATION_MARK:
              token = NOT_EQUAL
            elif previous_token.type == ASSIGN:
              token = EQUAL
            elif previous_token.type == MORE:
              token = MORE_OR_EQUAL
            elif previous_token.type == LESS:
              token = LESS_OR_EQUAL

            elif previous_token.type == EQUAL:
              token = END_OF_CONSTRUCTION

            elif previous_token.type in [ADDITION, SUBSTRACION, MULTIPLICATION, DIVISION, POWER, ROOT]:
              tokens.pop()
              while tokens[-1].type == SPACE:
                tokens.pop()
              tokens += [Token(ASSIGN, None, position_start, self.position.copy()), tokens[-1]]
              token = previous_token.type

          if token != ASSIGN:
            position_start = previous_token.position_start
            if token not in [ADDITION, SUBSTRACION, MULTIPLICATION, DIVISION, POWER, ROOT]:
              tokens.pop()

        case "!":
          token = EXCLAMATION_MARK
          if tokens and previous_token.type == EXCLAMATION_MARK:
            token = None
            tokens.pop()
            text = ""
            self.advance()

            while self.character not in ["\n", None]:
              text += self.character
              self.advance()

        case "+":
          token = ADDITION
          if tokens and previous_token.type == ADDITION:
            token = None
            tokens.pop()
            identifier = None
            if tokens and tokens[-1].type == IDENTIFIER:
              identifier = tokens.pop()

            tokens += [Token(INCREMENT, not identifier, position_start, self.position.copy()), identifier]
            position_start = previous_token.position_start
        case "-":
          token = SUBSTRACION
          if tokens and previous_token.type == SUBSTRACION:
            tokens.pop()
            self.advance()

            if self.character != "-":
              identifier = None
              if tokens and tokens[-1].type == IDENTIFIER:
                identifier = tokens.pop()

              tokens += [Token(DECREMENT, not identifier, position_start, self.position.copy()), identifier]
              position_start = previous_token.position_start
              continue

            token = END_OF_CONSTRUCTION
        case "*":
          token = MULTIPLICATION
          if tokens and previous_token.type == MULTIPLICATION:
            token = POWER
            position_start = previous_token.position_start
            tokens.pop()
        case "/":
          token = DIVISION
          if tokens:
            if previous_token.type == BACK_SLASH:
              token = LESS
            elif previous_token.type == DIVISION:
              token = ROOT

          if token != DIVISION:
            position_start = previous_token.position_start
            tokens.pop()

        case "\\":
          token = BACK_SLASH
          if tokens and previous_token.type == DIVISION:
            token = MORE
            position_start = previous_token.position_start
            tokens.pop()

        case "(":
          token = OPEN_PAREN
          if tokens and previous_token.type == PERCENT:
            token = OPEN_LIST_PAREN
            position_start = previous_token.position_start
            tokens.pop()
        case ")": token = CLOSED_PAREN
        case "%":
          token = PERCENT
          if tokens:
            if previous_token.type == CLOSED_PAREN:
              token = CLOSED_LIST_PAREN
            elif len(tokens) > 1 and [tokens[-1].type, tokens[-2].type] == [PERCENT, PERCENT]:
              token = END_OF_CONSTRUCTION
              tokens.pop()

          if token != PERCENT:
            position_start = previous_token.position_start
            tokens.pop()

        case ",": token = COMMA

        case _:
          position_start = self.position.copy()
          char = self.character
          self.advance()
          return [], IllegalCharacterError(position_start, self.position, f"`{char}`")

      tokens += [Token(token, None, position_start, self.position.copy())] if token else []
      self.advance()

    tokens += [Token(END_OF_FILE, position_start=self.position.copy())]
    return list(filter(lambda token: token and token.type != SPACE, tokens)), None

  def make_number(self):
    number = ""
    float_point = False
    position_start = self.position.copy()
    if self.character == "-":
      number += "-"
      self.advance()

    while self.character and (self.character.isdigit() or self.character in "_."):
      if self.character == "_":
        self.advance()

      if self.character == ".":
        if float_point:
          break

        float_point = True

      number += self.character
      self.advance()

    return Token(FLOAT, float(number), position_start, self.position.copy()) if float_point else Token(INTEGER, int(number), position_start, self.position.copy())

  def make_identifier(self):
    identifier = ""
    position_start = self.position.copy()
    position_end = position_start

    while self.character != None and (self.character.isalnum() or self.character in "_."):
      position_end = self.position.copy()

      # Меня заставили
      if self.character == "ё":
        self.character = "е"

      identifier += self.character
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

    if self.character == "\"":
      self.advance()

    return Token(STRING, string, position_start, self.position.copy())
