#!/bin/bash
#Fedora only
user=$1
icon=$2
if [[ $1 != "" && $2 != "" ]];then
  ls $2 >/dev/null 2>&1
  if [[ $? != 0 ]];then  
    echo "Error: No image called $2"
    exit 2
  fi
  ls /var/lib/AccountsService/icons/${user}.png >/dev/null 2>&1
  if [[ $? != 0 ]];then
    echo "Error: No user named $1"
    exit 2
  fi

  echo "Working ..."
  convert -resize 96x96! $2 /var/lib/AccountsService/icons/${user}.png
  if [[ $? != 0 ]];then
    echo "Failed to copy the icon, check permission?"
    exit 1
  fi
  iter=1
  cat /var/lib/AccountsService/users/$user |\
  while read line
  do
    entry=$( (echo "$line"|awk -F= '{print $1}') )
    if [[ $entry == "Icon" ]];then
      #deleting old icon settings
      sed -i "${iter}s/.*//" /var/lib/AccountsService/users/$user
    fi
    iter=$((iter+1))
  done
  content=$( (grep -v '^$' /var/lib/AccountsService/users/$user) )
  echo "$content" >/var/lib/AccountsService/users/$user
  #Adding new icon
  echo "Icon=/var/lib/AccountsService/icons/${user}.png" >> /var/lib/AccountsService/users/$user
  if [[ $? == 0 ]];then
    echo "Successful"
  fi
else
  echo "Usage: setUserIcon \$USER \$ImagePath"
fi
