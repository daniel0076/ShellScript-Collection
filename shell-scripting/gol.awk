BEGIN{
    printf("\033[2J");
    srand()
    size=30;
    for(h=0;h<size;h++){
        for(w=0;w<size;w++){
            map[h,w]=(rand() >= 0.5)?1:0;
            tmp[h,w]=map[h,w]
        }
    }
    {
        while(1){

            for(h=0;h<size;h++){
                for(w=0;w<size;w++){
                    count=map[h,w+1]+map[h,w-1]+map[h+1,w]+map[h-1,w]+map[h-1,w-1]+map[h-1,w+1]+map[h+1,w+1]+map[h+1,w-1];
                    if(map[h,w]==0 && count==3) tmp[h,w]=1;
                    else if(map[h,w]==1 && count<2) tmp[h,w]=0;
                        else if(map[h,w]==1 && count>3) tmp[h,w]=0;
                        }
                }
                printf("\033[1;1H");   # Home cursor
                for(i=0;i<30;i++)printf "==";
                print;
                for(h=0;h<size;h++){
                    for(w=0;w<size;w++){
                        map[h,w]=tmp[h,w];
                        if(map[h,w]==1)printf "x ";
                        else printf "  ";
                    }
                    printf "\n"
                }
                for(i=0;i<30;i++)printf "==";
                for(i=0;i<1100000;i++); #make it slower
            }
        }
    }
