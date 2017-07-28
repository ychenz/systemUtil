#!/bin/bash
dnf install -y vim sudo firewall-config gcc wget git
#wget http://download1.rpmfusion.org/free/fedora/releases/25/Everything/x86_64/os/Packages/r/rpmfusion-free-release-25-1.noarch.rpm
#rpm -ivh rpmfusion-free-release-25-1.noarch.rpm
#dnf repolist
#dnf install -y vlc
#dnf install -y vino
#echo "Enabling sshd ..."
#systemctl start sshd
#systemctl enable sshd
#firewall-cmd --add-port=22/tcp
#firewall-cmd --add-port=5900/tcp
#ports=$( (firewall-cmd --list-ports) )
if [[ $ports == '22/tcp'  ]];then
	echo "PORT: $ports opened successfully"
else
	echo "Failed to open PORT: $ports"
fi
echo "\nLooking for Nvidia cards ..."
nvidia_cnt=$( (lspci | grep -i nvidia|wc -l) )
if [[ $nvidia_cnt > 0 ]];then
	echo "Found Nvida card! Installing driver ..."
	echo "Installing kernel dependencies"
	dnf install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r)
	dnf remove -y xorg-x11-drv-nvidia  # 1Gb of stuff disappears
	dnf remove -y cuda-repo-*
	rm -rf /usr/local/cuda*
	dnf config-manager --add-repo=http://negativo17.org/repos/fedora-nvidia.repo
	dnf install -y dkms-nvidia  nvidia-driver-cuda
	dnf install -y cuda-devel cuda-cudnn-devel
	dnf install -y nvidia-cuda-toolkit-devel

	pip3 install virtualenv
	#echo "Installing tensorflow ..."
	#virtualenv --system-site-packages ~/.env/tensorflow
	#. ~/.env/tensorflow/bin/activate
	#LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64/
	#ln -s /usr/lib64/libcudnn.so.6.0.20 /usr/lib64/libcudnn.so.5

fi
