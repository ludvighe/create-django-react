#!/bin/bash

# Consts
NC="\033[0m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"

NAME=$1

SCRIPT_ROOT_PATH="$(pwd)"
LOG="$SCRIPT_ROOT_PATH/LOG"

# Script setup
if [ -f "$SCRIPT_ROOT_PATH/create_django_react.sh" ]; then
  run=1
else 
  echo "Please call this script from the same folder" && exit
fi

while [ -z "$NAME" ]; do
  echo "Please enter the name of the project"
  read NAME
done

cleanup_exit () {
  if [ -f "$LOG" ]; then
    cat $LOG
    rm $LOG
  fi
  echo "Exiting"
  exit $run
}

# Function wrapper to catch stdout and stderr and put in $LOG
fn () {
  [ $run == 1 ] && $1 &>$LOG || run=0
}

touch $LOG || cleanup_exit
cd $SCRIPT_ROOT_PATH
fn "rm -rf .git"

# Check dependencies
echo -e "Checking dependencies..."

dependencies=("python3" "pip3" "pipenv" "django-admin" "npm" "npx")
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


echo ""


# Django - setup
title="[1/2] Django - setup:"
echo -en "$title$YELLOW Setting up... $NC\r"
fn "django-admin startproject $NAME"
fn "cd $NAME"
fn "django-admin startapp api"
fn "python3 manage.py migrate"

[ $run == 0 ] && echo -e "$title$RED Failed $NC        " && echo -e "$RED""Could not set up django$NC" && cleanup_exit
[ $run == 1 ] && echo -e "$title$GREEN Done $NC        "



# Pipenv - setup
title="[2/2] Django - pipenv setup"
echo -en "$title$YELLOW Setting up... $NC\r"

cd "$SCRIPT_ROOT_PATH/$NAME"
fn "pipenv install django"

[ $run == 0 ] && echo -e "$title$RED Failed $NC         " && echo -e "$RED""Could not set up Django/React integration$NC" && cleanup_exit
[ $run == 1 ] && echo -e "$title$GREEN Done $NC         "



# React - setup
title="[1/3] React - setup:"
echo -en "$title$YELLOW Setting up... $NC\r"

cp -r "$SCRIPT_ROOT_PATH/frontend" "$SCRIPT_ROOT_PATH/$NAME" || run=0

[ $run == 0 ] && echo -e "$title$RED Failed $NC        " && echo -e "$RED""Could not set up react$NC" && cleanup_exit
[ $run == 1 ] && echo -e "$title$GREEN Done $NC        "



# React - installing npm packages
title="[2/3] React - installing npm packages:"
echo -en "$title$YELLOW Installing... $NC\r"
cd "$SCRIPT_ROOT_PATH/$NAME/frontend"
fn "npm install"

[ $run == 0 ] && echo -e "$title$RED Failed $NC        " && echo -e "$RED""Could not set up react$NC" && cleanup_exit
[ $run == 1 ] && echo -e "$title$GREEN Done $NC        "



# React - build
title="[3/3] React - build:"
echo -en "$title$YELLOW Building... $NC\r"

fn "npm run build"

[ $run == 0 ] && echo -e "$title$RED Failed $NC        " && echo -e "$RED""Could not set up react$NC" && cleanup_exit
[ $run == 1 ] && echo -e "$title$GREEN Done $NC        "


echo ""


# Django / React Integrations
title="Django/React - integration:"
echo -en "$title$YELLOW Integrating... $NC\r"

## settings.py - TEMPLATE, STATICFILES
cd "$SCRIPT_ROOT_PATH/$NAME/$NAME"
input=$(cat settings.py)
search="'DIRS': [],"
replace="'DIRS': [ os.path.join(BASE_DIR, 'frontend/build') ],"
output="${input//"$search"/"$replace"}"

search="from pathlib import Path"
replace="from pathlib import Path\nimport os"
output="${output//"$search"/"$replace"}"

search="STATIC_URL = '/static/'"
replace="STATIC_URL = '/static/'\n\nSTATICFILES_DIRS = [ os.path.join(BASE_DIR, 'frontend/build/static') ]\n"
output="${output//"$search"/"$replace"}"

echo -e "$output" > settings.py || run=0

## urls.py - TemplateView
cd "$SCRIPT_ROOT_PATH/$NAME/$NAME"
input=$(cat urls.py)
search="from django.urls import path"
replace="from django.urls import path\nfrom django.views.generic import TemplateView"
output="${input//"$search"/"$replace"}"

search="path('admin/', admin.site.urls),"
replace="path('admin/', admin.site.urls),\n    path('', TemplateView.as_view(template_name='index.html'))"
output="${output//"$search"/"$replace"}"

echo -e "$output" > urls.py || run=0

[ $run == 0 ] && echo -e "$title$RED Failed $NC         " && echo -e "$RED""Could not set up Django/React integration$NC" && cleanup_exit
[ $run == 1 ] && echo -e "$title$GREEN Done $NC         "



# Git - setup
title="Git:"
echo -en "$title$YELLOW Setting up... $NC\r"

cd "$SCRIPT_ROOT_PATH/$NAME"
fn "git init"
cp $SCRIPT_ROOT_PATH/.gitignore core/ || run=0

[ $run == 0 ] && echo -e "$title$RED Failed $NC        " && echo -e "$RED""Could not set up react$NC" && cleanup_exit
[ $run == 1 ] && echo -e "$title$GREEN Done $NC        "

echo ""

# Cleanup
echo -en "$YELLOW""Cleaning up...""$NC\r"
cd $SCRIPT_ROOT_PATH
fn "rm -r frontend"
fn "rm LOG .gitignore README.md $0"

echo -e "$GREEN""You're all set up!""$NC"
