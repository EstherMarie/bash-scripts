#!/bin/bash
#
# Description: Delete merged branchs that aren't main, master or dev
# Usage: bash ~/bash-scripts/git-delete-merged.sh 

git checkout dev
git fetch -p
git branch --merged | grep -v "dev" | grep -v "main" | grep -v "master" | xargs git branch -d
