#!/bin/bash
#
# Description: Check for SSL certificates with less than 30 days to expire
#
# Usage: ~/path/to/ssl-check.sh sites.txt


green_color="\033[0;32m"
yellow_color="\033[1;33m"
need_new_certificate="${green_color}For now, everything is fine!"

ssl_check() {
  while IFS= read -r line; do
    expire_date=$(curl -Iv "$line" --stderr - | grep "expire date" | cut -d":" -f 2- | date -f - "+%s")
    difference_in_days=$(( (expire_date - $(date "+%s")) / (60*60*24) ))

    echo "$line"
    curl -Iv "$line" --stderr - | grep "expire date"
    echo ""

    if [[ $difference_in_days -le 30 ]]; then
      need_new_certificate="${yellow_color}${line}"
    fi
  done < "${1}"

  echo -e "\nSites whose certificates need to be renewed:"
  echo -e "${need_new_certificate}\n"
}

ssl_check "${1}"
exit 0
