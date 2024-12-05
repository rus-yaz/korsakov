#!/bin/bash

# Директория, в которой находятся файлы .asm
directory="./Ассембли"

# Имя выходного файла
output_file="function.yaml"

# Очистить выходной файл перед записью
> "$output_file"

# Проходимся по всем файлам с расширением .asm, включая вложенные директории
while IFS= read -r -d '' file; do
    items=""

    # Читаем файл построчно
    while IFS= read -r line; do
        # Проверяем, начинается ли строка с 'macro'
        if [[ $line == macro* ]]; then
            # Разбиваем строку по пробелам и берем второй элемент
            second_element=$(echo $line | awk '{print $2}')

            # Добавляем элемент в список
            items+="${items:+, }$second_element"
        fi
    done < "$file"

    # Оставляем только относительный путь к файлу от исходной директории
    relative_path=${file#$directory}

    # Удаляем начальный слеш, если он присутствует
    relative_path=${relative_path#/}

    # Формируем запись в формате YAML
    if [ ! -z "$items" ]; then
        yaml_entry="- file: $relative_path\n  items:\n$(printf "    - %s\n" $items)"

        # Запись в файл
        echo -e "$yaml_entry" >> "$output_file"
    fi
done < <(find "$directory" -type f -name '*.asm' -print0)
