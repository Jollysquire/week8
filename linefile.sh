#!/bin/bash
while getopts ":hn" opt; do
  case "${opt}" in
    h)
      echo "Usage:"
      echo "      Prints contents of file"
      echo "      lnnm [OPTIONS] [FILE]"
      echo "      -n adds line numbers"
      exit 1
      ;;
    n)
      NUM=true
      ;;
    "?")
      echo "Error: -${OPTARG} is not an option, try using -h"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

input="$PWD/$1"
n=1
while IFS= read -r line
do
  if [[ $NUM ]]; then
    echo "$n. $line"
  else
    echo "$line"
  fi
  n=$(( n+1 ))
done < "$input"
