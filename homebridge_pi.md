# Installing Homebridge on a Raspberry Pi

This is a short howto to setup a Raspberry Pi (3) as a Homebridge server with camera module for Apple Homekit.

## Preparing the Pi

- download Raspbian Stretch Image
- open image to access root file system
- create an empty file with ```touch ssh``` to enable ssh per default
- Flash to an SD card with e.g. Etcher
- start the Pi and locate it on the network
- ssh to the Pi with ```ssh hosenameOrIpAddress -l pi```
- the password for user pi is ```raspberry```

## Configuring the Pi

- start the configuration with ```sudo raspi-config```
- set up hostname, locale and keyboard layout, expand the filesystem, enable the camera module etc.
- reboot

## Installing Node.js and modules

Add Node.js to the package list

```plaintext
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
```

Install Node.js and other packages

```plaintext
apt install nodejs node-semver ffmpeg
```

This will install all relevant node modules.

```plaintext
npm install -g --unsafe-perm pm2 homebridge homebridge-config-ui-x homebridge-hue homebridge-camera-rpi homebridge-tplink-smarthome
```

Set some rights for camera access

```plaintext
usermod -aG video pi
usermod -aG video homebridge
usermod -aG video root
```

Add video module codec to modules at startup

```plaintext
nano /etc/modules
```

and add this line

```plaintext
bcm2835-v4l2
```

## Config file

My config file is located in ```/root/.homebridge/config.json```

And this is the content

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

After reboot check if the server is running by opening ```http://hostname:8083```. This will bring up the config UI. To login user "admin" as username and password. You can change the password later in the UI.