#!/usr/bin/env bash
updatemode(){
    local primary_key=$(cat $5.index | awk 'BEGIN{FS=":"} {print $1}')
    if [[ $7 == $primary_key ]]
    then
        zenity --error --text="cannot update primary_key"
    else
        local flag
        flag=0;
        local re='^[0-9]+$'
        local data_types=($(getColumnDatatypes $5))
        local new_value=$(echo $* | awk 'BEGIN{FS="= "} {print $2}')
        local columns=($(head -1 $5 |awk 'BEGIN{FS=",";OFS=":"}{$1=$1; print $0}'| awk 'BEGIN{FS=":"}{for(i=1;i<=NF;i++) if(i%2) print $i}'))
        declare -A MYMAP
        typeset -i ind
        ind=0
        for column in "${columns[@]}"
        do
            MYMAP[$column]=$ind
            ind=$ind+1
        done
        typeset -i column_index
        local column_index=${MYMAP[$7]}
        if [[ "${data_types[$column_index]}" == "int" ]]
        then
            if [[ $new_value =~ $re ]]
            then
                flag=1;
            else
                flag=0;
            fi
        else
            if ! [[ $new_value =~ $re  ]]
            then
                flag=1;
            else
                flag=0;
            fi
        fi
        column_index+=1
        if [[ flag -eq 1 ]]
        then
            local new_tabel=$(awk -F "," 'BEGIN{OFS=","}{for(i =1 ; i <=NF ; i++) if(i == "'"$column_index"'" && NR == "'"$3"'") $i="'"$new_value"'" ;print$0}' $5)
            echo "$new_tabel" > $5
            echo Update sucess
        else
            echo non-valid
        fi
    fi
}

updateTableRow(){
    local re='^[0-9]+$'
    local line_num
    typeset -i line_num
    line_num=$(wc -l < $5)
    if [[ -f $5 ]]
    then
        if [[ $3 =~ $re ]] && [[ $3 -le $line_num ]]
        then
            if [[ $3 -ne 1 ]]
            then
                updatemode $*
            else
                zenity --error --text="cannot update table header"
            fi
        else
            zenity --error --text="non valid number"
        fi
    else
        zenity --error --text="No table with this name"
    fi
}

validateUniquePK(){
    local insert_statment=$(echo $* | awk 'BEGIN {FS = " "} { for ( i = 1;i <= NF;i++ ) { if (i = NF) print $i }  } ')
    local temp_values=$(echo $insert_statment | awk 'BEGIN {FS = "("} {print $2}')
    local raw_values=$(echo $temp_values | awk 'BEGIN {FS = ")"} {print $1}')
    local values=($(echo $raw_values | awk 'BEGIN {FS=","}{for(i=1;i<=NF;i++) print $i}'))
    local key=$(cat $4.index | awk 'BEGIN{FS=":"} {print $1}')
    local key_column_values=$(selectTableColumn $1 $key $3 $4)
    typeset -i p_key_index
    local p_key_index=$(cat $4.index | awk 'BEGIN{FS=":"} {print $2}')
    echo $key_column_values | grep ${values[$p_key_index]}
    if [[  $? -eq 0 ]]
    then
        echo "non unique"
    else
        echo "unique"
    fi
}

#uses global var p_key to create table_name.index
setPK(){
    local columns=($(head -1 $3 |awk 'BEGIN{FS=",";OFS=":"}{$1=$1; print $0}'| awk 'BEGIN{FS=":"}{for(i=1;i<=NF;i++) if(i%2) print $i}'))
    declare -A MYMAP
    local iterator
    typeset -i iterator
    typeset -i p_key_index
    iterator=0
    for column in "${columns[@]}"
    do
        if [[ $column == $GPK ]]
        then
            p_key_index=$iterator
        fi
        iterator=$iterator+1
    done
    echo "$GPK:$p_key_index" > $3.index
}

