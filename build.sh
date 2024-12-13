#iconv -f utf-8 -t cp1251 $1.asm > $1-1251.asm
wine ml64.exe -c -Zi -Fl -nologo $1.asm
if [ $? -eq 0 ]; then
    echo Ассемблирование успешно
    wine link.exe /DEBUG /MAP /SUBSYSTEM:CONSOLE lib/x64/kernel32.lib lib/x64/User32.Lib lib/x64/WinMM.Lib lib/x64/ntdll.lib lib/x64/AdvAPI32.Lib $1.obj
    if [ $? -eq 0 ]; then
        echo "Компоновка завершена"
        wine $1.exe
    else
        echo "Ошибка компоновки"
    fi
else
    echo Ошибка ассемблирования
fi
