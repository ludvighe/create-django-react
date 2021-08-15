#!/bin/bash

NC="\033[0m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"

# Check dependencies
echo -e "Checking dependencies..."

dependencies=("python3" "pip3" "wget" "django-admin" "npm" "npx")
dependencies_length=$(wc -w <<< ${dependencies[@]})

run=1
i=1
for dependency in "${dependencies[@]}"
do
  echo -en "[$i/$dependencies_length] $dependency:$YELLOW Checking... $NC\r" &&
    $dependency --version > /dev/null 2>&1  &&
    echo -e "[$i/$dependencies_length] $dependency:$GREEN OK $NC        " &&
    i=$((i+1)) || run=0
  
  [ $run == 0 ] && 
    echo -e "[$i/$dependencies_length] $dependency:$RED Failed... $NC     " && 
    echo -e "$RED$dependency not installed$NC\nExiting" && 
    exit
done

# Script setup
SCRIPT_ROOT_PATH="$(pwd)/$1_wrapper"
LOG="$SCRIPT_ROOT_PATH/LOG"
run=1

cleanup_exit () {
  if [ -f "$LOG" ]; then
    cat $LOG
    rm $LOG
  fi
  echo "Exiting"
  exit
}

# Function wrapper to catch stdout and stderr and put in $LOG
fn () {
  [ $run == 1 ] && $1 &>$LOG || run=0
}

mkdir $SCRIPT_ROOT_PATH && cd $SCRIPT_ROOT_PATH && touch $LOG || cleanup_exit



# Django setup
run=1
echo -en "Django:$YELLOW Setting up... $NC\r"
fn "django-admin startproject $1"
cd $1
fn "django-admin startapp api"
# fn "django-admin startapp frontend"

[ $run == 0 ] && echo -e "Django:$RED Failed $NC        " && echo -e "$RED""Could not set up django$NC" && cleanup_exit
[ $run == 1 ] && echo -e "Django:$GREEN Done $NC        "

# React setup
run=1
echo -en "React:$YELLOW Setting up... $NC\r"
# fn "npx create-react-app frontend"
[ $run == 0 ] && echo -e "React:$RED Failed $NC        " && echo -e "$RED""Could not set up react$NC" && cleanup_exit
[ $run == 1 ] && echo -e "React:$GREEN Done $NC        "

cleanup_exit