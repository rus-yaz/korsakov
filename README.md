# Язык программирования Корсáков

[![](<https://gitverse.ru/api/repos/rus.yaz/mediakit/raw/branch/master/Корсаков%20(блок)/Корсаков%20(блок,%20скруглённый%20прямоугольник)/Корсаков%20(блок,%20скруглённый%20прямоугольник).svg>)](https://корсаков.рус)

<div style="display: flex; justify-content: space-around">
    <a href="https://gitverse.ru/rus.yaz/korsakov"><img width="50em" src="https://gitverse.ru/apple-touch-icon.png"></a>
    <a href="https://altlinux.space/rus.yaz/korsakov"><img width="50em" src="https://altlinux.space/altlinux-space/design/raw/branch/main/ALT-Linux-Space-Favicon-Monochrome-White.svg"></a>
    <a href="https://github.com/rus-yaz/korsakov"><img width="50em" src="https://github.githubassets.com/favicons/favicon-dark.svg"></a>
    <a href="https://codeberg.org/rus-yaz/korsakov"><img width="50em" src="https://design.codeberg.org/logo-kit/icon_inverted.svg"></a>
    <a href="https://gitlab.com/rus.yaz/korsakov"><img width="50em" src="https://images.ctfassets.net/xz1dnu24egyd/5VNS0QDlyHhsJnrAv9uO53/e4c4ade0e9a25c33c13cda7b5c6be67c/gitlab-logo-700.svg"></a>
    <a href="https://sourcecraft.dev/rus-yaz/korsakov"><img width="50em" src="https://sourcecraft.dev/icons/favicon.svg"></a>
    <a href="https://gitflic.ru/project/rus-yaz/korsakov"><img width="50em" src="https://gitflic.ru//static/image/favicon/icon@512.png"></a>
</div>

## Описание

**Корсáков** – это проект по разработке нового, независимого языка программирования, поддерживающего кириллическую знаковую систему. Цель проекта – создание универсального инструмента для работы на разных архитектурах (x86-64, ARM, E2K и другие) и операционных системах (Microsoft Windows, macOS, дистрибутивы на базе ядра GNU/Linux).

## Дорожная карта

> Внимание!
>
> Сейчас проект находится на стадии бета-тестирования.
>
> Большая часть функционала не реализована, а также могут встречаться существенные баги. При нахождении таковых, пожалуйста, сообщайте [в раздел «Задачи»](gitverse.ru/rus.yaz/korsakov/tasktracker) или в [чате Дневника разработки](#дневник-разработки).

Подробности о развитии проекта в [Дневнике разработки](#дневник-разработки), а также в файле [Дорожной карты](./Документация/Дорожная_карта.md)

## Сборка и использование

> На текущий момент Корсáков доступен только для Linux-дистрибутивов с архитектурой `x86_64`

### Установка через пакетный менеджер

#### Arch Linux (AUR)

##### Ручная сборка

```sh
git clone https://aur.archlinux.org/packages/korsakov.git
cd korsakov
makepkg -si
```

##### Помощники

```sh
yay -S korsakov        # С ключами в Pacman-стиле
pamac install korsakov # Pamac
```

### Установка из репозитория

#### Подготовка

```sh
git clone https://gitverse.ru/rus.yaz/korsakov --depth 1
cd korsakov
```

#### Сборка

##### Make

```sh
make
# или
make build
```

##### Вручную

```sh
fasm -m 131072 korsakov.asm korsakov.o
ld korsakov.o -o korsakov
ld korsakov.o -o корсаков
```

##### Отладочная сборка

> Режим отладки позволяет увидеть промежуточные этапы работы компилятора/интерпретатора:
>
> - Токены
> - Работу парсера и итоговое абстрактное синтаксическое дерево
> - Работу компилятора (и итоговый код) или интерпретатора, в зависимости от режима исполнения

```sh
make debug
# или
fasm -m 131072 -d DEBUG= korsakov.asm korsakov.o
ld korsakov.o -o korsakov
ld korsakov.o -o корсаков
```

#### Установка

```sh
make install
# или
sudo install -m 755 korsakov /usr/bin/korsakov
sudo install -m 755 корсаков /usr/bin/корсаков
```

### Использование

```sh
Использование:
  корсаков [флаги] файл.[корс|kors]

Флаги:
  --справка|--помощь|-п|--help|-h
      Показать эту справку

  --компилировать|--компиляция|--комп|-к|--compile|-c
      Компиляция в исполняемый файл с таким же именем, что и переданный

  --выходной-файл|--выход|-в|--output|-o [имя_файла]
      Указание имени выходного файла

  --без-стандартной|--no-std
      Компиляция без стандартной библиотеки
```

> По умолчанию код выполняется в режиме интерпретации.
>
> В будущем настройку по умолчанию можно будет изменить с помощью конфигурационного файла.

## Подсветка синтаксиса

Мы предоставляем поддержку подсветки синтаксиса для редакторов Vim и Neovim.

### Для Vim

```bash
cd Подсветка\ синтаксиса/vim
mkdir -p ~/.vim/syntax
cp korsakov.vim ~/.vim/syntax/
echo "au BufNewFile,BufRead *.kors :set filetype=korsakov
au BufNewFile,BufRead *.корс :set filetype=korsakov" >> ~/.vimrc
```

### Для Neovim

```bash
cd Подсветка\ синтаксиса/nvim
cp -r syntax ftdetect ~/.config/nvim
```

## Спонсорство

Проект был поддержан Фондом содействия инновациям, подробнее на [сайте проекта](#контакты).

Если вы хотите поддержать разработчика, вы также можете оставить [пожертвование](#контакты). Если вы укажите имя или ник, то вы будете закреплены в файле [Спонсоров](./Документация/Спонсоры.md).

## Лицензия

Данный проект имеет двойную лицензию, подробнее в файле [Лицензий](./LICENSE.md)

## Контакты

Если у вас возникли вопросы или предложения, пожалуйста, свяжитесь с нами:

- Официальный сайт проекта: [корсаков.рус](https://корсаков.рус)
- Основной репозиторий проекта: [GitVerse](https://gitverse.ru/rus.yaz/korsakov)
- Электронная почта организации: info@корсаков.рус

### Дневник разработки (Телеграм)

- Канал: [@korsakov_rus](https://t.me/korsakov_rus)
- Чат: [@korsakov_chat](https://t.me/korsakov_chat)
- Информационный аккаунт: [@korsakov_info](https://t.me/korsakov_info)

### Другие ссылки

- [Прототип языка на Python](https://gitverse.ru/rus.yaz/korsakov_python). Синтаксис уже не совместим с текущей версией, доступна только интерпретация. Данный прототип более не будет развиваться.
- [Документация от сообщества](https://gitverse.ru/YaKotikTvoy/LearningKorsakov). Спасибо пользователю [YaKotikTvoy](https://gitverse.ru/YaKotikTvoy) за активное участие в жизни проекта!

### Спонсорство

Если хотите оставить своё имя или ник в истории развития языка, не забудьте указать их в сообщении

- [Т-Банк](https://www.tbank.ru/cf/7Bc8yWbbr4V)
