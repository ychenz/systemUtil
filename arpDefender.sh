#!/bin/bash
. /home/tina/Scripts/synapse.env
LOG=/var/log/arp_defencer.log
#function ask router for MAC
function _getghw(){
	local gip="$1"
	local iface="$2"
	local ghw=$( (arping -c 2 -I $iface $gip 2>>$LOG|grep $gip|awk -F[ 'FNR==2{print $2}'|awk -F] '{print $1}'|tr '[:upper:]' '[:lower:]') )

	#error handler
	#matching mac format
	if [[ "$ghw" =~ ^([a-f0-9]{2}:){5}[a-f0-9]{2}$ ]];then
		echo "$ghw"
	else
		_getghw $gip $iface #operation failed, resending arp request
	fi
}

function _routing(){
	#ip address and interface from route table
	local routing=$( (route -n) )
	echo "$routing"|\
	while read line
	do
	        ip_regex='[1-2]?[0-9]?[0-9].[1-2]?[0-9]?[0-9].[1-2]?[0-9]?[0-9].[1-2]?[0-9]?[0-9]'
	        ip=$( (echo $line|awk '{print $2}') )
	
	        if [[ $ip =~ $ip_regex && $ip != '0.0.0.0' ]];then
	                iface=$( (echo $line|awk '{print $8}') )
	                echo "$ip $iface"
	        fi
	done
}

function _offline_handler(){
	#offline handler
	local ip_iface="$1"
        while [[ -z $ip_iface ]]
        do
                sleep 10
                ip_iface=$( (_routing) )
        done
	echo $( (_routing) )
}

#initialization
function _initialization(){
	#get ip address and interface from route table
	local ip_iface=$( (_routing) )
	
	#offline handler
	ip_iface=$( (_offline_handler $ip_iface) )

	local gip=$( (echo $ip_iface|awk '{print $1}') )
	local iface=$( (echo $ip_iface|awk '{print $2}') )

	local ghw=$( (_getghw $gip $iface) )

	#get our ip
	our_ip=$( (ip addr show $iface|awk 'FNR==3{print $2}'|awk -F/ '{print $1}') )
	echo "$gip $iface $ghw $our_ip"
}

#start of defence
network=$( (_initialization) )

#start monitoring 
while true
do
	#offline handler
	routing=$( (_routing) )
	if [[ -z $routing ]];then
		_offline_handler $routing
		
		#re-initialization
		network=$( (_initialization) )
	fi

	#setting parameters
	arpReport=$( (arp -n))
	gip=$( (echo $network|awk  '{print $1}') )
	iface=$( (echo $network|awk  '{print $2}') )
	ghw=$( (echo $network|awk  '{print $3}') )
	ip=$( (echo $network|awk  '{print $4}') )

	if [[ $DEBUG == 1 ]];then echo "$network";fi

	echo "$arpReport"|\
	while read line
	do
		ip=$( (echo $line|awk '{print $1}') )
		if [[ $ip == $gip ]];then
			hw=$( (echo $line|awk '{print $3}') )
			echo "Gateway $gip is at: $hw"

			#Counter attack phase
			if [[ $hw != $ghw ]];then
				echo "Arp attack is detected!"
				kdialog --passivepopup 'Arp attack detected!!' --title "Arp defencer" 5
				echo "[$(date)] Arp attack launched from $hw is detected">>$LOG
				echo "Resetting arp table"
				arp -s $gip $ghw 2>>$LOG
				echo "Broadcasting.."
				while true
				do
					process=$( (ps aux|grep arping|wc -l) )

					#Start broadcast correct arp packet
					if [[ $process == 1 ]];then
						kdialog --passivepopup 'Now begin protection, resetting ARP table' --title "Arp defencer" 5
						arping -U -I $iface $ip >/dev/null &
					else
						kdialog --passivepopup 'They are still attacking...' --title "Arp defencer" 5
					fi

					chw=$( (_getghw $gip $iface) )
					echo "Current arp: $chw Correct:$ghw"
					if [[ $chw == $ghw ]];then
						kdialog --passivepopup 'Work done, finishing...' --title "Arp defencer" 5
						pkill arping
						break #resume to monitoring state
					fi
					sleep 10
				done
			fi
		fi
	done
	sleep 2
done
