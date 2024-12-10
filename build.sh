iconv -f utf-8 -t cp1251 $1.asm > $1-1251.asm
wine ml64.exe -c -Zi -Fl -nologo $1-1251.asm
wine link.exe /DEBUG /MAP /SUBSYSTEM:CONSOLE lib/x64/kernel32.lib lib/x64/User32.Lib lib/x64/WinMM.Lib lib/x64/ntdll.lib $1-1251.obj
wine $1-1251.exe
