#!/bin/bash
folder_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
date=$(date %m-%d-%Y)
lastweek=$(date +%m-%d-%Y -d "$date - 7 day")
echo $lastweek
echo $date
cd "projects"
declare -A count
declare -A count_week

add=1
my_function () {
  if [[ -f "$var-pass.txt" ]]; then
    DONE=false
    until $DONE ;do
    read || DONE=true
       if [[ "$REPLY" == "PASS:"* ]]; then
           pass="$(cut -d':' -f 2 <<< $REPLY)"
       fi
    done < "$var-pass.txt"
    name=$(git shortlog -sn "$var-pass.txt" 2>&1 | head -n 1)
    echo $name
    echo $pass
    only_name="${name#*	}"
    if [[ $only_name != "" ]]; then
    echo $only_name
    if [[ ${count[only_name]+abc} == "abc" ]]; then
       temp=count[$only_name]
       echo "$temp"
       num=$((temp + pass))
       count[$only_name]=$num
    else
       temp=0
       num=$((temp + pass))
       count[$only_name]=$num
    fi
    fi

    name=$(git shortlog -sn --since="$lastweek" "$var-pass.txt" 2>&1 | head -n 1)
    
    echo $name_tes
    pass=0
    only_name="${name#*	}"
    logAll=""
    if [[ $only_name != "" ]]; then
    DONE=false
    until $DONE ;do
    read || DONE=true
       if [[ "$REPLY" != "PASS:"* && "$REPLY" != "" ]]; then
           echo "$REPLY"
           folder="$(cut -d'(' -f 1 <<< $REPLY)"
           string2="${folder##*/}"
           string3="$(cut -d' ' -f 1 <<< $string2)"
           logAll+="$string3;"
       fi
    done < "$var-pass.txt"
    IFS=';' read -r -a log <<< "$logAll"
    for index in "${log[@]}"
    do
       check_name=$(git shortlog -sn --since="$lastweek" "bugs/$index/run_test.sh" 2>&1 | head -n 1)
       echo "$check_name"
       if [[ $check_name != "" ]]; then
           pass=$((pass + add))
       fi
    done
           
    echo $only_name
    if [[ $pass != 0 ]]; then
    if [[ ${count_week[only_name]+abc} == "abc" ]]; then
       temp=count_week[$only_name]
       echo "$temp"
       num=$((temp + pass))
       count_week[$only_name]=$num
    else
       temp=0
       num=$((temp + pass))
       count_week[$only_name]=$num
    fi
    fi
    fi
  fi
}

dirs=($(find . -maxdepth 1 -type d))
for dir in "${dirs[@]}"; do
  if [[ "$dir" != "." ]]; then
     var="$(cut -d'/' -f 2 <<< $dir)"
     temp_location="$folder_location/projects/$var"
     cd "$temp_location"
     pwd
     my_function
  fi
done
cd $folder_location

countAll=""
for index in "${!count[@]}"
do
  temp=${count[$index]}
  temp2=$index
  countAll+="$temp:$temp2;"
done
IFS=';' read -r -a count_fix <<< "$countAll"
IFS=$'\n' sorted=($(sort <<<"${count_fix[*]}")); unset IFS

countAllWeek=""
for index in "${!count_week[@]}"
do
  temp=${count_week[$index]}
  temp2=$index
  countAllWeek+="$temp:$temp2;"
done
IFS=';' read -r -a count_fix_week <<< "$countAllWeek"
IFS=$'\n' sorted_week=($(sort <<<"${count_fix_week[*]}")); unset IFS

echo "# BugsInPy" > README.md
echo "BugsInPy: Benchmarking Bugs in Python Projects" >> README.md
echo "##  Top 3 Contributors (of all time)" >> README.md
echo "Name | Bugs Data" >> README.md
echo "--- | --- " >> README.md
maxNumber=3
now=0
for index in "${sorted[@]}"
do
  if [[ $now != $maxNumber ]]; then
  string1="$(cut -d':' -f 1 <<< $index)"
  string2="${index#*:}"
  echo "$string1"
  echo "$string2"
  echo "$string2 | $string1 " >> README.md
  now=$((now+add))
  fi
done

echo "##  Top 3 Contributors (this week)" >> README.md
echo "Name | Bugs Data" >> README.md
echo "--- | --- " >> README.md
maxNumber=3
now=0
for index in "${sorted_week[@]}"
do
  if [[ $now != $maxNumber ]]; then
  string1="$(cut -d':' -f 1 <<< $index)"
  string2="${index#*:}"
  echo "$string1"
  echo "$string2"
  echo "$string2 | $string1 " >> README.md
  now=$((now+add))
  fi
done
