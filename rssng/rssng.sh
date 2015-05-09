if [ ! -d $HOME/.feed ];then
    env mkdir $HOME/.feed
fi
dir=$HOME/.feed
feed_ls="$dir/feed.list"
py3=`env which python3`
welcome(){
dialog --ascii-lines --ok-label 'But...I want google reader QAQ' --title 'The Next(?) Generation RSS Reader' --no-collapse --cr-wrap --msgbox '
 ________      ________      ________
/  ____  \\   /  ______))   /  ______))
| ||___) ||  |  ((_____    |  ((_____
|  ___  _//   \ _____  \\   \ _____  \\     .__   __.   ______
| ||  \ \\    _______) ||   _______) ||     |  \ |  |  /  ____|
|_||   \_\\  (_________//  (_________//     |   \|  | |  |  __
                                            |  . `  | |  | |_ |
                                            |  |\   | |  |__| |
                                            |__| \__|  \______|

                       Powered By mushr00m
' 16 70
menu
}

menu(){
rm -f $dir/tmp.*
tmp=`env mktemp $dir/tmp.XXX`
dialog --ascii-lines --clear --title "Main Menu" \
        --menu "Choose an action" 12 40 10 \
        "R"  "Read subscribed feeds" \
        "S" "Subscribe new feed" \
        "D" "Delete subscription" \
        "U" "Update subscription" \
        "Q"  "Leave RSSng" 2>$tmp
        choice=`cat $tmp`
        rm -f $tmp
        action $choice
}
subscribe(){
    tmp=`env mktemp $dir/tmp.XXX`
    dialog --ascii-lines --title "Subscribe" --clear --inputbox "Enter feed url:" 10 50 2>$tmp
    url=`env cat $tmp`
    if [ -z $url ];then
        dialog --ascii-lines --title 'Error!' --msgbox 'No url input' 5 20
        return
    else
        title=`env $py3 feed.py -u $url -t|sed 's/ /_/g'`
        if [ "$title" = "Something_got_wrong_o_O!" ] || [ -z $title ];then
            dialog --ascii-lines --title 'Not valid url' --msgbox 'Cannot not resolve the url' 5 40
            return
        elif (cat $feed_ls| grep -c $title);then
            dialog --ascii-lines --title 'Oops' --msgbox 'URL is already subscribed!' 5 40
            return
        fi
        echo "x $title $url" >> $feed_ls
        cat $feed_ls|awk '{print NR,$2,$3}' > $tmp
        cat $tmp > $feed_ls
    fi
}
select_feed(){
    tmp=`env mktemp $dir/tmp.XXX`
    if [ ! -s $feed_ls ];then
        dialog --ascii-lines --title 'Empty' --msgbox 'List empty, Subscribe first' 5 35
        return
    fi
    DIALOG=' --ascii-lines --menu "Feeds" 12 40 10'
    while read n t u;do
        t=`echo $t|sed 's/_/ /g'|awk '{printf "\"%s\"",$0}'`
        DIALOG="$DIALOG $n $t"
    done < $feed_ls
    echo "$DIALOG"|xargs dialog 2>$tmp
    case $? in
        0)
            feed_no=`env cat $tmp`
            feed_title=`cat $feed_ls |grep ^$feed_no|awk '{print $2}'`
            read_rss $feed_title
            select_feed
            ;;
        1)
            return
            ;;
        255)
            dialog --ascii-lines --title 'Oops' --msgbox 'ESC Pressed' 5 20
    esac

}
read_rss(){
    tmp=`env mktemp $dir/tmp.XXX`
    feed_items=$dir/${1}.items
    if [ ! -s $feed_items ];then
        dialog --ascii-lines --title 'Empty' --msgbox 'No items for the feed, update first' 5 45
        return
    else
        t=`echo $1|sed 's/_/ /g'|awk '{printf "\"%s\"",$0}'`
        items=`cat $feed_items`
        DIALOG=" --ascii-lines --clear --title $t --menu 'Articles' 30 80 30 $items"
        echo $DIALOG |xargs dialog 2>$tmp
    fi
    case $? in
        0)
            arti_no=`cat  $tmp`
            arti_no=$(($arti_no-1))
            arti_conent=`cat $dir/${1}.articles/$arti_no`
            dialog --ascii-lines --title 'Content' --msgbox "$arti_conent"  20 100
            read_rss ${1}
            ;;
        1)
            return
            ;;
    esac
}
delete(){
    if [ ! -s $feed_ls ];then
        dialog --ascii-lines --title 'Empty' --msgbox 'List empty, Nothing to delete' 5 45
        return
    fi
    tmp=`env mktemp $dir/tmp.XXX`
    DIALOG=' --ascii-lines --menu "Feeds" 12 40 10'
    while read n t u;do
        t=`echo $t|sed 's/_/ /g'|awk '{printf "\"%s\"",$0}'`
        DIALOG="$DIALOG $n $t"
    done < $feed_ls
    echo "$DIALOG"|xargs dialog 2>$tmp
    case $? in
        0)
            choice=`cat $tmp`
            del=/^`cat $tmp`/d
            store=`cat $feed_ls|grep $choice|awk '{print $2}'`
            rm -rf $dir/$store*
            sed -i -e $del $feed_ls
            dialog --ascii-lines --title 'Deleted' --msgbox 'Success' 5 20
            cat $feed_ls|awk '{print NR,$2,$3}' > $tmp
            cat $tmp > $feed_ls
            ;;
        1)
            return
            ;;
       255)
            dialog --ascii-lines --title 'Oops' --msgbox 'ESC Pressed' 5 20
    esac
}
update(){
    tmp=`env mktemp $dir/tmp.XXX`
    if [ ! -s $feed_ls ];then
        dialog --ascii-lines --title 'Empty' --msgbox 'List empty, Subscribe first' 5 35
        return
    fi
    DIALOG=' --ascii-lines --checklist "Feeds" 12 40 10'
    while read n t u;do
        t=`echo $t|sed 's/_/ /g'|awk '{printf "\"%s\"",$0}'`
        DIALOG="$DIALOG $n $t 0"
    done < $feed_ls
    echo "$DIALOG"|xargs dialog 2>$tmp
    options=`env cat $tmp|tr -d \"`
    for no in $options;do
        feed_url=`cat $feed_ls |grep ^$no|awk '{print $3}'`
        feed_title=`cat $feed_ls |grep ^$no|awk '{print $2}'`
        if [ ! -d $dir/${feed_title}.articles ];then
            mkdir $dir/${feed_title}.articles
        fi
        rm -f $dir/${feed_title}.items
        item_count=`env $py3 feed.py -u $feed_url -i|wc -l`
        item_count=$(($item_count/3))
        i=0
        counter=0
        while [ $i -lt $item_count ] ; do
            $py3 feed.py -u $feed_url -n $i >$tmp
            cat $tmp|sed "s/\"/'/g" |sed -ne '1p' >>$dir/${feed_title}.items
            cat $tmp |sed -ne '1p' >$dir/${feed_title}.articles/$i
            echo "===================================================">>$dir/${feed_title}.articles/$i
            cat $tmp |sed -ne '2p'|sed  -e 's/^http:/Feed URL: http:/' >> $dir/${feed_title}.articles/$i
            echo "===================================================">>$dir/${feed_title}.articles/$i
            cat $tmp |sed -e '1,2d' >> $dir/${feed_title}.articles/$i
            echo "===================================================">>$dir/${feed_title}.articles/$i
            counter=$((($i*100)/$item_count))
            i=$(($i+1))
            echo $counter
            echo XXX
            echo "Please wait...($counter% )"
            echo XXX
        done | dialog --ascii-lines --title "Updating ${feed_title}" --gauge "Please wait..." 7 70 0
        cat $dir/${feed_title}.items|awk '{printf "%s \"%s\" ",NR,$0}' > $tmp
        cat $tmp > $dir/${feed_title}.items
    done
    return
}
action(){
    choice=$1
    case $choice in
        R)
            select_feed
            menu
            ;;
        S)
            subscribe
            menu
            ;;
        D)
            delete
            menu
            ;;
        U)
            update
            menu
            ;;
        Q|*)
            dialog --ascii-lines --title 'Leaving RSSng' --msgbox 'Bye Bye!' 5 20
            exit
            ;;
    esac
}
welcome
