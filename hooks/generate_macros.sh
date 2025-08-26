#!/bin/bash

# Данный скрипт сгенерирован нейросетью

set -e

find_project_root() {
    local current_dir="$PWD"
    while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/.git" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done
    return 1
}

PROJECT_ROOT=$(find_project_root)
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось найти корень проекта (.git директория)"
    exit 1
fi

echo "Корень проекта: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

OUTPUT_FILE="core/generated_macros.asm"

mkdir -p "$(dirname "$OUTPUT_FILE")"

extract_function_name() {
    local line="$1"
    echo "$line" | sed -n 's/.*@function[[:space:]]*\([a-zA-Z_][a-zA-Z0-9_]*\).*/\1/p'
}

extract_param() {
    local line="$1"
    local param_part=$(echo "$line" | sed 's/^[[:space:]]*;[[:space:]]*@param[[:space:]]*//')
    # Извлекаем только имя параметра и значение по умолчанию, убираем описание после дефиса
    echo "$param_part" | sed 's/[[:space:]]*-[[:space:]].*$//' | sed 's/[[:space:]]*$//'
}

generate_macro() {
    local function_name="$1"
    local has_debug="$2"
    shift 2
    local params=("$@")

    local macro_params=""
    local clean_params=""

    for param in "${params[@]}"; do
        if [[ "$param" == *"="* ]]; then
            local param_name=$(echo "$param" | cut -d'=' -f1)
            local param_default=$(echo "$param" | cut -d'=' -f2 | cut -d' ' -f1)
            if [ -n "$macro_params" ]; then
                macro_params="$macro_params, $param"
                clean_params="$clean_params, $param_name"
            else
                macro_params="$param"
                clean_params="$param_name"
            fi
        else
            if [ -n "$macro_params" ]; then
                macro_params="$macro_params, ${param}*"
                clean_params="$clean_params, $param"
            else
                macro_params="${param}*"
                clean_params="$param"
            fi
        fi
    done

    if [ "$has_debug" = "true" ]; then
        cat << EOF
macro $function_name $macro_params {
  debug_start "$function_name"
  enter $clean_params
  call f_$function_name
  return
  debug_end "$function_name"
}
EOF
    else
        cat << EOF
macro $function_name $macro_params {
  enter $clean_params
  call f_$function_name
  return
}
EOF
    fi
}

# Функция для определения, является ли строка началом нового блока документации
is_new_doc_block() {
    local line="$1"
    [[ "$line" =~ ^[[:space:]]*\;[[:space:]]*@(function|example) ]]
}

# Функция для определения, является ли строка продолжением многострочного тега
is_continuation_line() {
    local line="$1"
    # Строка является продолжением, если она:
    # 1. Начинается с ; и содержит только пробелы после ;
    # 2. Или содержит отступы и не является новым тегом
    # НО НЕ является новым тегом документации
    [[ "$line" =~ ^[[:space:]]*\;[[:space:]]*$ ]] || \
    ([[ "$line" =~ ^[[:space:]]*\;[[:space:]]*[^@] ]] && \
     ! [[ "$line" =~ ^[[:space:]]*\;[[:space:]]*@(function|param|return|example|description) ]])
}

process_file() {
    local file_path="$1"
    local in_function_block=false
    local current_function=""
    local current_params=()
    local current_has_debug=false
    local found_functions=false
    local in_multiline_tag=false

    while IFS= read -r line; do
        # Проверяем, является ли это началом нового блока документации
        if is_new_doc_block "$line"; then
            # Если мы были в блоке функции, завершаем его
            if [ "$in_function_block" = true ] && [ -n "$current_function" ]; then
                generate_macro "$current_function" "$current_has_debug" "${current_params[@]}"
                echo
                found_functions=true
            fi

            # Если это @function, начинаем новый блок
            if [[ "$line" =~ ^[[:space:]]*\;[[:space:]]*@function ]]; then
                in_function_block=true
                current_function=$(extract_function_name "$line")
                current_params=()
                current_has_debug=false
                in_multiline_tag=false
            else
                # Это другой тег документации, не начинаем блок функции
                in_function_block=false
                current_function=""
                current_params=()
                current_has_debug=false
                in_multiline_tag=false
            fi

        elif [ "$in_function_block" = true ]; then
            # Обрабатываем параметры
            if [[ "$line" =~ ^[[:space:]]*\;[[:space:]]*@param ]]; then
                local param=$(extract_param "$line")
                if [ -n "$param" ]; then
                    current_params+=("$param")
                fi
                in_multiline_tag=false
            # Проверяем наличие тега @debug
            elif [[ "$line" =~ ^[[:space:]]*\;[[:space:]]*@debug ]]; then
                current_has_debug=true
                in_multiline_tag=false
            # Проверяем, является ли это продолжением многострочного тега
            elif is_continuation_line "$line"; then
                in_multiline_tag=true
                continue
            # Если это пустая строка и мы не в многострочном теге, завершаем блок
            elif [[ "$line" =~ ^[[:space:]]*$ ]] && [ "$in_multiline_tag" = false ]; then
                if [ -n "$current_function" ]; then
                    generate_macro "$current_function" "$current_has_debug" "${current_params[@]}"
                    echo
                    found_functions=true
                fi
                in_function_block=false
                current_function=""
                current_params=()
                current_has_debug=false
                in_multiline_tag=false
            # Если это не тег документации и не продолжение, завершаем блок
            elif ! [[ "$line" =~ ^[[:space:]]*\; ]] && [ "$in_multiline_tag" = false ]; then
                if [ -n "$current_function" ]; then
                    generate_macro "$current_function" "$current_has_debug" "${current_params[@]}"
                    echo
                    found_functions=true
                fi
                in_function_block=false
                current_function=""
                current_params=()
                current_has_debug=false
                in_multiline_tag=false
            fi
        fi
    done < "$file_path"

    # Обрабатываем последний блок, если он есть
    if [ "$in_function_block" = true ] && [ -n "$current_function" ]; then
        generate_macro "$current_function" "$current_has_debug" "${current_params[@]}"
        echo
        found_functions=true
    fi

    if [ "$found_functions" = true ]; then
      echo "- $file_path" >&2
    fi
}

find_asm_files() {
    find . -name "*.asm" -type f | grep -v ".git" | sort
}

echo "Генерация макросов по строкам документации"
echo

cat > "$OUTPUT_FILE" << EOF
; Копирайт © 2025 ООО «РУС.ЯЗ»
; SPDX-License-Identifier: GPLv3+ ИЛИ прориетарная
;
; Данный файл автоматически сгенерирован из строк документации. Не редактируйте его вручную
EOF

total_macros=0
for asm_file in $(find_asm_files); do
    if [ "$asm_file" = "$OUTPUT_FILE" ]; then
        continue
    fi

    macros=$(process_file "$asm_file")

    if [ -n "$macros" ]; then
      echo >> "$OUTPUT_FILE"
      echo "; $asm_file" >> "$OUTPUT_FILE"
      echo >> "$OUTPUT_FILE"
      echo "$macros" >> "$OUTPUT_FILE"
    fi
done

total_macros=$(grep -c "^macro " "$OUTPUT_FILE" 2>/dev/null || echo "0")

echo
echo "Макросов: $total_macros"
echo "Файл с макросами: $OUTPUT_FILE"
