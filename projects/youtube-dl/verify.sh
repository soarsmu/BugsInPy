#!/bin/bash
input="project.info"
githubURL=""
checkfurther="NO"
folder_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
project_location=""
temp_location=""
fail_number=0
pass_number=0
project_name=""
declare -a fail_list
declare -a pass_list

echo $folder_location
while IFS= read -r line
do
  if [[ "$line" == "github_url="* ]]; then
     githubURL="$(cut -d'"' -f 2 <<< $line)"
     echo "$githubURL"
  elif [[ "$line" == 'status="OK"'* ]]; then
     echo "TES"
     checkfurther="YES"
     git clone "$githubURL"
  fi
  echo "$line"
done < "$input"
if [[ "$checkfurther" == "NO" ]]; then
  exit
fi

dirs=($(find . -maxdepth 1 -type d))
for dir in "${dirs[@]}"; do
  if [[ "$dir" != "./bugs" && "$dir" != "." ]]; then
     var="$(cut -d'/' -f 2 <<< $dir)"
     project_location="$folder_location/$var"
     project_name=$var
  fi
done
my_function () {
  run_command_all=""
  DONE=false
  until $DONE ;do
  read || DONE=true
  if [[ "$REPLY" != "" ]]; then
     run_command_all+="$REPLY;"
     echo $REPLY
  fi
  done < run_test.sh
  IFS=';' read -r -a run_command <<< "$run_command_all"
  echo "$run_command"
  DONE=false
  until $DONE ;do
  read || DONE=true
  if [[ "$REPLY" == "buggy_commit_id"* ]]; then
       buggy_commit="$(cut -d'"' -f 2 <<< $REPLY)"
  elif [[ "$REPLY" == "fixed_commit_id"* ]]; then
       fix_commit="$(cut -d'"' -f 2 <<< $REPLY)"
  elif [[ "$REPLY" == "test_file"* ]]; then
       test_file_all="$(cut -d'"' -f 2 <<< $REPLY)"
       IFS=';' read -r -a test_file <<< "$test_file_all"
  fi
  done < bug.info

  #while IFS= read -r line
  #do
  #  if [[ "$line" == "buggy_commit_id"* ]]; then
  #     buggy_commit="$(cut -d'"' -f 2 <<< $line)"
  #  elif [[ "$line" == "fixed_commit_id"* ]]; then
  #     fix_commit="$(cut -d'"' -f 2 <<< $line)"
  #  elif [[ "$line" == "test_file"* ]]; then
  #     test_file="$(cut -d'"' -f 2 <<< $line)"
  #  fi
  #  echo "$line"
  #done < "bug.info.txt"
  #while IFS= read -r line
  #do
  #  echo "$line"
  #  run_command="$line"
  #done < "run_test.sh"
  echo "$buggy_commit"
  echo "$fix_commit"
  printf "%s\n" "${test_file[@]}"
  echo "BARRR"
  for index in "${!run_command[@]}"
  do
     echo ${run_command[index]}
  done
  cd "$project_location"
  source env/bin/activate
  git reset --hard "$fix_commit"
  pip install -r "$temp_location/requirements.txt"

  run_command_filter=""
  for index in "${!run_command[@]}"
  do
  run_command_now=${run_command[index]}
  
  echo "RUN EVERY COMMAND"
  echo "$index"
  echo "$run_command_now"
  echo "$test_file_now"
  
  res_first=$($run_command_now 2>&1)

  echo "$res_first"
  if [[ ${res_first##*$'\n'} == *"OK"* || ${res_first##*$'\n'} == *"pass"* ]]; then
     run_command_filter+="$run_command_now;"
  else
     fail_list+=("$temp_location ($run_command_now)")
     fail_number=$(($fail_number + 1))
  fi
  done

  for index in "${!test_file[@]}"
  do
     test_file_now=${test_file[index]}
     cp -v "$project_location/$test_file_now" "$temp_location"
  done
  git reset --hard "$buggy_commit"
  
  for index in "${!test_file[@]}"
  do
     test_file_now=${test_file[index]}
     string1="${test_file_now%/*}"
     string2="${test_file_now##*/}"
     mv -f  "$temp_location/$string2" "$project_location/$string1"
  done

  pip install -r "$temp_location/requirements.txt"
  
  
  IFS=';' read -r -a run_command_2 <<< "$run_command_filter"
  for index in "${!run_command_2[@]}"
  do
     run_command_now=${run_command_2[index]}
     res_second=$($run_command_now 2>&1)
     echo "$res_second"
     if [[ ${res_second##*$'\n'} == *"FAIL"* || ${res_second##*$'\n'} == *"error"* || ${res_second##*$'\n'} == *"fail"* ]]; then
         pass_list+=("$temp_location ($run_command_now)")
         pass_number=$(($pass_number + 1))
     else
         fail_list+=("$temp_location ($run_command_now)")
         fail_number=$(($fail_number + 1))       
     fi
  done
  

  #echo "$temp_location"
  #echo "INSIDE"
  #echo "$folder_location"
}
cd "$project_name"
pwd
python -m venv env
source env/bin/activate
cd ..
cd "bugs"
dirs=($(find . -maxdepth 1 -type d))
for dir in "${dirs[@]}"; do
  if [[ "$dir" != "." ]]; then
     var="$(cut -d'/' -f 2 <<< $dir)"
     temp_location="$folder_location/bugs/$var"
     cd "$temp_location"
     pwd
     my_function
  fi
done
for dir in "${pass_list[@]}"; do
  echo "$dir"
done
cd "$folder_location"

printf "%s\n" "${fail_list[@]}" > "$project_name-fail.txt"
printf "%s\n" "${pass_list[@]}" > "$project_name-pass.txt"

echo "PASS: $pass_number" &>>"$project_name-pass.txt"
echo "FAIL: $fail_number" &>>"$project_name-fail.txt" 
#find . -type d -print0 | xargs -0 -L1 sh -c 'cd "$0" && pwd && echo "$folder_location"'

