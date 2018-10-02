#!/bin/bash

# update system
echo "******** Updating the system"
apt-get update && apt-get upgrade -y
echo "******** Installing the video codec"
apt install ffmpeg -y
echo "******** Installing Node.js"
wget https://nodejs.org/dist/v8.12.0/node-v8.12.0-linux-armv6l.tar.xz
tar xvf node*.tar
cp -r node*/* /usr/local
echo "******** Installing Node.js packages for Homebridge"
npm install -g --unsafe-perm pm2 homebridge homebridge-config-ui-x homebridge-camera-rpi homebridge-camera-ffmpeg
echo "******** Setting video user rights"
usermod -aG video pi && usermod -aG video root
echo "******** Adding video module"
echo bcm2835-v4l2 >> /etc/modules
echo "******** Creating config.json"
mkdir /root/.homebridge
cp config.json /root/.homebridge
echo "******** Setting up Homebridge as a service with pm2"
pm2 start "homebridge -I"
pm2 save
pm2 startup
echo "******** Finished. You should reboot now"