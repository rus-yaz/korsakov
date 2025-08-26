#!/bin/bash

# Скрипт для анализа регистров, используемых в функциях
# Анализирует .asm файлы и показывает регистры для каждой функции
# Данный скрипт сгенерирован нейросетью

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Функция для вывода справки
show_help() {
    echo "Использование: $0 [опции] [файлы...]"
    echo ""
    echo "Опции:"
    echo "  -h, --help     Показать эту справку"
    echo "  -r, --recursive Рекурсивно искать .asm файлы в подкаталогах"
    echo "  -v, --verbose  Подробный вывод (включая размеры регистров)"
    echo "  -s, --summary  Показать только сводку"
    echo "  -c, --check    Проверить соответствие регистров в объявлении и теле функции"
    echo "  -z, --sizes    Показать размеры регистров (1-байт, 2-байт, 4-байт, 8-байт)"
    echo "  -p, --problems Показать только проблемные места"
    echo ""
    echo "Поддерживаемые размеры регистров:"
    echo "  8-bit (1-byte):  al, bl, cl, dl, ah, bh, ch, dh, sil, dil, spl, bpl, r8b-r15b"
    echo "  16-bit (2-byte): ax, bx, cx, dx, si, di, sp, bp, r8w-r15w"
    echo "  32-bit (4-byte): eax, ebx, ecx, edx, esi, edi, esp, ebp, r8d-r15d"
    echo "  64-bit (8-byte): rax, rbx, rcx, rdx, rsi, rdi, rsp, rbp, r8-r15"
    echo ""
    echo "Примеры:"
    echo "  $0 lib/arithmetical.asm"
    echo "  $0 -r ."
    echo "  $0 -s *.asm"
    echo "  $0 -v -c *.asm    # Подробная проверка с размерами"
    echo "  $0 -p *.asm       # Показать только проблемы"
}

# Переменные по умолчанию
RECURSIVE=false
VERBOSE=false
SUMMARY_ONLY=false
CHECK_REGISTERS=false
SHOW_SIZES=false
PROBLEMS_ONLY=false
FILES=()

# Парсинг аргументов командной строки
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -r|--recursive)
            RECURSIVE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -s|--summary)
            SUMMARY_ONLY=true
            shift
            ;;
        -c|--check)
            CHECK_REGISTERS=true
            shift
            ;;
        -z|--sizes)
            SHOW_SIZES=true
            shift
            ;;
        -p|--problems)
            PROBLEMS_ONLY=true
            shift
            ;;
        -*)
            echo -e "${RED}Ошибка: Неизвестная опция $1${NC}" >&2
            show_help
            exit 1
            ;;
        *)
            FILES+=("$1")
            shift
            ;;
    esac
done

