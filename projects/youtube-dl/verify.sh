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
#check project info
echo $folder_location
while IFS= read -r line
do
  if [[ "$line" == "github_url="* ]]; then
     githubURL="$(cut -d'"' -f 2 <<< $line)"
     echo "$githubURL"
     githubName="${githubUrl##*/}"
     if [[ "$githubName" == "" ]]; then
         temp="${githubUrl%?}"
         githubName="${temp##*/}"
     fi
  elif [[ "$line" == 'status="OK"'* ]]; then
     checkfurther="YES"
     #clone project if status OK
     git clone "$githubURL"
  fi
  echo "$line"
done < "$input"
if [[ "$checkfurther" == "NO" ]]; then
  exit
fi

#get project name
dirs=($(find . -maxdepth 1 -type d))
for dir in "${dirs[@]}"; do
  if [[ "$dir" != "./bugs" && "$dir" != "." && "$dir" == *"$githubName"* ]]; then
     var="$(cut -d'/' -f 2 <<< $dir)"
     project_location="$folder_location/$var"
     project_name=$var
  fi
done

#function for verifying bugs
my_function () {
  rm -f "$folder_location/$project_name-$var-fail.txt"
  #read file run_test.sh
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
  
  #read bug.info file
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
  elif [[ "$REPLY" == "pythonpath"* ]]; then
       pythonpath_all="$(cut -d'"' -f 2 <<< $REPLY)"
       temp_folder=":${folder_location}/"
       pythonpath_set=${pythonpath_all//;/$temp_folder}
       pythonpath_set="${folder_location}/${pythonpath_set}"
  fi
  done < bug.info
  
  #read setup.sh
  run_setup_all=""
  if [[ -f "setup.sh" ]]; then
    DONE=false
    until $DONE ;do
    read || DONE=true
       run_setup_all+="$REPLY;"
       echo $REPLY
    done < setup.sh
  fi
  
  IFS=';' read -r -a run_setup <<< "$run_setup_all"

  echo "$buggy_commit"
  echo "$fix_commit"
  printf "%s\n" "${test_file[@]}"
  for index in "${!run_command[@]}"
  do
     echo ${run_command[index]}
  done
  #add pythonpath if does not exist
  if [[ "$pythonpath_set" != "" ]]; then
     echo $pythonpath_set
     if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        echo "READ BASH"
        saveReply=""
        pythonpath_exist="NO"
        should_change="NO"
        DONE=false
        until $DONE ;do
        read || DONE=true
        if [[ "$pythonpath_exist" == "YES" ]]; then
            if [[ "$REPLY" != "export PYTHONPATH"* ]]; then
               should_change="YES"
               echo "export PYTHONPATH" >>"TES.txt"
            fi
            pythonpath_exist="YES1"
        fi
        if [[ "$REPLY" == "PYTHONPATH="* ]]; then
            pythonpath_exist="YES"
            tes='"'
            if [[ "$REPLY" != *"$pythonpath_set:"* ]]; then
               should_change="YES"
               echo $REPLY
               saveReply=$REPLY
               string1="${REPLY%:*}"
               string2="${REPLY##*:}"
               if [[ "$string2" == *"PYTHONPATH"* ]]; then
                  echo "$string1:$pythonpath_set:$string2" >>"TES.txt"
               else
                  temp="$"
                  temp_py="PYTHONPATH"
                  temp2=${REPLY%$tes*}
                  echo "$temp2:$pythonpath_set:$temp$temp_py$tes" >>"TES.txt"
               fi
            fi
        else
            echo "$REPLY" >>"TES.txt"   
        fi 
        done <  ~/.bashrc 
        if [[ "$pythonpath_exist" == "NO" ]]; then
            should_change="NO"
            echo 'PYTHONPATH="$pythonpath_set:$PYTHONPATH"' >> ~/.bashrc 
            echo "export PYTHONPATH" >> ~/.bashrc 
            source ~/.bashrc
        fi
        if [[ "$should_change" == "YES" ]]; then
            echo "SHOULD CHANGE"
            sed -i.bak '/PYTHONPATH=/d' ~/.bashrc
            if [[ "$pythonpath_exist" == "YES1" ]]; then
                sed -i.bak '/export PYTHONPATH/d' ~/.bashrc
            fi
            string1="${saveReply%:*}"
            string2="${saveReply##*:}"
            if [[ "$string2" == *"PYTHONPATH"* ]]; then
               echo "$string1:$pythonpath_set:$string2" >> ~/.bashrc
            else
               temp="$"
               temp_py="PYTHONPATH"
               temp2=${saveReply%$tes*}
               echo "$temp2:$pythonpath_set:$temp$temp_py$tes" >> ~/.bashrc
            fi
            echo "export PYTHONPATH" >> ~/.bashrc
            source ~/.bashrc
        fi
        
        rm TES.txt
        #echo 'export APP=/opt/tinyos-2.x/apps' >> ~/.bashrc 
      fi

  fi
  #go to project location
  cd "$project_location"
  if [ -d "$folder_location/$project_name/env/Scripts" ]; then
      source env/Scripts/activate
  else
      source env/bin/activate
  fi
  
  #reset to fix commit and install the requirement based on requirements.txt in bugs
  git reset --hard "$fix_commit"
  
  #run from setup.sh
  for index in "${!run_setup[@]}"
  do
     run_setup_trail=${run_setup[index]} 
     run_setup_now=$(echo $run_setup_trail | sed -e 's/\r//g')
     echo "$run_setup_now"
     $run_setup_now
  done
  
  pip install -r "$temp_location/requirements.txt"

  #run every command on the run_test.sh
  run_command_filter=""
  for index in "${!run_command[@]}"
  do
  run_command_trail=${run_command[index]} 
  
  echo "RUN EVERY COMMAND"
  echo "$index"
  echo "$run_command_now"
  echo "$test_file_now"
  run_command_now=$(echo $run_command_trail | sed -e 's/\r//g')
  
  res_first=$($run_command_now 2>&1)
  #update list for command if running output OK and write on the fail if not
  echo "$res_first"
  if [[ ${res_first##*$'\n'} == *"OK"* || ${res_first##*$'\n'} == *"pass"* || $res_first == *"passed"* ]]; then
     run_command_filter+="$run_command_now;"
  else
     fail_list+=("$temp_location ($run_command_now)")
     fail_number=$(($fail_number + 1))
     echo "OUTPUT AT FIXED COMMIT ID" &>>"$folder_location/$project_name-$var-fail.txt"
     echo "$run_command_now" &>>"$folder_location/$project_name-$var-fail.txt"
     echo "$res_first" &>>"$folder_location/$project_name-$var-fail.txt"
  fi
  done

  #copy test file from project to bugs folder
  for index in "${!test_file[@]}"
  do
     test_file_now=${test_file[index]}
     cp -v "$project_location/$test_file_now" "$temp_location"
  done

  #reset to buggy commit
  git reset --hard "$buggy_commit"
  
  #move test file from bugs folder to project
  for index in "${!test_file[@]}"
  do
     test_file_now=${test_file[index]}
     string1="${test_file_now%/*}"
     string2="${test_file_now##*/}"
     mv -f  "$temp_location/$string2" "$project_location/$string1"
  done
  
  #run from setup.sh
  for index in "${!run_setup[@]}"
  do
     run_setup_trail=${run_setup[index]} 
     run_setup_now=$(echo $run_setup_trail | sed -e 's/\r//g')
     echo "$run_setup_now"
     $run_setup_now
  done

  #install the requirement from requirements.txt in bugs folder
  pip install -r "$temp_location/requirements.txt"
  
  #run every command that output ok from before
  IFS=';' read -r -a run_command_2 <<< "$run_command_filter"
  for index in "${!run_command_2[@]}"
  do
     run_command_trail=${run_command_2[index]}
     run_command_now=$(echo $run_command_trail | sed -e 's/\r//g')
  
     res_second=$($run_command_now 2>&1)
     echo "$res_second"
     if [[ ${res_second##*$'\n'} == *"FAIL"* || ${res_second##*$'\n'} == *"error"* || ${res_second##*$'\n'} == *"fail"* || $res_second == *"failed"* ]]; then
         pass_list+=("$temp_location ($run_command_now)")
         pass_number=$(($pass_number + 1))
     else
         fail_list+=("$temp_location ($run_command_now)")
         fail_number=$(($fail_number + 1))
         echo "OUTPUT AT BUGGY COMMIT ID" &>>"$folder_location/$project_name-$var-fail.txt"
         echo "$run_command_now" &>>"$folder_location/$project_name-$var-fail.txt"
         echo "$res_first" &>>"$folder_location/$project_name-$var-fail.txt"       
     fi
  done
  
}

#go to project folder and activate the env
cd "$project_name"
pwd
python -m venv env
if [ -d "$folder_location/$project_name/env/Scripts" ]; then
  source env/Scripts/activate
else
  source env/bin/activate
fi
cd ..
cd "bugs"
#loop for every bugs, calling funct.
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

#print fail and pass on the file txt
printf "%s\n" "${fail_list[@]}" > "$project_name-fail.txt"
printf "%s\n" "${pass_list[@]}" > "$project_name-pass.txt"

echo "PASS: $pass_number" &>>"$project_name-pass.txt"
echo "FAIL: $fail_number" &>>"$project_name-fail.txt" 
