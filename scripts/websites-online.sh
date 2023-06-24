#!/bin/bash
#
# Description: Check if websites are online
#
# Usage: bash ~/path/to/websites-online.sh sites.txt


green_color="\033[0;32m"
not_200_sites="${green_color}All 200 OK!"

websites_online() {
  while IFS= read -r line; do
    HTTP_code=$(curl --max-time 5 --silent --write-out %{response_code} -o /dev/null "${line}")

    echo "$line"
    curl -Is "$line" | head -n 1
    curl -Iv "$line" --stderr - | grep "expire date"
    echo ""

    if [[ $HTTP_code -ne 200 ]]; then
      echo "" > not_200_sites
      not_200_sites="${line}"
    fi
  done < "${1}"


  echo -e "Sites that didn't return 200:"
  echo -e "${not_200_sites}\n"
}

websites_online "${1}"
exit 0
