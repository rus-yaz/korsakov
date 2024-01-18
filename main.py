import readline
from sys import argv

from run import run

if __name__ == "__main__":
  program_name, *argv = argv
  mods = {"debug": False}

  file_name = ""
  if "-d" in argv or "--debug" in argv:
    if "-d" in argv:
      argv.remove("-d")
    if "--debug" in argv:
      argv.remove("--debug")

    mods["debug"] = True

  if argv:
    file_name, *argv = argv

  default = "включить \"стандартный_модуль\"\n"

  if file_name:
    code = default
    with open(file_name) as file:
      code += file.read()

    _, error = run(file_name or "<ввод>", code, mods)

    if error:
      print(error)
  else:
    _, error = run("стандартный_модуль", default, mods)
    if error:
      print(error)

    while True:
      code = input(">> ")

      result, error = run(file_name or "<ввод>", code, mods)

      if error:
        print(error)
      elif result:
        result = result.elements

        if len(result) == 1:
          result = result[0]

          if not hasattr(result, "value") or result.value != None:
            print(str(result))
          elif mods["debug"]:
            print(result)
        else:
          if any(map(lambda x: x.value if hasattr(x, "value") else None, result)):
            print(str(result.values()))
          elif mods["debug"]:
            print(result.values())
