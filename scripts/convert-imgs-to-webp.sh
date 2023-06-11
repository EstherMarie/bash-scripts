#!/bin/bash
#
# Description: Convert all jpg and png images from current directory to WebP format
#
# Usage: bash path/to/convert-img-to-webp.sh
#
# TODO: Convert images from gif format 


download_libwebp="n"
move_lib_to_bin="n"
converted_imgs=0
red='\e[0;31m'
green='\e[0;32m'

convert_to_webp() {
  # If cweb does not exist, install libwebp and move to /use/bin/
  if [[ -z "$(which cwebp)" ]]; then

    read -p "Command not found. Would you like to install cwebp, dwebp, and the WebP libraries? [y/n]: " download_libwebp

    if [[ "${download_libwebp}" == "y" ]]; then
      wget https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.3.0-linux-x86-64.tar.gz\
        || echo "Oops! Wild error $? appeared!"

      tar -xvf libwebp-1.3.0-linux-x86-64.tar.gz


      read -p "Move files to /usr/bin/? (Sudo permission required) [y/n]: " move_lib_to_bin

      if [[ "${move_lib_to_bin}" == "y" ]]; then
        sudo cp -r libwebp-1.3.0-linux-x86-64/bin/* /usr/bin/

        rm -r libwebp-1.3.0-linux-x86-64 
      fi

    else
      echo -e "\n${red}Finishing process\n"
    fi
  fi


  for img in *.{jpg,png}; do
    img_name=$(echo "${img}" | sed 's/\..*$//')

    cwebp -q 75 "${img}" -o "${img_name}.webp" \
      || ./libwebp-1.3.0-linux-x86-64/bin/cwebp -q 75 "${img}" -o "${img_name}.webp"

    ((converted_imgs++))
  done

  echo -e "\n${green}Finished! Converted ${converted_imgs} image(s) to WebP!\n"
}

convert_to_webp "$@"

exit 0



# Source:
#
# https://developers.google.com/speed/webp?hl=pt-br
# https://developers.google.com/speed/webp/docs/precompiled?hl=pt-br
#
# cwebp Docs:
# https://developers.google.com/speed/webp/docs/cwebp?hl=pt-br
#
# Note:
# img_name="${img/\..*$//}" # This is not working yet...
