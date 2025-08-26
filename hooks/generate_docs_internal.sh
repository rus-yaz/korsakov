#!/bin/bash

# Скрипт для генерации документации из исходного кода
# Использование: ./generate_docs_internal.sh <директория_документации> [директория_поиска]

set -e

# Проверка аргументов
if [ $# -lt 1 ]; then
    echo "Использование: $0 <директория_документации> [директория_поиска]"
    echo "Пример: $0 docs ."
    exit 1
fi

DOCS_ROOT="$1"
SOURCE_DIR="${2:-.}"

# Создание корневой директории документации
mkdir -p "$DOCS_ROOT"

# Функция для очистки имени файла/функции для использования в путях
clean_name() {
    echo "$1" | sed 's/[^a-zA-Z0-9а-яА-Я_]/_/g' | sed 's/^_*//' | sed 's/_*$//'
}

# Функция для создания документации функции
create_function_doc() {
    local file_path="$1"
    local function_name="$2"
    local description="$3"
    local params="$4"
    local return_value="$5"
    local example="$6"
    local asm_snippet="$7"

    # Проверка обязательных параметров
    if [ -z "$function_name" ]; then
        echo "Ошибка: пустое имя функции в файле $file_path"
        return 1
    fi

    # Создание структуры директорий с сохранением относительного пути
    local relative_path="${file_path#$SOURCE_DIR/}"
    local dir_path=$(dirname "$relative_path")
    local file_name=$(basename "$file_path" .asm)
    local clean_file_name=$(clean_name "$file_name")
    local clean_function_name=$(clean_name "$function_name")

    # Создаем полный путь с сохранением структуры директорий
    local function_dir="$DOCS_ROOT"
    if [ "$dir_path" != "." ]; then
        function_dir="$function_dir/$dir_path"
    fi
    function_dir="$function_dir/$clean_file_name/$clean_function_name"
    mkdir -p "$function_dir"

    # Обработка пустых значений
    local safe_description=$(echo -e "${description:-Нет описания}")
    local safe_params=$(echo -e "${params:-Нет параметров}")
    local safe_return=$(echo -e "${return_value:-Нет возвращаемого значения}")
    local safe_example=$(echo -e "${example:-Нет примеров}")
    local safe_asm=$(echo -e "${asm_snippet:-Нет ASM snippet}")

    # Создание index.md для функции
    cat > "$function_dir/index.md" << EOF
# \`$function_name\`

$safe_description

## Параметры

\`\`\`asm
$safe_asm
\`\`\`

$safe_params

## Возвращаемое значение

$safe_return

## Примеры

\`\`\`asm
$safe_example
\`\`\`
EOF
}

# Функция для обработки одного файла
process_file() {
    local file_path="$1"
    local relative_path="${file_path#$SOURCE_DIR/}"

    echo "Обработка файла: $relative_path"

    # Временные файлы для хранения данных
    local temp_file=$(mktemp)
    local current_function=""
    local current_description=""
    local current_params=""
    local current_return=""
    local current_example=""
    local current_param_names=""
    local current_function_name=""
    local in_function_doc=false
    local in_description=false
    local in_params=false
    local in_return=false
    local in_example=false

    # Читаем файл построчно
    while IFS= read -r line; do
        # Поиск начала документации функции
        if echo "$line" | grep -q "^[[:space:]]*;[[:space:]]*@function[[:space:]]"; then
            # Сохраняем предыдущую функцию, если есть
            if [ -n "$current_function" ]; then
                # Формируем ASM snippet
                local asm_snippet=""
                if [ -n "$current_function_name" ]; then
                    if [ -n "$current_param_names" ]; then
                        asm_snippet="macro $current_function_name $current_param_names"
                    else
                        asm_snippet="macro $current_function_name"
                    fi
                fi

                # Создаем документацию
                create_function_doc "$file_path" "$current_function" "$current_description" "$current_params" "$current_return" "$current_example" "$asm_snippet"
            fi

            # Извлекаем имя функции
            current_function=$(echo "$line" | sed 's/^[[:space:]]*;[[:space:]]*@function[[:space:]]*//')
            current_description=""
            current_params=""
            current_return=""
            current_example=""
            current_param_names=""
            current_function_name=""
            in_function_doc=true
            in_description=false
            in_params=false
            in_return=false
            in_example=false
            continue
        fi

        # Поиск function_definition
        if echo "$line" | grep -q "^[[:space:]]*_function[[:space:]]"; then
            if [ "$in_function_doc" = true ]; then
                # Извлекаем имя функции из _function
                local func_name=$(echo "$line" | sed 's/^[[:space:]]*_function[[:space:]]*//' | sed 's/[[:space:]]*,.*$//')
                if [ "$func_name" = "$current_function" ]; then
                    current_function_name="$func_name"
                fi
                in_function_doc=false
            fi
            continue
        fi

        # Обработка тегов документации
        if [ "$in_function_doc" = true ]; then
            if echo "$line" | grep -q "^[[:space:]]*;[[:space:]]*@description"; then
                current_description=$(echo "$line" | sed 's/^[[:space:]]*;[[:space:]]*@description[[:space:]]*//')
                in_description=true
                in_params=false
                in_return=false
                in_example=false
            elif echo "$line" | grep -q "^[[:space:]]*;[[:space:]]*@param"; then
                local param_line=$(echo "$line" | sed 's/^[[:space:]]*;[[:space:]]*@param[[:space:]]*//' | sed 's/\([^ ]*\)\(.*\)/`\1`\2/')

                # Извлекаем название параметра (до первого пробела или дефиса)
                local param_name=$(echo "$param_line" | sed 's/[[:space:]]*-.*$//' | sed 's/[[:space:]]*=.*$//' | sed 's/`//g')

                # Добавляем название параметра к списку
                if [ -n "$current_param_names" ]; then
                    current_param_names="$current_param_names, $param_name"
                else
                    current_param_names="$param_name"
                fi

                if [ -n "$current_params" ]; then
                    current_params="$current_params\n- $param_line"
                else
                    current_params="- $param_line"
                fi
                in_description=false
                in_params=true
                in_return=false
                in_example=false
            elif echo "$line" | grep -q "^[[:space:]]*;[[:space:]]*@return"; then
                current_return=$(echo "$line" | sed 's/^[[:space:]]*;[[:space:]]*@return[[:space:]]*//')
                in_description=false
                in_params=false
                in_return=true
                in_example=false
            elif echo "$line" | grep -q "^[[:space:]]*;[[:space:]]*@example"; then
                current_example=$(echo "$line" | sed 's/^[[:space:]]*;[[:space:]]*@example[[:space:]]*//')
                in_description=false
                in_params=false
                in_return=false
                in_example=true
            elif echo "$line" | grep -q "^[[:space:]]*;[[:space:]]*@.*"; then
                continue
            elif echo "$line" | grep -q "^[[:space:]]*;[[:space:]]*$"; then
                if [ "$in_description" = true ] || [ "$in_params" = true ] || [ "$in_return" = true ] || [ "$in_example" = true ]; then
                    # Пустая строка в комментарии - добавляем перенос строки
                    if [ "$in_description" = true ]; then
                        current_description="$current_description\n"
                    elif [ "$in_params" = true ]; then
                        current_params="$current_params\n"
                    elif [ "$in_return" = true ]; then
                        current_return="$current_return\n"
                    elif [ "$in_example" = true ]; then
                        current_example="$current_example\n"
                    fi
                fi
            elif echo "$line" | grep -q "^[[:space:]]*;[[:space:]]*[^@]"; then
                if [ "$in_description" = true ] || [ "$in_params" = true ] || [ "$in_return" = true ] || [ "$in_example" = true ]; then
                    # Продолжение многострочного содержимого
                    local content=$(echo "$line" | sed 's/^[[:space:]]*;[[:space:]]*//')
                    if [ "$in_description" = true ]; then
                        if [ -n "$current_description" ]; then
                            current_description="$current_description\n$content"
                        else
                            current_description="$content"
                        fi
                    elif [ "$in_params" = true ]; then
                        if [ -n "$current_params" ]; then
                            current_params="$current_params\n$content"
                        else
                            current_params="$content"
                        fi
                    elif [ "$in_return" = true ]; then
                        if [ -n "$current_return" ]; then
                            current_return="$current_return\n$content"
                        else
                            current_return="$content"
                        fi
                    elif [ "$in_example" = true ]; then
                        if [ -n "$current_example" ]; then
                            current_example="$current_example\n$content"
                        else
                            current_example="$content"
                        fi
                    fi
                fi
            elif ! echo "$line" | grep -q "^[[:space:]]*;"; then
                # Не комментарий - заканчиваем текущий блок
                in_description=false
                in_params=false
                in_return=false
                in_example=false
            fi
        fi
    done < "$file_path"

    # Обрабатываем последнюю функцию
    if [ -n "$current_function" ]; then
        # Формируем ASM snippet
        local asm_snippet=""
        if [ -n "$current_function_name" ]; then
            if [ -n "$current_param_names" ]; then
                asm_snippet="macro $current_function_name $current_param_names"
            else
                asm_snippet="macro $current_function_name"
            fi
        fi

        # Создаем документацию
        create_function_doc "$file_path" "$current_function" "$current_description" "$current_params" "$current_return" "$current_example" "$asm_snippet"
    fi

    rm -f "$temp_file"
}

# Функция для создания индексного файла для файла с функциями
create_file_index() {
    local dir="$1"
    local title="$2"

    cat > "$dir/index.md" << EOF
# $title

Документация по функциям в файле.

## Функции

EOF

    # Поиск всех поддиректорий с функциями
    if [ -d "$dir" ]; then
        for func_dir in "$dir"/*/; do
            if [ -d "$func_dir" ]; then
                local func_name=$(basename "$func_dir")
                echo "- [$func_name]($func_name/)" >> "$dir/index.md"
            fi
        done
    fi
}

# Функция для создания индексного файла для директории
create_directory_index() {
    local dir="$1"
    local title="$2"

    cat > "$dir/index.md" << EOF
# $title

Документация по модулям и файлам.

## Содержимое

EOF

    # Поиск всех поддиректорий
    if [ -d "$dir" ]; then
        # Добавляем ссылки на поддиректории
        for subdir in "$dir"/*/; do
            if [ -d "$subdir" ]; then
                local subdir_name=$(basename "$subdir")
                echo "- [$subdir_name]($subdir_name/)" >> "$dir/index.md"
            fi
        done
    fi
}

# Функция для создания всех индексных файлов
create_all_indexes() {
    echo "Создание индексных файлов..."

    # Создаем временный файл для отслеживания созданных директорий
    temp_dirs=$(mktemp)

    # Находим все директории с функциями и создаем индексные файлы для файлов
    find "$DOCS_ROOT" -type d -name "*" | while read -r dir; do
        # Пропускаем корневую директорию
        if [ "$dir" = "$DOCS_ROOT" ]; then
            continue
        fi

        # Проверяем, есть ли в директории файлы index.md (функции)
        if [ -f "$dir/index.md" ]; then
            # Это директория с функциями, создаем индексный файл для файла
            file_dir=$(dirname "$dir")
            file_name=$(basename "$file_dir")
            echo "$file_dir" >> "$temp_dirs"
        fi
    done

    # Создаем индексные файлы для уникальных директорий файлов
    sort -u "$temp_dirs" | while read -r file_dir; do
        if [ -d "$file_dir" ]; then
            file_name=$(basename "$file_dir")
            create_file_index "$file_dir" "Файл: $file_name"
        fi
    done

    rm -f "$temp_dirs"

    # Создаем индексные файлы для всех промежуточных директорий
    echo "Создание индексных файлов для директорий..."

    # Находим все директории в документации
    find "$DOCS_ROOT" -type d | sort | while read -r dir; do
        # Пропускаем корневую директорию
        if [ "$dir" = "$DOCS_ROOT" ]; then
            continue
        fi

        # Проверяем, есть ли в директории поддиректории и нет ли уже index.md
        if find "$dir" -maxdepth 1 -type d | grep -q . 2>/dev/null && [ ! -f "$dir/index.md" ]; then
            # Создаем индексный файл для директории
            dir_name=$(basename "$dir")
            create_directory_index "$dir" "Директория: $dir_name"
        fi
    done
}

# Основная логика
echo "Начинаю генерацию документации..."
echo "Корневая директория документации: $DOCS_ROOT"
echo "Исходная директория: $SOURCE_DIR"

# Очистка существующей документации
if [ -d "$DOCS_ROOT" ]; then
    echo "Очистка существующей документации..."
    rm -rf "$DOCS_ROOT"/*
fi

# Подсчет файлов
TOTAL_FILES=$(find "$SOURCE_DIR" -name "*.asm" -type f | wc -l)
echo "Найдено файлов для обработки: $TOTAL_FILES"

# Создаем временный файл для отслеживания прогресса
PROGRESS_FILE=$(mktemp)
echo "0" > "$PROGRESS_FILE"

# Обработка всех .asm файлов
find "$SOURCE_DIR" -name "*.asm" -type f | while read -r file; do
    # Увеличиваем счетчик
    current_count=$(cat "$PROGRESS_FILE")
    current_count=$((current_count + 1))
    echo "$current_count" > "$PROGRESS_FILE"

    echo "Обработка файла $current_count из $TOTAL_FILES: $(basename "$file")"
    process_file "$file"
done

# Читаем финальный счетчик
PROCESSED_FILES=$(cat "$PROGRESS_FILE")
rm -f "$PROGRESS_FILE"

echo "Обработано файлов: $PROCESSED_FILES из $TOTAL_FILES"

# Создание всех индексных файлов
create_all_indexes

# Создание главного индексного файла
echo "Создание главного индексного файла..."

cat > "$DOCS_ROOT/index.md" << EOF
# Описание внутренних функций языка

Документация по функциям проекта, сгенерированная из исходного кода.

## Разделы

EOF

# Поиск всех директорий первого уровня для главного индекса
find "$DOCS_ROOT" -maxdepth 1 -type d | while read -r dir; do
    # Пропускаем корневую директорию
    if [ "$dir" = "$DOCS_ROOT" ]; then
        continue
    fi

    # Проверяем, есть ли в директории поддиректории
    if find "$dir" -maxdepth 1 -type d | grep -q .; then
        relative_path="${dir#$DOCS_ROOT/}"
        echo "- [\`$relative_path\`]($relative_path/)" >> "$DOCS_ROOT/index.md"
    fi
done

# Создание README файла с инструкциями
cat >> "$DOCS_ROOT/index.md" << EOF

## Структура документации

- \`index.md\` - главная страница с навигацией по всем модулям
- Каждая директория содержит \`index.md\` с ссылками на содержимое
- \`lib/\` - документация по библиотечным функциям
- \`core/\` - документация по основным компонентам
- \`executor/\` - документация по исполнителю
- \`modules/\` - документация по модулям

## Навигация

Каждая директория содержит \`index.md\` файл со ссылками на:

- Поддиректории (модули, файлы)
- Функции внутри файлов

## Формат документации функций

Каждая функция документируется в отдельной директории со следующими разделами:

### Заголовок

Название функции

### Описание

Подробное описание функциональности

### Параметры

- ASM-вставка с названиями аргументов
- Список параметров с описанием

### Возвращаемое значение

Описание возвращаемого значения

### Примеры

Примеры использования функции

## Генерация документации

Для обновления документации выполните:

\`\`\`bash
./hooks/generate_docs_internal.sh docs .
\`\`\`

## Примечания

- Документация генерируется из комментариев в исходном коде
- Используйте теги \`@function\`, \`@description\`, \`@param\`, \`@return\`, \`@example\`
- Документация должна быть размещена перед объявлением функции
- Каждая директория содержит навигационный \`index.md\` файл
EOF

echo "Документация успешно сгенерирована в директории: $DOCS_ROOT"
