#!/bin/sh
eval SOURCE=$(realpath $(dirname "$0"))
if [ -z "$1" ]; then
    echo "Нет опций сборки. Используй флаг -h для справки"
    exit -1
fi
function check_arg(){
	if [[ $2 == -* ]]; then 
		echo "Флаг $1 требует наличие аргумента" >&2
		exit 1
	fi
}
function parse_param() {
    while getopts :frhi:o:l:c opt; do
        case $opt in
            h)
                echo "build [-hfr] [-o <имя_выхода>] [-c [<вход>:<выход>]] [-l библиотеки] <имя_входа>,"
                echo " где имя_входа  - имя исходного файла без расширения,"
                echo "   а библиотеки - lib-файлы через пробел "
                echo ""
                echo " * -h                    - справка"
                echo " * -o <имя>              - выходной файл (например, -o aboba.exe)"
                echo " * -c [входная:выходная] - перекодировать входной файл (по умолчанию utf8 -> win1251)"
                echo " * -f                    - не удалять файлы сборки"
                echo " * -r                    - запустить программу после сборки"
                echo " * -l                    - компонуемые библиотеки"
                echo "                            (по умолчанию kernel32, user32, winmm, ntdll, advapi32)"
                exit 1
            ;;
            f)
                OPTION_FLUSH=false
            ;;
            o)
                check_arg "-o" "$OPTARG"
                OPTION_CUSTOM_OUTPUT_FILENAME=true
                OPTION_OUTPUT_FILENAME=$OPTARG
            ;;
            l)
                check_arg "-l" "$OPTARG"
                OPTION_LIBS=$OPTARG
            ;;
            c)
                OPTION_UCONV=true
                # Следующий параметр
                eval nextopt=\${$OPTIND}
                _colons=${nextopt//[^:]}
                # Существует и не начинается с дефиса?
                if [[ -n $nextopt && $nextopt != -* && ${#_colons} == 1 ]] ; then
                    OPTIND=$((OPTIND + 1))
                    level=$nextopt
                    set -f
                    IFS=':'
                    array=($nextopt)
                    OPTION_INPUT_ENCODING=${array[0]}
                    OPTION_OUTPUT_ENCODING=${array[1]}
                else
                    level=1
                    OPTION_INPUT_ENCODING=utf-8
                    OPTION_OUTPUT_ENCODING=cp1251
                fi
            ;;
            r)
                OPTION_RUN=true
            ;;
            \?)
                echo "Неверный флаг: -$OPTARG" >&2 
                exit -3
            ;;
            :)
                echo "Флаг -$OPTARG требует наличие аргумента" >&2
                exit -4
            ;;
        esac
    done
}
function build() {
    echo $OPTION_FILENAME
    #cd ${SOURCE}
    cd $(dirname $OPTION_FILENAME)
    if $OPTION_UCONV; then
        iconv -f ${OPTION_INPUT_ENCODING} -t ${OPTION_OUTPUT_ENCODING} ${OPTION_INPUT_FILENAME}.asm > ${OPTION_FILENAME}.asm
    fi
    wine $SOURCE/ml64.exe -c -Zi -Fl -nologo $(winepath -w ${OPTION_FILENAME}.asm)
    if [ $? -eq 0 ]; then
        echo Ассемблирование успешно
        echo wine $SOURCE/link.exe /DEBUG /MAP /SUBSYSTEM:CONSOLE ${OPTION_LIBS} $(winepath -w ${OPTION_FILENAME}).obj
        wine $SOURCE/link.exe /DEBUG /MAP /SUBSYSTEM:CONSOLE ${OPTION_LIBS} $(winepath -w ${OPTION_FILENAME}).obj
        if [ $? -eq 0 ]; then
            echo Компоновка завершена
            if $OPTION_CUSTOM_OUTPUT_FILENAME; then
                echo move it move it
                mv ${OPTION_FILENAME}.exe ${OPTION_OUTPUT_FILENAME}
            else
                OPTION_OUTPUT_FILENAME=${OPTION_FILENAME}.exe
            fi
            if $OPTION_RUN; then
                wine $(winepath -w ${OPTION_OUTPUT_FILENAME})
            fi
        else
            echo Ошибка компоновки
        fi
    else
        echo Ошибка ассемблирования
    fi
}
function flush() {
    if $OPTION_FLUSH; then
        if $OPTION_UCONV; then
            rm ${OPTION_FILENAME}.asm
        fi
        rm ${OPTION_FILENAME}.{obj,lst,map,pdb,ilk}
    fi
}

eval DEFAULT_LIBS_ARRAY=(kernel32.lib User32.Lib WinMM.Lib ntdll.lib AdvAPI32.Lib)
eval DEFAULT_LIBS_STR=""
for lib in ${DEFAULT_LIBS_ARRAY[@]}; do 
    DEFAULT_LIBS_STR="$DEFAULT_LIBS_STR $(winepath -w ${SOURCE}/../lib/x64/${lib})"
done



eval OPTION_RUN=false
eval OPTION_UCONV=false
eval OPTION_FLUSH=true
eval OPTION_CUSTOM_OUTPUT_FILENAME=false
#OPTION_LIBS="${SOURCE}/../lib/x64/kernel32.lib ${SOURCE}/../lib/x64/User32.Lib ${SOURCE}/../lib/x64/WinMM.Lib ${SOURCE}../lib/x64/ntdll.lib ${SOURCE}/../lib/x64/AdvAPI32.Lib"
OPTION_LIBS=$DEFAULT_LIBS_STR

parse_param "$@"
shift $((OPTIND - 1))
if [ "$#" -ne 1 ]; then
    echo "Требуется имя файла. -h для вывода справки"
    exit -2
fi
eval OPTION_INPUT_FILENAME=$1
if $OPTION_UCONV; then
    eval OPTION_FILENAME=${OPTION_INPUT_FILENAME}-${OPTION_OUTPUT_ENCODING}
else
    eval OPTION_FILENAME=${OPTION_INPUT_FILENAME}
fi
echo $OPTION_FILENAME
eval OPTION_FILENAME=$(realpath $OPTION_FILENAME)
build
flush
