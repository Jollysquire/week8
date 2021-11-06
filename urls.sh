#!/bin/bash
PRINT=0
INDEX="$PWD/index"
while getopts ":fh" opt; do
  case ${opt} in
    f )
      PRINT=1
      ;;
    h )
      echo "Usage:"
      echo "      Gets all http/https links on a page"
      echo "      ...[URL]"
      echo "      -f writes URL's to a file"
      exit 1
      ;;
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

URL=$1
wget $URL -O $INDEX

if [ $PRINT = 0 ]; then
  cat $INDEX | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u
  rm $INDEX
else
  read -p "Enter a filename (Optional): " FILE
  if [[ $FILE == '' ]]; then
    FILE="URL_List"
  fi
  cat $INDEX | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u > $PWD/$FILE
  rm $INDEX
  echo -e "\nURLs saved in $FILE"
fi
