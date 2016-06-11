#!/bin/bash
#if [[ -e "/var/run/wpa_supplicant/wlp0s20u4" ]];then
#    rm -f /var/run/wpa_supplicant/wlp0s20u4
#fi
wpa_supplicant -B -i wlp0s20u4 -c /etc/wpa_supplicant/wpa_supplicant.conf -D nl80211

