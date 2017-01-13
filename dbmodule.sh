#!/usr/bin/env bash
showDB() {
    subdircount=`find "$PARENTDIR"/"" -maxdepth 1 -type d | wc -l`
    if [ $subdircount -eq 1 ]
    then
        ERROR="No Databases Found"
        zenity --info --text="No Databases Found"
    else
        ls -dl "$PARENTDIR"/*/"" | awk 'BEGIN{FS=" "}{ print $9}' | awk 'BEGIN{FS="/"}{ print $5 }'|zenity --text-info --title="Databases"
    fi
}

#changes working directory to the selected database dir
useDB() {
    if test -e "$PARENTDIR"/""$2"" && [[ "$2" != "" ]]
    then
        CURRENTDB=$2
        cd "$PARENTDIR"/""$2""
        zenity --info --text="Database changed to $2"
    else
        zenity --error --text="database not exits"
    fi
}
#checks if there is adirectory already matching the to be created database , creates new dir for every DB
newDB() {
    local r_db_name="${*: -1}"
    local db_path
    local response
    db_path="$PARENTDIR"/"$r_db_name"
    if [ -d "$db_path" ]
    then
        zenity --info --text="database already exits"
    else
        mkdir $db_path
        zenity --info --text="$r_db_name created"
        zenity --info --text="Type use database_name to change working database"
    fi
}
