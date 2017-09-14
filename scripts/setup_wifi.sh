#! /bin/bash

service NetworkManager stop

killall wpa_supplicant

wpa_supplicant -B -dd -D wext -i wlan0 -c sample.conf

sleep 5

dhclient -v wlan0
