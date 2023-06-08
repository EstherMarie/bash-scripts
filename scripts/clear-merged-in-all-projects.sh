#!/bin/bash
# 
# Description: 
# - List all git subdirectories
# - Access all listed repositories and ask to fetch, prune and clear merged branches
#
# Usage: bash ~/bash-scripts/clear-merged-in-all-projects.sh


function clear() {
  should_clear_merged="n"
  total_projects=$(find -type d -path "*/.git" | wc -l)
  current_project=1
  updated_projects=0
  green_color="\033[0;32m"

  for project in $(find -type d -path "*/.git" | sed -E 's|.\/(.*)\/.git|\1|g'); do 
    echo ""
    read -p "[$current_project/$total_projects] Update and clear merged branchs of $project? [y / n] " should_clear_merged
    ((current_project++))

    if [ $should_clear_merged == 'y' ]; then
      cd $project
      git branch
      git checkout dev
      git fetch -p 
      git branch --merged | grep -v "dev" | grep -v "main" | grep -v "master" | xargs --no-run-if-empty git branch -d
      cd ..
      ((updated_projects++))
    fi
  done

  echo -e "\n${green_color}Finished! Updated $updated_projects project(s)!\n"
}

clear

exit 0



# ## Some interesting notes:
#
# Unfortunatelly it's not possible to pipe things to git commands, but these notes might be useful someday.
#
# git_password=""
# 
# read -s -p "Enter your password (optional): " git_password
# *** The command above uses de `-s` flag to hide user input on terminal.
#
# [ $git_password != "" ] && { echo "$git_password"; }
# *** This is a conditional! Read this page to understand:
# *** https://mange.ifrn.edu.br/shell-script-wikipedia/12-if-else.html#if-else
#
# =====
#
# ## Explaining find and sed commands
#
# find -type d -path "*/.git" | sed -E 's/.\/(.*)\/.git/\1/g'
#
# * find: 
# - search for directories (-type d) that contains a .git subdirectory
#
# * sed: 
# - use extended regular expressions in the script (-E)
# - 's|.\/(.*)\/.git|\1|g' 
#   - sed allows to use almost any character as a separator. So, using | instead of / can keep the command readable.
#   - First, capture everything (use .* inside parentheses) that is not a '.', '/' (remember to scape: \/) and '/.git' (\/.git).
#   - Then replace current string with captured group (\1)
