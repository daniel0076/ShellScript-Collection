#!/bin/sh
src=""
o_name="sa.out"
lang=""
polyglot=""
help (){
    echo "$0 [-h] [-s src] [-o output_name] [-l lang] [-c compiler]"
}
while getopts ":hl:o:s:c:" flag ; do
    case ${flag} in
        s)
            src=${OPTARG}
            if [ ! -s $src ];then
                echo "Error open source, $OPTARG is not a valid file"
                help
                exit
            fi
            ;;
        o)
            o_name=${OPTARG}
            ;;
        l)
            lang="${OPTARG}"
            ;;
        c)
            c_cpr=${OPTARG}
            ;;
        \?)
            echo "Invalid option -$OPTARG"
            help
            exit
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            help
            exit
            ;;
        *|h)
            help
            exit
            ;;
    esac
done
if [ -z $src ];then
    echo "No source code spicified...exiting"
    help
    exit
elif [ -z $lang ];then
    echo "No language spicified"
    exit
fi
arr=`env echo $lang |sed 's/,/ /g'`
for key in $arr;do
    if echo $key |env grep -cE '^[Cc]$' > /dev/null;then
        polyglot=`env which gcc`
        if [ "$c_cpr" = "clang"  ] || [ "$c_cpr" = "clang++" ]; then
            polyglot=`env which clang`
        fi
        $polyglot -o $o_name $src;./$o_name
    fi
    if echo $key |env grep -cE '^[Cc]([p\+])\1$|cc$' > /dev/null;then
        polyglot=`env which g++`
        if [ "$c_cpr" = "clang++"  ] || [ "$c_cpr" = "clang++" ]; then
            polyglot=`env which clang++`
        fi
        $polyglot -std=c++11 -o $o_name $src;./$o_name
    fi
    if echo $key |env grep -cE '^awk$|^AWK$' > /dev/null;then
        polyglot=`env which awk`
        $polyglot $src
    fi
    if echo $key |env grep -cE '^[Pp]erl$' > /dev/null;then
        polyglot=`env which perl`
        $polyglot $src
    fi
    if echo $key |env grep -cE '^[Pp]ython[2]?$|^py[2]?$' > /dev/null;then
        polyglot=`env which python2`
        $polyglot $src
    fi
    if echo $key |env grep -cE '^[Pp]ython3$|^py3$' > /dev/null;then
        polyglot=`env which python3`
        $polyglot $src
    fi
    if echo $key |env grep -cE '^[Rr]uby$|^rb$' > /dev/null;then
        polyglot=`env which ruby`
        $polyglot $src
    fi
    if echo $key |env grep -cE '^[Hh]askell$|^hs$' > /dev/null;then
        polyglot=`env which ghc`
        $polyglot $src
    fi
    if echo $key |env grep -cE '^[Ll]ua$' > /dev/null;then
        polyglot=`env which lua52`
        if echo $polyglot |env grep -c 'no'>/dev/null;then
            polyglot=`env which lua`
        elif [ -z $polyglot ];then
            polyglot=`env which lua`
        fi
        $polyglot $src
    fi
    if echo $key |env grep -cE '^[Bb]ash$' > /dev/null;then
        polyglot=`env which bash`
        $polyglot $src
    fi
    if [ -z $polyglot ]; then
        echo "Invalid language or you do not have the compiler/interpreter"
        exit
    fi
done
