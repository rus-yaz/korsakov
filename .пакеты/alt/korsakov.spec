%define _unpackaged_files_terminate_build 1
%define cyrillic_name корсаков


Name: korsakov
Version: 1.15.2
Release: alt1

Summary: Cyrillic multi-paradigm general-purpose programming language
Summary(ru_RU.UTF-8): Кириллический мультипарадигменный язык программирования общего назначения
License: GPL-3.0-or-later
Group: Development/Other

Url: https://gitverse.ru/rus.yaz/korsakov
Vcs: https://gitverse.ru/rus.yaz/korsakov
Source: %name-%version.tar

BuildRequires: fasm

Requires: fasm

ExclusiveArch: x86_64

Provides: korsákov
Provides: %cyrillic_name

%description
Korsakov is a project to develop a new, independent programming language that
supports the Cyrillic sign system. The goal of the project is to create a
universal tool for working on different architectures (x86-64, ARM, E2K and
others) and operating systems (Microsoft Windows, macOS, distributions based on
the GNU/Linux kernel).

%description -l ru_RU.UTF-8
Корсаков – это проект по разработке нового, независимого языка
программирования, поддерживающего кириллическую знаковую систему. Цель проекта
– создание универсального инструмента для работы на разных архитектурах
(x86-64, ARM, E2K и другие) и операционных системах (Microsoft Windows, macOS,
дистрибутивы на базе ядра GNU/Linux).

%prep
%setup

%build
make

%install
make install

%files
%_datadir/%name
%_bindir/%name
%_bindir/%cyrillic_name
%doc README.md

%changelog
* Thu May 22 2025 David Sultaniiazov <x1z53@altlinux.org> 1.15.2-alt1
- Initial build
