Shell Scripts Collections
===

System Administration NCTU 2014 Fall

---

### Files and Descrption

+ gol.awk
    + Conway's Game of Life by AWK
    + default size 30x30
    + `awk -f gol.awk` to run

+ gol.sh
    + One line shell script of Conway's Game of Life
    + Base on the AWK version
    + `sh gol.sh` to run

+ process-inspector.sh
    + Parse the output of `ps auxww`
    + List by the user and the status of the process
    + Clear and easy view
    + `sh process-inspector.sh` to run

+ polygolt.sh
    + A script to call other compilers/interpreters base on the input files and commands
    + `polyglot.sh [-h] [-s src] [-o output_name] [-l lang] [-c compiler]`
    + use `-h` to get help messages
    + use `-l` to specific language
    + Language support: C/C++, Python2/3, Perl, Ruby, Lua, Haskell, Bash
    + Compiler support: Clang/Clang++, GCC/G++
