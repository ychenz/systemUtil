#!/bin/bash
#By Yuchen Jun 7,2015
#Change booting animation
#All  theme is in /usr/share/plymouth/themes/


if [ "$1" == '' ];then
	echo 'You must select a theme!'
	exit 1
fi

if [ "$1" == '--setup' ];then
	yum -y install plymouth* 
	exit 0;
fi	


if [ "$1" == '--help' ];then
	echo 'usage:setBootTheme [plymouth theme]'
	echo 'setBootTheme --list: list avaliable themes'          
	echo 'setBootTheme -- setup: install plymouth'
	echo "You may need to append vga=792 in /etc/default/grub at GRUB_CMDLINE_LINUX field"
	echo " All themes is in /usr/share/plymouth/themes"
else
	if [ "$1" == '--list' ];then
		plymouth-set-default-theme --list;
	else
		for theme in $( (plymouth-set-default-theme --list) );do
			if [[ "$1" == "$theme" ]];then
				echo "theme $1 selected"
			        break
			fi
		done
		plymouth-set-default-theme $1
		if [[ $? != 0 ]];then
			echo "Failed to select theme $1"
			exit 1	
		fi
		echo "generating initrd.."
		plymouth-set-default-theme -R $1
		dracut --force
		echo "Done"
		exit 0
	fi
fi
