#!/bin/sh
get_version() {
  local app_name="$1"
  local version=${2:-"--version"}
  app_version_str=$($app_name "$version" 2>&1 | tr -cd '0-9')
  echo "$app_version_str"
}

# check version of the program
check_version() {
  local app_name="$1"
  local req_version_str="$2"
  local version=${3:-"--version"}

  if ! command -v "$app_name" >/dev/null 2>&1; then
    return 0
  fi
  #local app_version_str
  NODE_PATH=$(which $app_name)
  TR_PATH=$(which tr)

  app_version_str=$(get_version $app_name $version)
  # Extract major version number (integer part)
  #local app_version
  app_version=$(echo "$app_version_str" | cut -d '.' -f 1 | cut -c 1-7)
  req_version=$(echo "$req_version_str" | tr -cd '0-9' | cut -d '.' -f 1 | cut -c 1-7)
  if [ "$app_version" -ge "$req_version" ]; then
    echo 1
  else
    echo 0
  fi
}

# Usage
# check_version "node" 18
