ps aux|awk '{print $1,$8,$2}'|sed '1d'|sort -k1,2 -k3n|awk '{n[$1]++;if(n[$1]==1){printf "\n%s",$1;delete s;}s[$2]++;if(s[$2]==1){printf "\n\t%s ( ",$2}printf "%s ",$3}'|sed 's/\([0-9] $\)/\1)/'|sed '1d'