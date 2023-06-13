#!/bin/bash
#
# Description: Convert all JPG, PNG, and GIF images in the current directory to WebP format
#
# Usage: bash path/to/convert-img-to-webp.sh


download_libwebp="n"
download_imagemagick="n"
move_lib_to_bin="n"
quality=75
converted_imgs=0
red='\e[0;31m'
green='\e[0;32m'

convert_to_webp() {
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

      rm libwebp-1.3.0-linux-x86-64.tar.gz

    else
      echo -e "\n${red}Finishing process\n"
    fi
  fi

  if [[ -z "$(which convert)" ]]; then

    read -p "Command not found. Would you like to install ImageMagick? (Sudo permission required) [y/n]: " download_imagemagick

    [ "${download_imagemagick}" == "y" ] && sudo apt install imagemagick
  fi

  mkdir -p ./webp/

  for gif in *.gif; do
    convert "${gif}" "${gif//..*$/}.jpg"
  done

  for img in *.{jpg,png}; do
    img_name=$(echo "${img}" | sed 's/\..*$//')

    cwebp -q "${quality}" "${img}" -o "./webp/${img_name}.webp" \
      || ./libwebp-1.3.0-linux-x86-64/bin/cwebp -q "${quality}" "${img}" -o "./webp/${img_name}.webp"

    ((converted_imgs++))
  done

  echo -e "\n${green}Finished! Converted ${converted_imgs} image(s) to WebP!\n"
}

convert_to_webp "$@"

exit 0


