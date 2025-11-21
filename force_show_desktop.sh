#!/bin/bash
xfdesktop --windowlist &
sleep 0.2
xdotool search --name "Window List" windowactivate --sync
xdotool search --name "Window List" windowsigma 0.99
#DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus xfdesktop --windowlist
