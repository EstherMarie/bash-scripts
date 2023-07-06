#!/bin/bash
#
# Descripition: 
# - Setup Docker Compose for WordPress Development in current directory
# - Add uploads.ini
# - Optional:
#   - If directory is empty, can download WordPress and set required files for custom theme development
#   - Can add Docker Compose files to gitignore
# 
# Usage: bash ~/bash-scripts/docker-compose-wordpress.sh
#
# Important: Change DEFAULT_PASSWORD in line 16


DEFAULT_DB_USER="admin"
DEFAULT_PASSWORD="quousquetandemabuterecatilinapatientianostra"
GREEN_COLOR="\033[0;32m"

configure_theme_files() {
echo -e "\nCreating theme directory..."

mkdir ./wp-content/themes/${THEME_NAME}
touch ./wp-content/themes/${THEME_NAME}/{index.php,functions.php}

cat <<-EOF > ./wp-content/themes/${THEME_NAME}/style.css 
/*
Theme Name: ${THEME_NAME}
Theme URI:
Author:
Author URI:
Description:
Tags:
Version: 1.0
Requires at least:
Tested up to:
Requires PHP:
License: GNU General Public License v2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html
Text Domain:
This theme, like WordPress, is licensed under the GPL.
Use it to make something cool, have fun, and share what you've learned with others.
*/
EOF


echo "Creating uploads.ini..."

cat <<EOF > uploads.ini
upload_max_filesize = 2000M
post_max_size = 4000M
max_execution_time = 600
EOF
}

if [[ $(find docker-compose.yml > /dev/null 2>&1) ]]; then
  echo "Project already has docker-compose"
  echo "Exiting..."
  exit 1
fi

echo -e "\nConfiguring Docker Compose variables..."

read -p "Write your theme name: " THEME_NAME

read -p "Write your DB name (example: wp-awesome-project): " DB_NAME
VOLUME_NAME="${DB_NAME//-/_}" # Replace "-" for "_"

read -p "Write your DB user login [Press enter to login as ${DEFAULT_DB_USER}]: " DB_USER
DB_USER="${DB_USER:-${DEFAULT_DB_USER}}"

read -s -p "Write your DB password [Press enter to use default password]: " DB_PASSWORD
DB_PASSWORD="${DB_PASSWORD:-${DEFAULT_PASSWORD}}"

echo ""
read -s -p "Write your MYSQL root password [Press enter to use default password]: " MYSQL_ROOT_PASSWORD
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-${DEFAULT_PASSWORD}}"


### Check if WordPress directories exits ###
NUMBER_OF_FILES=$(ls -l | grep -c -v "total")

# if no file is found, download WordPress
if [ "${NUMBER_OF_FILES}" -eq 0 ]; then

  echo -e "\n"
  read -p "Would you like to download WordPress? [y/n]: " SHOULD_DOWNLOAD_WP

  if [ ${SHOULD_DOWNLOAD_WP} == "y" ]; then
    echo -e "\nDownloading lastest version of WordPress ..." 
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* ./
    rmdir wordpress
    rm latest.tar.gz 

    configure_theme_files
  fi
fi

echo -e "\n"
echo "Creating Docker Compose file..."

cat <<-EOF > docker-compose.yml
version: '3'
services:
  db:
    #image: mariadb:10.6.4-focal
    image: mysql:5.7.36
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${DB_NAME}
      - MYSQL_USER=${DB_USER}
      - MYSQL_PASSWORD=${DB_PASSWORD}
    expose:
      - 3306
      - 33060
    networks:
      - wpsite
  phpmyadmin:
    depends_on:
      - db
    image: phpmyadmin/phpmyadmin
    restart: always
    ports:
      - '8080:80'
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    networks:
      - wpsite
  wordpress:
    image: wordpress:latest
    volumes:
      - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
      - ./wp-content/themes/${THEME_NAME}:/var/www/html/wp-content/themes/${THEME_NAME}
      - ${VOLUME_NAME}:/var/www/html
    ports:
      - 80:80
    restart: always
    environment:
      - WORDPRESS_DB_HOST=db
      - WORDPRESS_DB_USER=${DB_USER}
      - WORDPRESS_DB_PASSWORD=${DB_PASSWORD}
      - WORDPRESS_DB_NAME=${DB_NAME}
    networks:
      - wpsite
networks:
  wpsite:
volumes:
  db_data:
  ${VOLUME_NAME}:
EOF

### Optionaly add files to .gitignore ###
echo ""
read -p "Would you like to add Docker Compose files to .gitignore? [y/n]: " SHOULD_ADD_TO_GITIGNORE 

if [ ${SHOULD_ADD_TO_GITIGNORE}  == "y" ]; then
cat <<-EOF > .gitignore
docker-compose.yml
uploads.ini
.gitignore
EOF
fi

echo -e "\nCreating .gitignore..."

echo -e "\n${GREEN_COLOR}Docker compose successfully configured for WordPress!\n"   
exit 0