choosePK(){
    local flag=0
    local headers=($(getTableHeaders $*))
    headers=($(echo $headers |awk 'BEGIN{FS=",";OFS=":"}{$1=$1; print $0}'| awk 'BEGIN{FS=":"}{for(i=1;i<=NF;i++) if(i%2) print $i}'))
    primary_key=$(zenity --forms --title="Select primary key" \
        --text="Please select a valid  primary key" \
        --add-entry="Primary Key")
    for key in ${headers[@]}
    do
        if [[ $key == $primary_key ]]
        then #validates primary key is in table headers
            flag=1
        fi
    done

    if [[ flag -eq 1 ]]
    then
        zenity --info --text="primary_key set sucess"
        GPK=$primary_key  # set global var p_key to be used for .index creation
    else
        zenity --error --text="non-valid primary_key"
    fi
    return $flag
}

deleteTableRow(){
    local re='^[0-9]+$'
    local line_num
    typeset -i line_num
    line_num=$(wc -l < $5)
    if [[ -f $5 ]]
    then
        if [[ $3 =~ $re ]] && [[ $3 -le $line_num ]]
        then
            if [[ $3 -ne 1 ]]
            then
                sed -i "$3 d" $5
                sed -i "$3 d" $5.index
                zenity --info --text="row $3 deleted"
            else
                zenity --error --text="cannot delete table header"
            fi
        else
            zenity --error --text="non valid number"
        fi
    else
        zenity --error --text="No table with this name"
    fi
}

selectTableColumn(){
    local OFS='BEGIN{OFS=" "}'
    local result=''
    local column_to_select
    column_to_select=$2
    local columns=($(head -1 $4 |awk 'BEGIN{FS=",";OFS=":"}{$1=$1; print $0}'| awk 'BEGIN{FS=":"}{for(i=1;i<=NF;i++) if(i%2) print $i}'))
    local select_columns=($(echo $2|awk 'BEGIN{FS=","}{for(i=1;i<=NF;i++) print $i}'))
    declare -A MYMAP
    typeset -i ind
    typeset -i ind_awk
    ind_awk=0
    ind=0
    for column in "${columns[@]}"
    do
        MYMAP[$column]=$ind
        ind=$ind+1
    done
    for var in "${select_columns[@]}"
    do
        ind_awk=MYMAP[$var]
        ind_awk=$ind_awk+1
        result="$result\$$ind_awk\"  \" "
    done
    awk -F',' "$(echo $OFS){\$1=\$1; print $(echo $result)}" $4  |column -t -s" "
}

selectAllTable(){
    if  [[ "$3" == "from" ]]
    then
        if [[ -f $4 ]]
        then
            awk -F"," 'BEGIN{print "<table border="3px" width="320px">"}{print"<tr>";for(i=1;i<NF+1;i++){if(NR==1){print "<th>"$i"</th>"}else{print "<td>"$i"</td>"}}print "</tr>"}END{print "</table>"}' $4 | yad --text-info --title="All data from $4 table" --html --width=320 --height=480
        else
            zenity --info --text="No table with this name"
        fi
    fi
}

validateInsertDatatype() {
    local insert_statment=$(echo $* | awk 'BEGIN {FS = " "} { for ( i = 1;i <= NF;i++ ) { if (i = NF) print $i }  } ')
    local temp_values=$(echo $insert_statment | awk 'BEGIN {FS = "("} {print $2}')
    local raw_values=$(echo $temp_values | awk 'BEGIN {FS = ")"} {print $1}')
    local values=($(echo $raw_values | awk 'BEGIN {FS=","}{for(i=1;i<=NF;i++) print $i}'))
    local data_types=($(getColumnDatatypes $4))
    local re='^[0-9]+$'
    local flag
    local i
    i=0;
    flag=0;
    for value in "${values[@]}"
    do
        if [[ "${data_types[$i]}" == "int" ]]
        then
            if [[ $value =~ $re ]]
            then
                flag=1;
            else
                flag=0;
                break;
            fi
        else
            if ! [[ $value =~ $re  ]]
            then
                flag=1;
            else
                flag=0;
                break;
            fi
        fi
        i=$i+1;
    done
    echo $flag
}

