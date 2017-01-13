#!/usr/bin/env bash
set -x
PARENTDIR="$HOME/bash_dbms"
USERSFILE="$PARENTDIR/users_file"
DBMSOPTFILE="$PARENTDIR/dbms_opt"
GPK=""
. ./tablemodule.sh
. ./dbmodule.sh
. ./usermodule.sh
#processes commands and redirects workflow according
checkCommand() {
    if [[ "$1" == "create" ]]
    then
        generalCreate $*
    fi
    if [[ "$1" == "use" ]]
    then
        useDB $*
    fi
    if [[ "$1" == "check" ]]
    then
        checkPWD
    fi
    if [[ "$1" == "show" ]]
    then
        show $*
    fi
    if [[ "$1" == "drop" ]]
    then
        drop $*
    fi
    if [[ "$1" == "insert" ]]
    then
        checkInsertStatment $*
    fi
    if [[ "$1" == "select" ]] && [[ "$2" == "all" ]]
    then
        selectAllTable $*
    fi
    if [[ "$1" == "select" ]] && [[ "$2" != "all" ]]
    then
        selectTableColumn $*
    fi
    if [[ "$1" == "delete" ]] && [[ "$2" == "row" ]] 
    then
        deleteTableRow $*
    fi
    if [[ "$1" == "update" ]] && [[ "$2" == "row" ]] 
    then
        updateTableRow $*
    fi
}
drop() {
    if [[ "$2" == "table" ]]
    then
        removeTable $*
    elif [[ "$2" == "database" ]]; then
        remove_database $*
    fi
}
# for internal testing 
checkPWD() {
    echo $(pwd)
}
show() {
    if [[ "$2" == "tables" ]]
    then
        showTable $*
    elif [[ "$2" == "databases" ]]; then
        showDB $*
    fi
}
#recieves any create command then redirects 
generalCreate() {
    if [[ "$2" == "table" ]]
    then
        createTable $*
    elif [[ "$2" == "database" ]]; then
        newDB $*
    fi
}
#command prompt for INPUT
DBMSloop() {
    local COMMAND=getCommand
    if [[ "$COMMAND" = "" ]]
    then
        exit
    else
        while [[ "$COMMAND" != "exit" ]]
        do
            checkCommand $COMMAND
            COMMAND=$(getCommand)
        done
    fi
}
#get command from user
getCommand() {
    local INPUT=$(awk '{print $0}' $DBMSOPTFILE |yad --text-info --title="DBMS Commands" --text="current used dabtabase: $CURRENTDB" --editable --maximized --lang=sql)
    echo $INPUT >$DBMSOPTFILE
    if [[ "$INPUT" = "" ]]
    then
        echo 1
    else
        echo $INPUT | awk 'BEGIN{FS = " "}{ for(i = 1; i <= NF; i++) { print $i; } }'
    fi
}

#check if main dir is present and redirects user to userLogin or create user according to result
firstRun() {
    if [[ ! -e $PARENTDIR ]]
    then
        setupDBMS
        zenity --warning --text "no no not here create user before"
        newUSER
        DBMSloop
    else
        userLogin
    fi
}

setupDBMS() {
    zenity --info --text "Welcome home $LOGNAME "
    zenity  --question --text "Are you sure you wish to proceed?"
    if [[ $? -eq 0 ]]
    then
        if [[ ! -e $PARENTDIR ]]
        then
            mkdir -p $PARENTDIR
            touch $DBMSOPTFILE
            touch $USERSFILE
            cd "$PARENTDIR"
        fi
    else
        zenity --info --text "You just break my heart"
        exit 0
    fi
}
firstRun
