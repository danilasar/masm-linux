# MASM для Линукса
## Требования
Для корректной работы компилятора masm достаточно лишь установленного wine.
## Как этим пользоваться?
```sh
build.sh aboba
```
где `aboba` &mdash; это имя asm-файла без расширения.
## Как это работает?
В этом дистрибутиве содержится всё необходимое для запуска компилятора из-под вина, а также все необходимые lib-файлы для компоновки.

Сборщик конвертирует исходный файл из UTF-8 в Windows-1251 (поскольку приколы винды), затем запускает ml64 и link и скармливает им конвертированный исходник, после чего опять же из-под вина запускает скомпилированную программу.
