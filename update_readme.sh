#!/bin/bash
folder_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "projects"
declare -A count
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
    echo "TES2"
    if [[ ${count[only_name]+abc} == "abc" ]]; then
       echo "TES3"
       temp=count[$only_name]
       echo "$temp"
       num=$((temp + pass))
       count[$only_name]=$num
    else
       echo "TES4"
       temp=0
       num=$((temp + pass))
       count[$only_name]=$num
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

echo "TESSS"
countAll=""
for index in "${!count[@]}"
do
  temp=${count[$index]}
  temp2=$index
  countAll+="$temp:$temp2;"
done
IFS=';' read -r -a count_fix <<< "$countAll"
IFS=$'\n' sorted=($(sort <<<"${count_fix[*]}")); unset IFS


echo "# BugsInPy" > README.md
echo "BugsInPy: Benchmarking Bugs in Python Projects" >> README.md
echo "##  Top 3 Contributors (of all time)" >> README.md
echo "Name | Bugs Data" >> README.md
echo "--- | --- " >> README.md
maxNumber=3
now=0
add=1
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
