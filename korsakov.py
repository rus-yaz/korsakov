import readline
from sys import argv

from run import run, COMMANDLINE_ARGUMENTS

if __name__ == "__main__":
  program_name, *argv = argv

  file_name = ""
  if "-d" in argv or "--debug" in argv:
    if "-d" in argv:
      argv.remove("-d")
    if "--debug" in argv:
      argv.remove("--debug")

    COMMANDLINE_ARGUMENTS["debug"] = True

  if "--nostd" in argv:
    argv.remove("--nostd")
    COMMANDLINE_ARGUMENTS["nostd"] = True

  if "--tokens" in argv:
    argv.remove("--tokens")
    COMMANDLINE_ARGUMENTS["tokens"] = True

  if "--ast" in argv:
    argv.remove("--ast")
    COMMANDLINE_ARGUMENTS["ast"] = True

  if "--context" in argv:
    argv.remove("--context")
    COMMANDLINE_ARGUMENTS["context"] = True

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
