#!/bin/bash
mkdir ~/Scripts
cd ~/Scripts
echo "Choose input method"
im-chooser
echo "To install software, please input your root password"
su
dnf -y group install KDE
dnf -y group install "Development Tools"
dnf -y install kio-gdrive
dnf -y install compiz
dnf -y install python3-tkinter  # matplotlib dependencies
dnf -y install knotes #sticky note
dnf -y install shutter # snipping tool
dnf -y install deluge # bitTorrent client
dnf -y install plymouth-theme*

echo "Installing nodejs and reactJS toolkit"
dnf -y install nodejs
npm install -g express-generator
npm install -g create-react-app
npm install -g mocha
# create-react-app projectName
# express backendProjectName


echo "Installing anti-virus"
dnf -y install clamav clamav-update clamtk


# boot theme not working in fedora 25
#wget https://raw.githubusercontent.com/ychenz/systemUtil/master/setBootTheme.sh
#chmod 744 setBootTheme.sh
# Open /home/yzhao/.config/kwinrc and set compositing Enabled to true to enable desktop effects
