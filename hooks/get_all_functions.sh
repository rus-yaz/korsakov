#! /bin/bash

# Временные файлы для сравнение
temp_funcs="$(mktemp)"
temp_macros="$(mktemp)"

# Флаг для выхода с ненулевым кодом
found=0

# Ассоциативный массива с файлами с функцией
declare -A files

# 1. Рекурсивно проходим по папкам и находим функции
while IFS= read -r -d '' file; do
    while IFS= read -r line; do
        func_name="$(echo "$line" | sed 's/^f_//' | sed 's/:$//')"
        files["$func_name"]="$file"
        echo "$func_name" >> "$temp_funcs"
    done < <(grep -h '^f_.*:$' "$file")
done < <(find . -type f -name '*.asm' -print0)

sort -u "$temp_funcs" -o "$temp_funcs"

# 2. Рекурсивно проходим по папкам и находим макросы
while IFS= read -r -d '' file; do
    grep -h '^macro.*{$' "$file" | awk '{print $2}'
done < <(find . -type f -name '*.asm' -print0) | sort -u > "$temp_macros"

# 3. В выводе маркируем бесхозные функции в древовидно-маркированной форме
echo "Бесхозные функции"

current_file=""
file_count=0
total_files=0

# считаем количество файлов с бесхозными функцией
temp_report="$(mktemp)"

while IFS= read -r item; do
    if ! grep -qx "$item" "$temp_macros"; then
        fname="${files[$item]}"
        fname="${fname#./}"

        echo "$fname|$item" >> "$temp_report"
    fi
done < "$temp_funcs"

# Получаем количество файлов с бесхозными функцией
total_files=$(cut -d'|' -f1 "$temp_report" | sort -u | wc -l)

current_file_index=0
current_file=""
current_file_count=0

cut -d'|' -f1 "$temp_report" | sort -u | while IFS='' read -r fname; do
    current_file_index=$((current_file_index+1))
    echo "$([ "$current_file_index" -lt "$total_files" ] && echo "├─" || echo "└─")" "$fname"

    # Получаем список функцияй в файле
    functions=($(grep "$fname|" "$temp_report" | cut -d'|' -f2 | sort -u))
    total_functions=${#functions}

    for i in "${!functions[@]}"; do
        if [ "$current_file_index" -lt "$total_files" ]; then
            echo -n "│"
        else
            echo -n " "
        fi

        echo -n "  "

        if [ "$((i+1 ))" -lt "${#functions[@]}" ]; then
            echo "├─ ${functions[$i]}"
        else
            echo "└─ ${functions[$i]}"
        fi
    done
done

# 4. В выводе маркируем функции без тестов в древовидно-маркированной форме
echo ""
echo "Функции без тестов"

current_file=""
temp_report_tests="$(mktemp)"

while IFS= read -r item; do
    fname="${files[$item]}"
    fname="${fname#./}"

    test_file="core_tests/${fname%%.*}/${item}.asm"
    if [ ! -f "$test_file" ]; then
        echo "$fname|$item" >> "$temp_report_tests"
    fi
done < "$temp_funcs"

# Получаем количество файлов с функцией без тестов
total_files_tests=$(cut -d'|' -f1 "$temp_report_tests" | sort -u | wc -l)

current_file_index=0

cut -d'|' -f1 "$temp_report_tests" | sort -u | while IFS='' read -r fname; do
    current_file_index=$((current_file_index+1))
    echo "$([ "$current_file_index" -lt "$total_files_tests" ] && echo "├─" || echo "└─")" "$fname"

    functions=($(grep "$fname|" "$temp_report_tests" | cut -d'|' -f2 | sort -u))
    total_functions=${#functions}

    for i in "${!functions[@]}"; do
        if [ "$current_file_index" -lt "$total_files_tests" ]; then
            echo -n "│"
        else
            echo -n " "
        fi

        echo -n "  "

        if [ "$((i+1 ))" -lt "${#functions[@]}" ]; then
            echo "├─ ${functions[$i]}"
        else
            echo "└─ ${functions[$i]}"
        fi
    done
done

# Чистка
rm "$temp_funcs" "$temp_macros" "$temp_report" "$temp_report_tests"

# Выйти с ненулевым кодом, если что было найдено
if [ "$found" -eq 1 ]; then
    exit 1
fi

exit 0
