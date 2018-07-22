# Installing Homebridge on a Raspberry Pi

This is a short howto to setup a Raspberry Pi (3) as a Homebridge server with camera module for Apple Homekit.

## Preparing the Pi

- Download [Raspbian Stretch Image](https://downloads.raspberrypi.org/raspbian_lite_latest)
- Open image to access root file system. On a Mac it's just double clicking it
- Create an empty file with ```touch ssh``` to enable ssh per default. On a Mac open a terminal and ```cd /Volumes/boot```
- Flash to an SD card with e.g. [Etcher](https://etcher.io/)
- start the Pi and locate it on the network
- ssh to the Pi with ```ssh hosenameOrIpAddress -l pi```
- the password for user pi is ```raspberry```

## Configuring the Pi

- start the configuration with ```sudo raspi-config```
- set up hostname, wifi, locale and keyboard layout, expand the filesystem, enable the camera module etc.
- reboot

## System updates

Issue a

```plaintext
apt update && apt upgrade -y
```

to update the whole system first.

## Other machine settings

Set up a real root user. 

```plaintext
sudo passwd
```

Also, you may want to set ssh access for the root user. Open the ```/etc/ssh/sshd_config``` file and search for the line

```plaintext
#PermitRootLogin prohibit-password
```

Change this to

```plaintext
PermitRootLogin yes #prohibit-password
```

Reboot the Pi or restart ssh with

```plaintext
sudo /etc/init.d/ssh restart
```

## Installing Node.js

Add Node.js to the package list

```plaintext
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
```

Install Node.js and other packages. We need ffmeg only if we want to use a Pi camera. The installation may take a while.

```plaintext
apt install nodejs node-semver ffmpeg -y
```

## Install Node.js packages

This will install all relevant node modules.

```plaintext
npm install -g --unsafe-perm pm2 homebridge homebridge-config-ui-x homebridge-hue homebridge-camera-rpi homebridge-tplink-smarthome
```

Set some rights for camera access

```plaintext
usermod -aG video pi
usermod -aG video root
```

If you want to use the Pi camera, add this video module codec to modules at startup

```plaintext
nano /etc/modules
```

and add this line

```plaintext
bcm2835-v4l2
```

## Config file

My config file is located in ```/root/.homebridge/config.json```

If you don't have that folder and file yet, create them (all commands as root user)

```plaintext
cd
mkdir .homebridge
nano .homebridge/config.json
```

And this is the content in my case. You may want to alter it depending on the plugins and devices you are using.

```json
{
    "bridge": {
        "name": "Bridge_IPCAM",
        "username": "CC:22:3D:E3:CE:30",
        "port": 51826,
        "pin": "656-92-987"
    },
    "description": "This is the description",
    "platforms": [
        {
            "platform": "rpi-camera",
            "cameras": [
                {
                    "name": "Pi Camera"
                }
            ]
        },
        {
            "platform": "config",
            "name": "Config",
            "port": 8083,
            "log": "/var/log/homebridge.stdout.log",
            "error_log": "/var/log/homebridge.stderr.log",
            "restart": "/usr/local/bin/supervisorctl restart homebridge"
        },
        {
            "platform": "TplinkSmarthome",
            "name": "TplinkSmarthome",
            "pollingInterval": 10,
            "switchModels": [
                "HS100"
            ],
            "broadcast": "255.255.255.255",
            "devices": [
                {
                    "host": "192.168.2.216"
                }
            ]
        },
        {
            "platform": "Hue",
            "users": {
                "001788FFFE6E4BC7": "jWBnbhj9isw1LY3dy40IkMce7w5v0P2nbKD3OrXN"
            },
            "lights": true
        }
    ],
    "accessories": []
}
```

## Test installation

```plaintext
homebridge
```

If no errors occur than congrats! You can stop the script with ```CTRL+C```

## Add homebridge as a service at boot

I am using pm2 to startup node scripts at boot time

```plaintext
pm2 start homebridge
```

To list the processes that pm2 is running type

```plaintext
pm2 ls
```

To save the pm2 config type

```plaintext
pm2 save
```

To add pm2 to the start up procedure type

```plaintext
pm2 startup
```

## Reboot and check

After reboot check if the server is running by opening ```http://hostname:8083```. This will bring up the config UI. To login use "admin" as username and password. You can change the password later in the UI.

## Troubleshooting

Whenever you experiment with adding and removing the homebridge to your Homekit system, it may occur that you cannot re-add the homebridge after you removed (for testing). In this case change the username property in the config file.

In my case I could successfully re-add the bridge after changing this line:

```plaintext
"username": "CC:22:3D:E3:CE:30"
```

to

```plaintext
"username": "CC:22:3D:E3:CE:31"
```

in the config.json file. It seems that homekit chaches devices for a while so this is a roundtrip.