#!/bin/env bash
#
# Description: Enter css folder, compile and minify scss file passed as argument
# Usage: bash ~/bash-scripts/css-compile.sh home 

cd custom/css/
sass --no-source-map --watch $1.scss ./minify/$1.css --style compressed
