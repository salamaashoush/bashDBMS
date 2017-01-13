#!/usr/bin/env bash
#creates new user and adds his/her userLogin info to USERSFILE
newUSER() {
    zenity --forms --title="Add User" \
        --text="Please Enter user userLogin and PASSWORD" \
        --separator=":" \
        --add-entry="User" \
        --add-PASSWORD="Password">$USERSFILE
    cd "$PARENTDIR"
}

userLogin() {
    OUTPUT=$(zenity --forms --title="User Login" \
        --text="Please Enter user userLogin and PASSWORD" \
        --separator=":" \
        --add-entry="User" \
        --add-password="Password")
    LOGIN=$(awk 'BEGIN{FS=":"}{print $1}'<<<$OUTPUT)
    PASSWORD=$(awk 'BEGIN{FS=":"}{print $2}'<<<$OUTPUT)
    if [[ ! $OUTPUT ]];then exit 0;fi
    if awk 'BEGIN{FS=":"}/'"$LOGIN"'/{print $1}/'"$PASSWORD"'/{print $2}' $USERSFILE | grep $LOGIN >/dev/null
    then
        zenity --info --text=$LOGIN" you are now logged in"
        cd "$PARENTDIR"
        DBMSloop
    else
        userLogin
    fi
}