import os

# Функция для поиска макросов в defines.asm
def find_macros_in_defines(file_path):
    macros = []

    with open(file_path, 'r') as file:
        for line in file:
            if line.startswith('macro '):
                parts = line.split()
                macro_name = parts[1]
                macros.append(macro_name)

    return macros

# Функция для поиска использования макросов в asm-файлах
def search_for_macro_usage(macros, root_dir):
    used_macros = set()

    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if not filename.endswith('.asm'):
                continue

            full_path = os.path.join(dirpath, filename)
            with open(full_path, 'r') as file:
                content = file.read().lower()  # Приводим к нижнему регистру для поиска

                for macro in macros:
                    if f'f_{macro.lower()}' in content:
                        used_macros.add(macro)

    unused_macros = [macro for macro in macros if macro not in used_macros]
    return unused_macros

# Основной блок программы
if __name__ == "__main__":
    root_directory = 'Ассембли'  # Текущая директория
    defines_file_path = root_directory + '/lib/defines.asm'

    macros = find_macros_in_defines(defines_file_path)
    unused_macros = search_for_macro_usage(macros, root_directory)

    if len(unused_macros) == 0:
        print("Нет неиспользуемых макросов")
    else:
        print(f"Найдены неиспользуемые макросы: {', '.join(unused_macros)}")
        exit(1)