# Если файлы не указаны, используем текущую директорию
if [ ${#FILES[@]} -eq 0 ]; then
    FILES=(".")
fi

# Функция для извлечения регистров из строки
extract_registers_from_string() {
    local regs_string="$1"
    local -a registers=()

    # Разбиваем строку по запятым и убираем пробелы
    IFS=',' read -ra reg_array <<< "$regs_string"
    for reg in "${reg_array[@]}"; do
        reg=$(echo "$reg" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        if [ -n "$reg" ]; then
            registers+=("$reg")
        fi
    done

    printf '%s\n' "${registers[@]}"
}

# Функция для извлечения регистров из тела функции
extract_registers_from_body() {
    local file="$1"
    local func_start_line="$2"
    local func_end_line="$3"
    local -a used_registers=()

    # Читаем тело функции (от строки после объявления до следующей функции или конца файла)
    local line_num=0
    local in_function=false
    local function_depth=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Пропускаем строки до начала функции
        if [ $line_num -lt $func_start_line ]; then
            continue
        fi

        # Проверяем, не является ли это объявлением другой функции (но не комментарием)
        if [[ $line =~ ^[[:space:]]*_function[[:space:]]+([^,]+) ]] && [ $line_num -gt $func_start_line ]; then
            break
        fi

        # Пропускаем объявление текущей функции
        if [[ $line =~ _function[[:space:]]+([^,]+) ]] && [ $line_num -eq $func_start_line ]; then
            continue
        fi

        # Ищем использование регистров в строке
        # Исключаем комментарии
        if [[ $line =~ ^[[:space:]]*\; ]]; then
            continue
        fi

        # Ищем регистры в инструкциях (первый операнд)
        if [[ $line =~ ^[[:space:]]*[a-z_]+[[:space:]]+([re][a-z0-9]+)[[:space:]]*[,] ]]; then
            local reg="${BASH_REMATCH[1]}"
            # Проверяем, что это действительно регистр
            if is_register "$reg"; then
                if [[ ! " ${used_registers[@]} " =~ " ${reg} " ]]; then
                    used_registers+=("$reg")
                fi
            fi
        fi

        # Ищем регистры как второй операнд (после запятой)
        if [[ $line =~ ,[[:space:]]*([re][a-z0-9]+) ]]; then
            local reg="${BASH_REMATCH[1]}"
            if is_register "$reg"; then
                if [[ ! " ${used_registers[@]} " =~ " ${reg} " ]]; then
                    used_registers+=("$reg")
                fi
            fi
        fi

        # Ищем регистры в скобках (адресация памяти)
        if [[ $line =~ \[([re][a-z0-9]+)\] ]]; then
            local reg="${BASH_REMATCH[1]}"
            if is_register "$reg"; then
                if [[ ! " ${used_registers[@]} " =~ " ${reg} " ]]; then
                    used_registers+=("$reg")
                fi
            fi
        fi

        # Ищем регистры в конце строки (например, в метках)
        if [[ $line =~ [[:space:]]([re][a-z0-9]+)[[:space:]]*$ ]]; then
            local reg="${BASH_REMATCH[1]}"
            if is_register "$reg"; then
                if [[ ! " ${used_registers[@]} " =~ " ${reg} " ]]; then
                    used_registers+=("$reg")
                fi
            fi
        fi

        # Ищем 8-битные регистры (al, bl, cl, dl, ah, bh, ch, dh, sil, dil, spl, bpl, r8b-r15b)
        # Улучшенный паттерн для 8-битных регистров
        if [[ $line =~ [[:space:]]([abcd][hl]|[sd]il|[sb]pl|r[0-9]+b)[[:space:]]|^[[:space:]]*[a-z_]+[[:space:]]+([abcd][hl]|[sd]il|[sb]pl|r[0-9]+b)[[:space:]]*[,]|,[[:space:]]*([abcd][hl]|[sd]il|[sb]pl|r[0-9]+b)[[:space:]]|\[([abcd][hl]|[sd]il|[sb]pl|r[0-9]+b)\] ]]; then
            local reg=""
            # Извлекаем регистр из соответствующей группы
            for i in {1..4}; do
                if [ -n "${BASH_REMATCH[$i]}" ]; then
                    reg="${BASH_REMATCH[$i]}"
                    break
                fi
            done
            if is_register "$reg"; then
                if [[ ! " ${used_registers[@]} " =~ " ${reg} " ]]; then
                    used_registers+=("$reg")
                fi
            fi
        fi

        # Ищем 16-битные регистры (ax, bx, cx, dx, si, di, sp, bp, r8w-r15w)
        # Улучшенный паттерн для 16-битных регистров
        if [[ $line =~ [[:space:]]([abcd][x]|[sd][ip]|r[0-9]+w)[[:space:]]|^[[:space:]]*[a-z_]+[[:space:]]+([abcd][x]|[sd][ip]|r[0-9]+w)[[:space:]]*[,]|,[[:space:]]*([abcd][x]|[sd][ip]|r[0-9]+w)[[:space:]]|\[([abcd][x]|[sd][ip]|r[0-9]+w)\] ]]; then
            local reg=""
            # Извлекаем регистр из соответствующей группы
            for i in {1..4}; do
                if [ -n "${BASH_REMATCH[$i]}" ]; then
                    reg="${BASH_REMATCH[$i]}"
                    break
                fi
            done
            if is_register "$reg"; then
                if [[ ! " ${used_registers[@]} " =~ " ${reg} " ]]; then
                    used_registers+=("$reg")
                fi
            fi
        fi

        # Ищем 32-битные регистры (eax, ebx, ecx, edx, esi, edi, esp, ebp, r8d-r15d)
        # Улучшенный паттерн для 32-битных регистров
        if [[ $line =~ [[:space:]](e[abcd][x]|e[sd][ip]|r[0-9]+d)[[:space:]]|^[[:space:]]*[a-z_]+[[:space:]]+(e[abcd][x]|e[sd][ip]|r[0-9]+d)[[:space:]]*[,]|,[[:space:]]*(e[abcd][x]|e[sd][ip]|r[0-9]+d)[[:space:]]|\[(e[abcd][x]|e[sd][ip]|r[0-9]+d)\]|\[[^]]*\][[:space:]]*(e[abcd][x]|e[sd][ip]|r[0-9]+d) ]]; then
            local reg=""
            # Извлекаем регистр из соответствующей группы
            for i in {1..5}; do
                if [ -n "${BASH_REMATCH[$i]}" ]; then
                    reg="${BASH_REMATCH[$i]}"
                    break
                fi
            done
            if is_register "$reg"; then
                if [[ ! " ${used_registers[@]} " =~ " ${reg} " ]]; then
                    used_registers+=("$reg")
                fi
            fi
        fi

    done < "$file"

    printf '%s\n' "${used_registers[@]}"
}

# Функция для определения размера регистра
get_register_size() {
    local reg="$1"

    # 8-битные регистры (1-байтовые)
    if [[ $reg =~ ^([abcd][hl]|[sd]il|[sb]pl|r[0-9]+b)$ ]]; then
        echo "8-bit (1-byte)"
        return
    fi

    # 16-битные регистры (2-байтовые)
    if [[ $reg =~ ^([abcd][x]|[sd][ip]|r[0-9]+w)$ ]]; then
        echo "16-bit (2-byte)"
        return
    fi

    # 32-битные регистры (4-байтовые)
    if [[ $reg =~ ^(e[abcd][x]|e[sd][ip]|r[0-9]+d)$ ]]; then
        echo "32-bit (4-byte)"
        return
    fi

    # 64-битные регистры (8-байтовые)
    if [[ $reg =~ ^r[a-z0-9]+$ ]]; then
        echo "64-bit (8-byte)"
        return
    fi

    echo "unknown"
}

# Функция для проверки, является ли слово регистром
is_register() {
    local word="$1"

    # 64-битные регистры
    case "$word" in
        rax|rbx|rcx|rdx|rsi|rdi|rsp|rbp|r8|r9|r10|r11|r12|r13|r14|r15) return 0 ;;
    esac

    # 32-битные регистры
    case "$word" in
        eax|ebx|ecx|edx|esi|edi|esp|ebp|r8d|r9d|r10d|r11d|r12d|r13d|r14d|r15d) return 0 ;;
    esac

    # 16-битные регистры
    case "$word" in
        ax|bx|cx|dx|si|di|sp|bp|r8w|r9w|r10w|r11w|r12w|r13w|r14w|r15w) return 0 ;;
    esac

    # 8-битные регистры
    case "$word" in
        al|bl|cl|dl|ah|bh|ch|dh|sil|dil|spl|bpl|r8b|r9b|r10b|r11b|r12b|r13b|r14b|r15b) return 0 ;;
    esac

    return 1
}