getColumnDatatypes() {
    local data_types=$(head -1 $1 | awk 'BEGIN{FS=","; OFS=":"}{$1=$1 ;print $0}'|awk 'BEGIN{FS=":"}{for(i=1;i<=NF;i++) if(!(i%2)) print $i }')
    read -a data_array <<< $data_types
    echo $data_types
}
#get numbers of column to check against during insertion
getColumnCount() {
    local index
    index=0;
    local count_string=$(head -n1 $1 | awk 'BEGIN{FS=","}{print NF}')
    read -a count_array <<<$count_string
    echo ${count_array[@]}
}
#check insert synatx "insert into table table_name ()"
checkInsertStatment() {
    if [[ "$2" == "into" ]] && [[ "$3" == "table" ]]
    then
        tableInsert $*;
    else
        zenity --error --text="syntax error";
    fi
}

tableInsert() {
    local check_path=$(checkPWD)      #get number of colums
    local check_form=$(checkStatmentFormat $*)
    local check_num_colum=$(getColumnCount $4)
    local insert_statment=$(echo $* | awk 'BEGIN {FS = " "} { for ( i = 1;i <= NF;i++ ) { if (i = NF) print $i }  } ') #get number of values
    local temp_values=$(echo $insert_statment | awk 'BEGIN {FS = "("} {print $2}')
    local raw_values=$(echo $temp_values | awk 'BEGIN {FS = ")"} {print $1}')
    local values=$(echo $raw_values | awk 'BEGIN {FS=","}{print NF}')
    read -a values_array <<<$values
    local values_count=$(echo ${values_array[@]})
    local data_types=$(getColumnDatatypes $4)
    local valid_insertion=$(validateInsertDatatype $*)
    local unique_p_key
    if [[ "$check_path" == "$PARENTDIR" ]]
    then #check if databse is selected
        echo choose db first;
    else
        if [[ -f $4 ]]
        then #check if table is present
            if [[ check_form -eq 1 ]]
            then #check format (...,...,..)
                if [[ $check_num_colum -eq $values_count ]]
                then #check number of colums
                    if [[ $valid_insertion -eq 1 ]]
                    then
                        unique_p_key=$(validateUniquePK $*)
                        if [[ $unique_p_key == "unique" ]]
                        then
                            echo $raw_values >> $4;
                            zenity --info --text="insert data sucess"
                        else
                            zenity --error --text="insert unique primary_key"
                        fi
                    else
                        zenity --error --text="incompatible data types"
                    fi
                else
                    zenity --error --text="wrong number of colums"
                fi
            else
                zenity --error --text="check format"
            fi
        else
            zenity --error --text="no table with this name"
        fi
    fi
}
#checks datatypes during table first creation
checkHeaderDataType()  {
    declare -a valid=('int' 'char');
    local data_types=''
    local i
    local k
    local index
    index=0
    local insert_statment=$(echo $* | awk 'BEGIN {FS = " "} { for ( i = 1;i <= NF;i++ ) { if (i = NF) print $i }  } ')
    local temp_headers=$(echo $insert_statment | awk 'BEGIN {FS = "("} {print $2}')
    local headers=$(echo $temp_headers | awk 'BEGIN {FS = ")"} {print $1}')
    local temp_data_type=$(echo "$headers" |awk -F "," 'BEGIN{ OFS=":"; } {$1=$1; print $0 }')
    data_types=$(echo $temp_data_type | awk -F ":" '{for(i=1;i<=NF;i++) if (!(i%2)) print$i }')
    read -a array <<<$data_types
    local flag=non-valid
    for i in "${array[@]}"
    do
        flag=non-valid
        for k in "${valid[@]}"
        do
            if [[ "$k" == "$i"  ]]
            then
                flag=valid
                break
            fi
        done
    done
    echo $flag
}
#concat table headers
setTableHeader() {
    local insert_statment=$(echo $* | awk 'BEGIN {FS = " "} { for ( i = 1;i <= NF;i++ ) { if (i = NF) print $i }  } ')
    local temp_headers=$(echo $insert_statment | awk 'BEGIN {FS = "("} {print $2}')
    local headers=$(echo $temp_headers | awk 'BEGIN {FS = ")"} {print $1}')
    echo $headers >$3
}
#gets table header
getTableHeaders() {
    local insert_statment=$(echo $* | awk 'BEGIN {FS = " "} { for ( i = 1;i <= NF;i++ ) { if (i = NF) print $i }  } ')
    local temp_headers=$(echo $insert_statment | awk 'BEGIN {FS = "("} {print $2}')
    local headers=$(echo $temp_headers | awk 'BEGIN {FS = ")"} {print $1}')
    echo $headers
}
# checks for (.... ....,..... ...,...... ....) fromat
checkStatmentFormat() {
    local insert_statment=$(echo $* | awk 'BEGIN {FS = " "} { for ( i = 1;i <= NF;i++ ) { if (i = NF) print $i }  } ')
    local first_insert_instance=$(echo $insert_statment | awk 'BEGIN {FS = ","} { for ( i = 1;i <= 1;i++ ) { if (i = 1) print $i }  } ')
    local first_char=$(echo $first_insert_instance | awk 'BEGIN {FS = ""} { for ( i = 1;i <= 1;i++ ) { if (i = 1) print $i }  } ')
    local input=$*
    local i=$((${#input}-1))
    local last_char=$(echo "${input:$i:1}")
    local flag=0;
    if [[ "$(echo $first_char)" == "(" ]] && [[ "$(echo $last_char)" == ")" ]]
    then
        flag=1
        echo $flag
    else
        echo $flag
    fi
}
removeTable() {
    if [[ $(pwd) != $PARENTDIR ]]
    then
        if [ -f $3 ]
        then
            rm $3
            rm $3.index
            zenity --info --text="tabel $3 removed !"
        else
            zenity --error --text="No tables with this name"
        fi
    else
        zenity --error --text="Select a database first"
        zenity --error --text="You can use show databases to list availabe databases"
    fi
}
showTable() {
    if [[ $(pwd) != $PARENTDIR ]]
    then
        ls -l $(pwd) | awk 'BEGIN{FS=" "}{if($0!="")print $9}'| grep -v .index |zenity --text-info --title="Tables"
    else
        zenity --error --text="Select a database first"
        zenity --info --text="You can use show databases to list availabe databases"
    fi
}
#checks if user is assigned to database and creates a new file for every table
createTable() {
    local primary_key_status
    local code1=$(checkPWD)
    local check
    local check_two
    if [[ $code1 == "$PARENTDIR" ]]; then
        zenity --error --text="You must select database first"
    else
        check=$(checkStatmentFormat $*)
        local table="$(pwd)"/"$3"
        if [[ check -eq 1 ]]; then
            if [ ! -f  $table ]; then
                check_two=$(checkHeaderDataType $*)
                if [[ $check_two == "valid" ]]
                then
                    choosePK $*
                    if [[ $? == 1 ]]
                    then
                        $(touch $3)
                        create=$(setTableHeader $* )
                        zenity --info --text="table $3 created"
                        setPK $*
                    else
                        zenity --error --text="primary_key set failed"
                        zenity --error --text="failed to create table $3"
                    fi
                else
                    zenity --error --text="Non-valid data_types"
                fi
            else
                zenity --error --text="table already exits"
            fi
        else
            zenity --error --text="syntax error"
        fi
    fi
}