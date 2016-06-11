#!/bin/bash
if [[ $1 == "t" ]];then
  rm /etc/systemd/system/default.target
  ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
  echo "System will boot into text mode next time"
elif [[ $1 == "g" ]];then
  rm /etc/systemd/system/default.target
  ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
  echo "System will boot into graphical mode next time"
fi
