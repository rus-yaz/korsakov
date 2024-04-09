import readline
from sys import argv

from run import COMMANDLINE_ARGUMENTS, run

if __name__ == "__main__":
  program_name, *argv = argv

  file_name = ""
  for flag in COMMANDLINE_ARGUMENTS.keys():
    if "--" + flag in argv:
      argv.remove("--" + flag)
      COMMANDLINE_ARGUMENTS[flag] = True

  if argv:
    file_name, *argv = argv

  default = "включить \"стандартный_модуль\"\n" if not COMMANDLINE_ARGUMENTS["nostd"] else ""

  if file_name:
    code = default
    with open(file_name) as file:
      code += file.read()

    _, error = run(file_name, code)

    if error:
      print(error)
  else:
    _, error = run("стандартный_модуль", default)
    if error:
      print(error)

    while True:
      code = input(">> ")
      if not code.strip() or code.startswith("!!"):
        continue

      result, error = run("<ввод>", code)

      if error:
        print(error)
      elif result:
        result = result.value

        if len(result) == 1:
          result = result[0]

          if not hasattr(result, "value") or result.value != None:
            print(str(result))
          elif COMMANDLINE_ARGUMENTS["debug"]:
            print(repr(result))
        else:
          if any(map(lambda x: x.value if hasattr(x, "value") else None, result)):
            print(str(result))
          elif COMMANDLINE_ARGUMENTS["debug"]:
            print(repr(result))
