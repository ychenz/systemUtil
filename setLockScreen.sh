#!/bin/bash
#To have this work, need to first change the main.qml file, set the source in the Image block pointing to the "background.jpg"
#KDE only
if [[ "$1" == '' ]];then
	echo "usage:setLockScreen.sh 'Your image path'"
	exit 1
else
	echo "Removing old wallpaper.."
	rm -f /usr/share/kde4/apps/ksmserver/screenlocker/org.kde.passworddialog/contents/ui/background.jpg
	echo "Setting new wallpaper..."
	convert $1 /usr/share/kde4/apps/ksmserver/screenlocker/org.kde.passworddialog/contents/ui/background.jpg
	if [[ "$?" == 0 ]];then
		echo "Success!"
		exit 0
	else
		echo "failed.."
		exit 2
	fi
fi
