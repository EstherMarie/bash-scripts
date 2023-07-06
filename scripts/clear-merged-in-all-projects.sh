#!/bin/bash
# 
# Description: 
# - List all git subdirectories
# - Access all listed repositories and ask to fetch, prune and clear merged branches
#
# Usage: bash ~/bash-scripts/clear-merged-in-all-projects.sh


function clear() {
  should_clear_merged="n"
  total_projects=$(find . -type d -path "*/.git" | wc -l)
  current_project=1
  updated_projects=0
  green_color="\033[0;32m"

  for project in $(find . -type d -path "*/.git" | sed -E 's|.\/(.*)\/.git|\1|g'); do
    echo ""
    read -p "[${current_project}/${total_projects}] Update and clear merged branchs of ${project}? [y / n] " should_clear_merged
    ((current_project++))

    if [ "${should_clear_merged}" == "y" ]; then
      cd "${project}" || exit
      git branch
      git checkout dev
      git fetch -p 
      git branch --merged | grep -v "dev" | grep -v "main" | grep -v "master" | xargs --no-run-if-empty git branch -d
      cd ..
      ((updated_projects++))
    fi
  done

  echo -e "\n${green_color}Finished! Updated ${updated_projects} project(s)!\n"
}

clear

exit 0
