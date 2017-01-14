#!/usr/bin/env bash
showDB() {
    subdircount=`find "$PARENTDIR"/"" -maxdepth 1 -type d | wc -l`
    if [ $subdircount -eq 1 ]
    then
        zenity --info --text="No Databases Found"
    else
        ls -dl "$PARENTDIR"/*/"" | awk 'BEGIN{FS=" "}{ print $9}' | awk 'BEGIN{FS="/"}{ print $5 }'|zenity --text-info --title="Databases"
    fi
}
dropDB(){
    if [[ -e "$PARENTDIR"/""$3"" ]]
    then
        cd "$PARENTDIR"
        rm -rf "$3"
        zenity --info --text="$3 database deleted"
    else
        zenity --error --text="database not exits"
    fi
}
useDB() {
    if [[ -e "$PARENTDIR"/""$2"" ]] && [[ "$2" != "" ]]
    then
        CURRENTDB=$2
        cd "$PARENTDIR"/""$2""
        zenity --info --text="Database changed to $2"
    else
        zenity --error --text="database not exits"
    fi
}
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
