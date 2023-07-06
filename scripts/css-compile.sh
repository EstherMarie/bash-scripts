#!/bin/env bash
#
# Description: 
# - Enter css folder, compile and minify scss file passed as argument
# - If no argument is passed, compile all scss files
#
# Usage: bash ~/bash-scripts/css-compile.sh home 


css_compile() {
  scss_files=$(find . -name "*.scss" | sed 's/.*\/\(\w*\).scss$/\1/')
  path_to_css_files=$(find . -name "*.scss" | head -n 1 | sed 's/\w*.scss$//')
  command=""

  if [[ -z $(which sass) ]]; then
    echo -e "Installing Sass..."

    npm install -g sass
  fi

  cd "${path_to_css_files}" || exit

  if [[ "${1}" ]]; then
    echo "Watching ${1}"
    sass --no-source-map --watch "${1}.scss" "./minify/${1}.css" --style compressed
  else
    for file in ${scss_files}; do 
      command="${command} ${file}.scss:./minify/${file}.css"
    done
  fi

  sass --no-source-map --watch ${command} --style compressed
}

css_compile "${@}"
exit 0
