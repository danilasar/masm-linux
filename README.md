# MASM для Линукса
## Требования
Для корректной работы компилятора masm достаточно лишь установленного wine.
## Как этим пользоваться?
```sh
bin/build.sh [-hfr] [-o <имя_выхода>] [-c [<вход>:<выход>]] [-l библиотеки] <имя_входа>
```
- имя\_входа  - имя исходного файла без расширения
-  `-h`                    - справка
-  `-o <имя>`              - выходной файл (например, -o aboba.exe)
-  `-c [входная:выходная]` - перекодировать входной файл (по умолчанию utf8 -> win1251)
-  `-f`                    - не удалять файлы сборки
-  `-r`                    - запустить программу после сборки
-  `-l`                    - компонуемые библиотеки (в кавычках lib-файлы через пробел, по умолчанию kernel32, user32, winmm, ntdll, advapi32)
где `aboba` &mdash; это имя asm-файла без расширения.
## Как это работает?
В этом дистрибутиве содержится всё необходимое для запуска компилятора из-под вина, а также все необходимые lib-файлы для компоновки.

При установке флага -c сборщик конвертирует исходный файл из UTF-8 в Windows-1251 (или согласно указанным кодировкам) с помощью iconv. Это может быть полезно при проблемах с кириллицей.

Затем сборщик запускает ml64 и link и скармливает им конвертированный исходник. При установленном флаге `-r` опять же из-под вина запускает скомпилированную программу.

Пример:
```sh
bin/build.sh -r lab6.asm # скомпилирует и запустит lab6.asm
```
## Как быть с библиотеками?
Благодаря флагу -l можно подсосать любую статическую библиотеку и всё успешно скомпонуется. Я заботливо подготовил в папке lib солянку из winapi и прочих виндовых библиотек, для общих задач этого более чем достаточно (а для лабораторных по ассемблеру хватает всего пять из их числа, они подключаются автоматически), но, само собой, никто не запрещает и свои подставлять.

```sh
bin/build.sh -r -o output.exe -l "lib/x64/shell32.lib lib/x64/kernel32.dll lib/x64/user32.dll" otveti_s_osi
```
