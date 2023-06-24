# bash-scripts
Some lovely bash scripts to automate common Front-end tasks.

## Included Scripts
- SCSS Compilation and Minification
- Docker-Compose Setup for WordPress
- Image Conversion to WebP
- Git Branch Management
- SSL certificate expiration date checker
- Website HTTP status code test

## Usage
Many of these scripts will be executed in the current directory. To run any of them, please read the description provided for each script, and follow the steps below:

Allow execution of the script
```bash
chmod +x ./script.sh
```
Execute the script
```bash
bash ./script.sh
```

Some scripts receive an argument. Pass it after the script name:
  ```bash
  bash ./css-compile.sh home
  ```

The `ssl-check.sh` and `websites-online.sh` scripts receive a `.txt` file with a list of websites.

Example:
```
https://github.com
https://www.figma.com
https://www.docker.com
```
