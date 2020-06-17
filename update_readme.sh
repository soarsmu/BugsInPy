#!/bin/bash
folder_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
date=$(date %m-%d-%Y)
lastweek=$(date +%m-%d-%Y -d "$date - 7 day")
echo $lastweek
echo $date
cd "projects"
declare -A count
declare -A count_week
declare -A count_all
declare -A count_all_week
verified_bugs=0
all_bugs=0
add=1
my_function () {
  #pass_all=$(find bugs/* -maxdepth 0 -type d 2>&1 | wc -l)
  dirs=($(find bugs/* -maxdepth 0 -type d))
  for dir in "${dirs[@]}"; do
     bug_location="$temp_location/$dir"
     cd $bug_location
     check_name_all=$(git shortlog -sn requirements.txt 2>&1 | head -n 1)
     if [[ $check_name_all == "fatal: "* ]]; then
         check_name_all=$(git shortlog -sn run_test.sh 2>&1 | head -n 1)
     fi
     if [[ $check_name_all == "fatal: "* ]]; then
         check_name_all=$(git shortlog -sn bug.info 2>&1 | head -n 1)
     fi
     if [[ $check_name_all == "fatal: "* ]]; then
         check_name_all=""
     fi
     only_name="${check_name_all#*	}"
     if [[ $only_name != "" ]]; then
       #echo "PRINT NAME"
       #echo $only_name
       all_bugs=$((all_bugs + add))
       if [[ ${count_all[only_name]+abc} == "abc" ]]; then
          temp=count_all[$only_name]
          #echo "$temp"
          num=$((temp + add))
          count_all[$only_name]=$num
       else
          temp=count_all[$only_name]
          num=$((temp + add))
          count_all[$only_name]=$num
       fi
     fi
     pwd
     check_name_all_week=$(git shortlog -sn --since="$lastweek" requirements.txt 2>&1 | head -n 1)
     if [[ $check_name_all_week == "fatal: "* ]]; then
         check_name_all_week=$(git shortlog -sn --since="$lastweek" run_test.sh 2>&1 | head -n 1)
     fi
     if [[ $check_name_all_week == "fatal: "* ]]; then
         check_name_all_week=$(git shortlog -sn --since="$lastweek" bug.info 2>&1 | head -n 1)
     fi
     if [[ $check_name_all_week == "fatal: "* ]]; then
         check_name_all_week=""
     fi
     only_name="${check_name_all_week#*	}"
     if [[ $only_name != "" ]]; then
       #echo "PRINT NAME WEEK"
       #echo $only_name
       if [[ ${count_all_week[only_name]+abc} == "abc" ]]; then
          temp=count_all_week[$only_name]
          #echo "$temp"
          num=$((temp + add))
          count_all_week[$only_name]=$num
       else
          temp=count_all_week[$only_name]
          num=$((temp + add))
          count_all_week[$only_name]=$num
       fi
     fi
  done
  cd $temp_location

  if [[ -f "$var-pass.txt" ]]; then
    pass=0
    pass_all=0
    check=0
    logAll=""
    DONE=false
    until $DONE ;do
    read || DONE=true
       if [[ "$REPLY" != "PASS:"* && "$REPLY" != "" ]]; then
           echo "$REPLY"
           folder="$(cut -d'(' -f 1 <<< $REPLY)"
           echo "$folder"
           string2="${folder##*/}"
           string3="$(cut -d' ' -f 1 <<< $string2)"
           if [[ $logAll != *";$string3;"* ]]; then 
               if [[ $logAll != "$string3;" ]]; then
               logAll+="$string3;"
               check=$((check+add))
               echo "$string3"
               fi
           fi
       fi
    done < "$var-pass.txt"

    echo "$check"
    IFS=';' read -r -a log <<< "$logAll"
    for index in "${log[@]}"
    do
       echo "$index"
       check_name=$(git shortlog -sn "bugs/$index/run_test.sh" 2>&1 | head -n 1)
       if [[ $check_name == "fatal: "* ]]; then
           check_name=$(git shortlog -sn "bugs/$index/requirements.txt" 2>&1 | head -n 1)
       fi
       if [[ $check_name == "fatal: "* ]]; then
           check_name=$(git shortlog -sn "bugs/$index/bug.info" 2>&1 | head -n 1)
       fi
       if [[ $check_name == "fatal: "* ]]; then
           check_name=""
       fi
       if [[ $check_name != "" ]]; then
           only_name="${check_name#*	}"
           #echo "$only_name"
           temp=count[$only_name]
           #echo "$temp"
           num=$((temp + add))
           count[$only_name]=$num
           pass_all=$((pass_all + add))
           #echo "$num"
           #echo "$pass_all"
       fi

       check_name=$(git shortlog -sn --since="$lastweek" "bugs/$index/run_test.sh" 2>&1 | head -n 1)
       if [[ $check_name == "fatal: "* ]]; then
           check_name=$(git shortlog -sn --since="$lastweek" "bugs/$index/requirements.txt" 2>&1 | head -n 1)
       fi
       if [[ $check_name == "fatal: "* ]]; then
           check_name=$(git shortlog -sn --since="$lastweek" "bugs/$index/bug.info" 2>&1 | head -n 1)
       fi
       if [[ $check_name == "fatal: "* ]]; then
           check_name=""
       fi
       #echo "$check_name"
       if [[ $check_name != "" ]]; then
           only_name="${check_name#*	}"
           temp=count_week[$only_name]
           #echo "$temp"
           num=$((temp + add))
           count_week[$only_name]=$num
           pass=$((pass + add))
       fi
    done
    
    verified_bugs=$((verified_bugs + pass_all))  
    
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
for index in "${!count[@]}"
do
  temp=${count[$index]}
  temp2=$index
  echo "$temp $temp2"
done

countAll=""
for index in "${!count_all[@]}"
do
  temp=${count_all[$index]}
  temp2=$index
  countAll+="$temp:$temp2;"
done
echo "$countAll"
IFS=';' read -r -a count_fix <<< "$countAll"
IFS=$'\n' sorted=($(sort -n -r <<<"${count_fix[*]}")); unset IFS

countAllWeek=""
for index in "${!count_all_week[@]}"
do
  temp=${count_all_week[$index]}
  temp2=$index
  countAllWeek+="$temp:$temp2;"
done
IFS=';' read -r -a count_fix_week <<< "$countAllWeek"
IFS=$'\n' sorted_week=($(sort -n -r <<<"${count_fix_week[*]}")); unset IFS

echo "# BugsInPy" > README.md
echo "BugsInPy: Benchmarking Bugs in Python Projects" >> README.md
echo "##  Top 3 Contributors (of all time)" >> README.md
echo "Name | Bugs Data | Verified Bugs Data" >> README.md
echo "--- | --- | --- " >> README.md
maxNumber=3
now=0
for index in "${sorted[@]}"
do
  if [[ $now != $maxNumber ]]; then
  string1="$(cut -d':' -f 1 <<< $index)"
  string2="${index#*:}"
  string3="${count[$string2]}"
  string3=$((string3 + 0))
  echo "$string1"
  echo "$string2"
  echo "$string3"
  echo "$string2 | $string1 | $string3" >> README.md
  now=$((now+add))
  fi
done

echo "##  Top 3 Contributors (last week)" >> README.md
echo "Name | Bugs Data | Verified Bugs Data" >> README.md
echo "--- | --- | --- " >> README.md
maxNumber=3
now=0
for index in "${sorted_week[@]}"
do
  if [[ $now != $maxNumber ]]; then
  string1="$(cut -d':' -f 1 <<< $index)"
  string2="${index#*:}"
  echo "$string1"
  echo "$string2"
  string3="${count_week[$string2]}"
  string3=$((string3 + 0))
  echo "$string2 | $string1 | $string3" >> README.md
  now=$((now+add))
  fi
done

echo "#### Total data : $all_bugs" >> README.md
echo "#### Total verified bugs data : $verified_bugs" >> README.md
echo "###### Note: this list is based on the dataset bug without verifying the data. We will update this list of contributors based on the output of verify.sh that you pushed on the repo." >> README.md