# Функция для получения старшей версии регистра
get_parent_register() {
    local reg="$1"

    # 64-битные регистры (остаются как есть)
    if [[ $reg =~ ^r[a-z0-9]+$ ]] && [[ ! $reg =~ ^r[0-9]+d$ ]]; then
        echo "$reg"
        return
    fi

    # 32-битные регистры
    case "$reg" in
        eax) echo "rax" ;;
        ebx) echo "rbx" ;;
        ecx) echo "rcx" ;;
        edx) echo "rdx" ;;
        esi) echo "rsi" ;;
        edi) echo "rdi" ;;
        esp) echo "rsp" ;;
        ebp) echo "rbp" ;;
        r8d) echo "r8" ;;
        r9d) echo "r9" ;;
        r10d) echo "r10" ;;
        r11d) echo "r11" ;;
        r12d) echo "r12" ;;
        r13d) echo "r13" ;;
        r14d) echo "r14" ;;
        r15d) echo "r15" ;;
        # 16-битные регистры (2-байтовые)
        ax) echo "rax" ;;
        bx) echo "rbx" ;;
        cx) echo "rcx" ;;
        dx) echo "rdx" ;;
        si) echo "rsi" ;;
        di) echo "rdi" ;;
        sp) echo "rsp" ;;
        bp) echo "rbp" ;;
        r8w) echo "r8" ;;
        r9w) echo "r9" ;;
        r10w) echo "r10" ;;
        r11w) echo "r11" ;;
        r12w) echo "r12" ;;
        r13w) echo "r13" ;;
        r14w) echo "r14" ;;
        r15w) echo "r15" ;;
        # 8-битные регистры (1-байтовые)
        al) echo "rax" ;;
        ah) echo "rax" ;;
        bl) echo "rbx" ;;
        bh) echo "rbx" ;;
        cl) echo "rcx" ;;
        ch) echo "rcx" ;;
        dl) echo "rdx" ;;
        dh) echo "rdx" ;;
        sil) echo "rsi" ;;
        dil) echo "rdi" ;;
        spl) echo "rsp" ;;
        bpl) echo "rbp" ;;
        r8b) echo "r8" ;;
        r9b) echo "r9" ;;
        r10b) echo "r10" ;;
        r11b) echo "r11" ;;
        r12b) echo "r12" ;;
        r13b) echo "r13" ;;
        r14b) echo "r14" ;;
        r15b) echo "r15" ;;
        # Если не распознан, возвращаем как есть
        *) echo "$reg" ;;
    esac
}

