#!/bin/bash
# Author: yuchen
# works on ubuntu 16.04
echo "Installing dependencies ..."
sudo apt-get install -y build-essential cmake git pkg-config
sudo apt-get install -y libjpeg8-dev libtiff4-dev libjasper-dev libpng12-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install -y libgtk2.0-dev
sudo apt-get install -y libatlas-base-dev gfortran
sudo apt-get install -y python3.5-dev
sudo pip3 install numpy
python3.5-config --includes # check python dependencies

# copy dependencies to include path
sudo cp /usr/include/x86_64-linux-gnu/python3.5m/pyconfig.h /usr/include/python3.5m/
git clone https://github.com/Itseez/opencv.git
mv opencv opencv-3
echo "cd opencv-3 ..."
cd opencv-3
mkdir build
cd build
sudo mkdir /usr/local/opencv-3

echo "#### Start of building ####"
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local/opencv-3 ..
make
echo "#### Installing into /usr/local/opencv-3 ####"
sudo make install
echo "#### Linking python library ####"
sudo ln -s /usr/local/opencv-3/lib/python3.5/dist-packages/cv2.cpython-35m-x86_64-linux-gnu.so /usr/local/lib/python3.5/dist-packages/
echo "Done !!"
cd ../..

