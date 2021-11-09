#!/bin/bash

DIR="$HOME/contacts"

if [[ ! -d "$DIR" ]]; then
  mkdir $DIR
fi

while getopts ":cr:d:h" opt; do
  case "${opt}" in
    c)
      #Recives contact info throught user input       
      read -p "Email: " email
      #Define file based on contacts email
      FILE="$DIR/$email"
      read -p "Address: " addr
      read -p "First Name: " fname
      read -p "Last Name: " lname
      read -p "Cell: " cnum
      read -p "Home Phone(optional): " hnum
      #Writes contact info to file
      echo "$email;$addr;$fname;$lname;$cnum;$hnum" >> $FILE
      ;;
    r)
      #Removes a contact from the contacts directory
      found=0
      #Loops through each file/contact to search for a match
      for file in $DIR/*; do
        if [[ $file == $DIR/${OPTARG} ]]; then
          echo "Removing $OPTARG from contacts"
          rm $file
          found=$((found+1))
        fi
      done
      #If the contact doesn't exist is found alerts user 
      if [[ $found == 0 ]]; then
        echo "${OPTARG} not found"
        exit 1
      fi
      ;;
    d)
      #Displays all contacts or a single contact using email as identifier
      read -p "Email of contact (Leave blank for all contacts): " contact
      echo 
      #Single contact
      if [[ -f $DIR/$contact ]]; then 
        file=$DIR/$contact
        if [[ $OPTARG -gt "-1" ]]; then
          FILTER=("email name cell address home")
          #Check if user entered a valid filter then sorts them
          if [[ " ${FILTER[*]} " =~ " $OPTARG "  ]]; then 
            #Use dictionary to later print category
            declare -A filters
              filters[email]=' { print $1 }'
              filters[name]='{ print $3, $4 }'
              filters[cell]=' { print $5 }'
              filters[address]='{ print $2 }'
              filters[home]='{ print $6 }'
            VAR=$(awk -F';' "${filters[${OPTARG}]}" $file)
            echo -e "${OPTARG^}: $VAR\n"
          #Prints for all
          elif [[ $OPTARG = 'all' ]]; then        
            IFS=';'
            while read -r email addr fname lname cnum hnum; do
              printf "Email: %s\n" $email
              printf "Name: %s %s\n" $fname $lname
              printf "Address: %s\n" $addr
              printf "Cell Number: %s\n" $cnum
              if [[ $hnum != "" ]]; then
                printf "Home Number: %s\n" $hnum
              fi
              done < $file     
          else
            #No filter/wrong filter passed
            echo "Error: ${OPTARG} is not a valid argument"
            exit 1
          fi
        fi
      #All contacts
      #Identical to Single, would use functions if I was better and just loop.
      elif [[ $contact == '' ]]; then
        if [[ $OPTARG -gt "-1" ]]; then
          FILTER=("email name cell address home")
          if [[ " ${FILTER[*]} " =~ " $OPTARG "  ]]; then
              for file in $DIR/*; do
                declare -A filters
                  filters[email]=' { print $1 }'
                  filters[name]='{ print $3, $4 }'
                  filters[cell]=' { print $5 }'
                  filters[address]='{ print $2 }'
                  filters[home]='{ print $6 }'
                VAR=$(awk -F';' "${filters[${OPTARG}]}" $file)
                echo -e "${OPTARG^}: $VAR\n"
              done
         elif [[ $OPTARG = 'all' ]]; then        
            for file in $DIR/*; do      
              IFS=';'
              while read -r email addr fname lname cnum hnum
                do
                  printf "Email: %s\n" $email
                  printf "Name: %s %s\n" $fname $lname
                  printf "Address: %s\n" $addr
                  printf "Cell Number: %s\n" $cnum
                  if [[ $hnum != "" ]]; then
                    printf "Home Number: %s\n" $hnum
                  fi
                done < $file
                echo;
              done   
          else
            echo "Error: ${OPTARG} is not a valid argument"
            exit 1
          fi
        fi
      #If the contact doesn't exist alerts the user
      else 
        echo "$contact not found"
        exit 1
      fi
      ;;
      h)
        #Prints help message
        echo "Usage:"
        echo "    -d [FILTER]       Displays contacts"
        echo "       Filters: all, email, name, address, cell, home"
        echo "       - Filters specify what contact info you wish to display (Only 1 at a time)."
        echo "    -c              Creates a new contact"
        echo "    -r [EMAIL]      Removes a contact"
        echo "        Email: The email of the contact you wish to remove"
        ;;
    "?")
      echo "Error: -${OPTARG} is not an option, try using -h"
      exit 1
      ;;
     :)
      echo "Error: -${OPTARG} requires an argument, try using -h"
      exit 1
  esac
done

if [[ $# -lt 1 ]]; then
  echo "Error Provide option -c, -d and/or -r"
fi

shift $((OPTIND - 1))