# Функция для проверки документации функции
check_function_documentation() {
    local file="$1"
    local func_line="$2"
    local func_name="$3"

    # Ищем документацию перед функцией (до 50 строк назад)
    local start_line=$((func_line - 50))
    if [ $start_line -lt 1 ]; then
        start_line=1
    fi

    # Находим предыдущую функцию, чтобы ограничить поиск
    local prev_function_line=0
    local temp_line_num=0

    while IFS= read -r temp_line; do
        temp_line_num=$((temp_line_num + 1))
        if [ $temp_line_num -ge $start_line ] && [ $temp_line_num -lt $func_line ]; then
            if [[ $temp_line =~ ^[[:space:]]*_function ]]; then
                prev_function_line=$temp_line_num
            fi
        fi
    done < "$file"

    # Если нашли предыдущую функцию, начинаем поиск после неё
    if [ $prev_function_line -gt 0 ]; then
        start_line=$((prev_function_line + 1))
    fi

    local has_return_tag=false
    local has_documentation=false
    local line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))
        if [ $line_num -ge $start_line ] && [ $line_num -lt $func_line ]; then
            # Ищем любые комментарии документации
            if [[ $line =~ ^[[:space:]]*\;.*@ ]]; then
                has_documentation=true
                # Ищем @return в комментариях
                if [[ $line =~ ^[[:space:]]*\;.*@return ]]; then
                    has_return_tag=true
                    break
                fi
            fi
            # Если встретили другую функцию, прекращаем поиск
            if [[ $line =~ ^[[:space:]]*_function ]]; then
                break
            fi
        fi
    done < "$file"

    if [ "$has_return_tag" = true ]; then
        echo "has_return"
    elif [ "$has_documentation" = true ]; then
        echo "no_return"
    else
        echo "none"
    fi
}

# Функция для сравнения списков регистров
compare_register_lists() {
    local declared_regs="$1"
    local used_regs="$2"
    local func_name="$3"
    local file="$4"
    local func_line="$5"
    local silent_mode="${6:-false}"

    local -a declared_array=()
    local -a used_array=()
    local -a missing_in_declaration=()
    local -a unused_declared=()

    # Преобразуем строки в массивы
    while IFS= read -r reg; do
        if [ -n "$reg" ]; then
            declared_array+=("$reg")
        fi
    done < <(extract_registers_from_string "$declared_regs")

    while IFS= read -r reg; do
        if [ -n "$reg" ]; then
            used_array+=("$reg")
        fi
    done < <(echo "$used_regs")

    # Проверяем наличие @return в документации
    local doc_status=$(check_function_documentation "$file" "$func_line" "$func_name")

    # Проверяем отсутствие документации
    local has_documentation_issue=false
    if [ "$doc_status" = "none" ]; then
        has_documentation_issue=true
        if [ "$silent_mode" != "true" ]; then
            echo -e "${YELLOW}ℹ️  Функция '$func_name' не имеет документации${NC}"
        fi
    fi

    # Находим регистры, которые используются, но не объявлены
    for used_reg in "${used_array[@]}"; do
        local found=false
        local parent_used_reg=$(get_parent_register "$used_reg")

        # Пропускаем rsp и rbp (системные регистры)
        if [ "$parent_used_reg" = "rsp" ] || [ "$parent_used_reg" = "rbp" ]; then
            continue
        fi

        # Если есть @return, пропускаем rax
        if [ "$doc_status" = "has_return" ] && [ "$parent_used_reg" = "rax" ]; then
            continue
        fi

        # Проверяем точное совпадение
        for declared_reg in "${declared_array[@]}"; do
            if [ "$used_reg" = "$declared_reg" ]; then
                found=true
                break
            fi
        done

        # Если точное совпадение не найдено, проверяем родительские регистры
        if [ "$found" = false ]; then
            for declared_reg in "${declared_array[@]}"; do
                local parent_declared_reg=$(get_parent_register "$declared_reg")
                if [ "$parent_used_reg" = "$parent_declared_reg" ]; then
                    found=true
                    break
                fi
            done
        fi

        if [ "$found" = false ]; then
            missing_in_declaration+=("$used_reg")
        fi
    done

    # Находим объявленные, но неиспользуемые регистры
    for declared_reg in "${declared_array[@]}"; do
        local found=false
        local parent_declared_reg=$(get_parent_register "$declared_reg")

        # Проверяем точное совпадение
        for used_reg in "${used_array[@]}"; do
            if [ "$declared_reg" = "$used_reg" ]; then
                found=true
                break
            fi
        done

        # Если точное совпадение не найдено, проверяем родительские регистры
        if [ "$found" = false ]; then
            for used_reg in "${used_array[@]}"; do
                local parent_used_reg=$(get_parent_register "$used_reg")
                if [ "$parent_declared_reg" = "$parent_used_reg" ]; then
                    found=true
                    break
                fi
            done
        fi

        if [ "$found" = false ]; then
            unused_declared+=("$declared_reg")
        fi
    done

    # Проверяем логику с rax
    local has_rax_in_declared=false

    for declared_reg in "${declared_array[@]}"; do
        local parent_declared_reg=$(get_parent_register "$declared_reg")
        if [ "$parent_declared_reg" = "rax" ]; then
            has_rax_in_declared=true
            break
        fi
    done

    if [ "$doc_status" = "has_return" ]; then
        # Если есть @return, rax не должен быть объявлен
        if [ "$has_rax_in_declared" = true ]; then
            if [ "$silent_mode" != "true" ]; then
                echo -e "${RED}⚠️  Ошибка в функции '$func_name': rax объявлен, но есть @return в документации${NC}"
            fi
            return 1
        fi
    elif [ "$doc_status" = "no_return" ]; then
        # Если есть документация, но нет @return, проверяем rax
        if [ "$has_rax_in_declared" = true ]; then
            # rax объявлен - это корректно
            :
        else
            # Проверяем, используется ли rax в коде
            local rax_used=false
            while IFS= read -r reg; do
                if [ -n "$reg" ]; then
                    local parent_reg=$(get_parent_register "$reg")
                    if [ "$parent_reg" = "rax" ]; then
                        rax_used=true
                        break
                    fi
                fi
            done < <(echo "$used_regs")

            if [ "$rax_used" = true ]; then
                if [ "$silent_mode" != "true" ]; then
                    echo -e "${RED}⚠️  Ошибка в функции '$func_name': rax используется, но не объявлен и нет @return в документации${NC}"
                fi
                return 1
            fi
        fi
    fi
    # Если doc_status = "none", то не проверяем rax вообще

    # Выводим результаты
    if [ ${#missing_in_declaration[@]} -gt 0 ] || [ ${#unused_declared[@]} -gt 0 ] || [ "$has_documentation_issue" = true ]; then
        if [ "$silent_mode" != "true" ]; then
            if [ ${#missing_in_declaration[@]} -gt 0 ] || [ ${#unused_declared[@]} -gt 0 ]; then
                echo -e "${RED}⚠️  Несоответствия в функции '$func_name':${NC}"

                if [ ${#missing_in_declaration[@]} -gt 0 ]; then
                    echo -e "${YELLOW}  Используются, но не объявлены:${NC} ${missing_in_declaration[*]}"
                    # Показываем соответствие с родительскими регистрами
                    echo -e "${MAGENTA}  Соответствие:${NC}"
                    for reg in "${missing_in_declaration[@]}"; do
                        local parent=$(get_parent_register "$reg")
                        if [ "$reg" != "$parent" ]; then
                            echo -e "${MAGENTA}    $reg → $parent${NC}"
                        fi
                    done
                fi

                if [ ${#unused_declared[@]} -gt 0 ]; then
                    echo -e "${CYAN}  Объявлены, но не используются:${NC} ${unused_declared[*]}"
                fi
                echo ""
            fi
        fi
        return 1
    else
        if [ "$silent_mode" != "true" ]; then
            echo -e "${GREEN}✅ Регистры функции '$func_name' соответствуют${NC}"
        fi
        return 0
    fi
}

# Функция для анализа одного файла
analyze_file() {
    local file="$1"
    local found_functions=false
    local total_issues=0

    if [ ! -f "$file" ]; then
        echo -e "${RED}Ошибка: Файл '$file' не найден${NC}" >&2
        return 1
    fi

    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}Анализирую файл: $file${NC}"
    fi

    # Сначала собираем информацию о всех функциях
    local -a function_names=()
    local -a function_regs=()
    local -a function_lines=()
    local line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))
        if [[ $line =~ ^[[:space:]]*_function[[:space:]]+([^,]+),([[:space:]]*(.+))? ]]; then
            # Пропускаем определения макросов
            if [[ $line =~ macro ]]; then
                continue
            fi

            # Извлекаем имя функции и регистры вручную
            local func_name=$(echo "$line" | sed -n 's/^[[:space:]]*_function[[:space:]]*\([^,]*\),.*/\1/p')
            local regs_part=$(echo "$line" | sed -n 's/^[[:space:]]*_function[[:space:]]*[^,]*,\(.*\)/\1/p')



            # Извлекаем регистры
            local regs=""
            if [ -n "$regs_part" ]; then
                regs=$(echo "$regs_part" | sed 's/^[[:space:]]*,[[:space:]]*//' | sed 's/[[:space:]]*$//')
            fi

            function_names+=("$func_name")
            function_regs+=("$regs")
            function_lines+=("$line_num")
        fi
    done < "$file"

    # Теперь анализируем каждую функцию
    for i in "${!function_names[@]}"; do
        local func_name="${function_names[$i]}"
        local declared_regs="${function_regs[$i]}"
        local func_line="${function_lines[$i]}"

        found_functions=true

        # Если включен режим "только проблемы", но нет проверки регистров,
        # то показываем только функции с объявленными регистрами
        if [ "$PROBLEMS_ONLY" = true ] && [ "$CHECK_REGISTERS" = false ]; then
            if [ -n "$declared_regs" ]; then
                echo -e "${GREEN}Функция:${NC} $func_name"
                echo -e "${YELLOW}Объявленные регистры:${NC} $declared_regs"

                # Показываем размеры регистров в режиме -z
                if [ "$SHOW_SIZES" = true ]; then
                    echo -e "${BLUE}Размеры регистров:${NC}"
                    while IFS= read -r reg; do
                        if [ -n "$reg" ]; then
                            local size=$(get_register_size "$reg")
                            echo -e "  ${CYAN}$reg${NC}: $size"
                        fi
                    done < <(extract_registers_from_string "$declared_regs")
                fi
                echo ""
            fi
            continue
        fi

        # Режим "только проблемы" - показываем только функции с проблемами
        if [ "$PROBLEMS_ONLY" = true ] && [ "$CHECK_REGISTERS" = true ] && [ -n "$declared_regs" ]; then
            # Извлекаем регистры из тела функции для проверки
            local used_regs=$(extract_registers_from_body "$file" "$func_line" "")

            # Проверяем наличие проблем в тихом режиме
            if compare_register_lists "$declared_regs" "$used_regs" "$func_name" "$file" "$func_line" "true"; then
                # Нет проблем
                :
            else
                # Есть проблемы, показываем функцию
                echo -e "${GREEN}Функция:${NC} $func_name"
                echo -e "${YELLOW}Объявленные регистры:${NC} $declared_regs"
                if [ -n "$used_regs" ]; then
                    echo -e "${CYAN}Используемые регистры:${NC} $(echo "$used_regs" | tr '\n' ' ')"
                fi
                # Показываем проблемы
                compare_register_lists "$declared_regs" "$used_regs" "$func_name" "$file" "$func_line" "false"
                total_issues=$((total_issues + 1))
            fi
        elif [ "$SUMMARY_ONLY" = false ] && [ "$PROBLEMS_ONLY" = false ]; then
            echo -e "${GREEN}Функция:${NC} $func_name"
            if [ -n "$declared_regs" ]; then
                echo -e "${YELLOW}Объявленные регистры:${NC} $declared_regs"

                # Показываем размеры регистров в verbose режиме или при использовании -z
                if [ "$VERBOSE" = true ] || [ "$SHOW_SIZES" = true ]; then
                    echo -e "${BLUE}Размеры регистров:${NC}"
                    while IFS= read -r reg; do
                        if [ -n "$reg" ]; then
                            local size=$(get_register_size "$reg")
                            echo -e "  ${CYAN}$reg${NC}: $size"
                        fi
                    done < <(extract_registers_from_string "$declared_regs")
                fi
            else
                echo -e "${YELLOW}Объявленные регистры:${NC} не указаны"
            fi

            # Если включена проверка регистров
            if [ "$CHECK_REGISTERS" = true ] && [ -n "$declared_regs" ]; then
                if [ "$PROBLEMS_ONLY" = false ]; then
                    echo -e "${MAGENTA}Проверяю соответствие регистров...${NC}"
                fi

                # Извлекаем регистры из тела функции
                local used_regs=$(extract_registers_from_body "$file" "$func_line" "")

                if [ "$PROBLEMS_ONLY" = false ]; then
                    if [ -n "$used_regs" ]; then
                        echo -e "${CYAN}Используемые регистры:${NC} $(echo "$used_regs" | tr '\n' ' ')"

                        # Показываем размеры используемых регистров в verbose режиме или при использовании -z
                        if [ "$VERBOSE" = true ] || [ "$SHOW_SIZES" = true ]; then
                            echo -e "${BLUE}Размеры используемых регистров:${NC}"
                            while IFS= read -r reg; do
                                if [ -n "$reg" ]; then
                                    local size=$(get_register_size "$reg")
                                    echo -e "  ${CYAN}$reg${NC}: $size"
                                fi
                            done < <(echo "$used_regs")
                        fi
                    else
                        echo -e "${CYAN}Используемые регистры:${NC} не найдены"
                    fi
                fi

                # Сравниваем регистры
                if compare_register_lists "$declared_regs" "$used_regs" "$func_name" "$file" "$func_line"; then
                    # Успешно
                    :
                else
                    total_issues=$((total_issues + 1))
                fi
            fi
            echo ""
        else
            if [ -n "$declared_regs" ]; then
                echo "$func_name: $declared_regs"

                # Показываем размеры регистров в summary режиме при использовании -z
                if [ "$SHOW_SIZES" = true ]; then
                    while IFS= read -r reg; do
                        if [ -n "$reg" ]; then
                            local size=$(get_register_size "$reg")
                            echo "  $reg: $size"
                        fi
                    done < <(extract_registers_from_string "$declared_regs")
                fi
            else
                echo "$func_name: (без регистров)"
            fi

            # Если включена проверка регистров, показываем краткую информацию о проблемах
            if [ "$CHECK_REGISTERS" = true ] && [ -n "$declared_regs" ]; then
                local used_regs=$(extract_registers_from_body "$file" "$func_line" "")
                if [ -n "$used_regs" ]; then
                    # Простая проверка на наличие rax (часто используется как возврат)
                    if echo "$used_regs" | grep -q "rax" && ! echo "$declared_regs" | grep -q "rax"; then
                        echo "  ⚠️  rax используется, но не объявлен"
                    fi
                fi
            fi
        fi
    done

    if [ "$found_functions" = false ] && [ "$VERBOSE" = true ]; then
        echo -e "${YELLOW}В файле '$file' не найдено функций${NC}"
    fi

    if [ "$CHECK_REGISTERS" = true ] && [ $total_issues -gt 0 ]; then
        echo -e "${RED}Всего проблем: $total_issues${NC}"
    fi

    return $total_issues
}

# Функция для рекурсивного поиска .asm файлов
find_asm_files() {
    local dir="$1"
    find "$dir" -name "*.asm" -type f 2>/dev/null || true
}

# Основная логика
main() {
    local total_files=0
    local processed_files=0

    for item in "${FILES[@]}"; do
        if [ -f "$item" ]; then
            # Это файл
            if [[ "$item" == *.asm ]]; then
                total_files=$((total_files + 1))
                if analyze_file "$item"; then
                    processed_files=$((processed_files + 1))
                fi
            else
                echo -e "${YELLOW}Пропускаю файл '$item' (не .asm файл)${NC}" >&2
            fi
        elif [ -d "$item" ]; then
            # Это директория
            if [ "$RECURSIVE" = true ]; then
                # Рекурсивный поиск
                while IFS= read -r asm_file; do
                    if [ -n "$asm_file" ]; then
                        total_files=$((total_files + 1))
                        if analyze_file "$asm_file"; then
                            processed_files=$((processed_files + 1))
                        fi
                    fi
                done < <(find_asm_files "$item")
            else
                # Только файлы в текущей директории
                for asm_file in "$item"/*.asm; do
                    if [ -f "$asm_file" ]; then
                        total_files=$((total_files + 1))
                        if analyze_file "$asm_file"; then
                            processed_files=$((processed_files + 1))
                        fi
                    fi
                done
            fi
        else
            echo -e "${RED}Ошибка: '$item' не является файлом или директорией${NC}" >&2
        fi
    done

    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}Обработано файлов: $processed_files из $total_files${NC}"
    fi
}

# Запуск основной функции
main
