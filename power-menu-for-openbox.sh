#!/bin/bash
# Power menu with rofi - black background, white text
selected=$(echo -e "Shutdown\nReboot\nLogout\nSuspend\nLock" | rofi -dmenu -i -p "System" \
    -theme-str 'window {width: 20%; height: 250px; background-color: #000000; border-radius: 10px;}' \
    -theme-str 'listview {lines: 5; scrollbar: false;}' \
    -theme-str 'textbox {placeholder-color: @foreground;}' \
    -theme-str 'element {background-color: #1a1a1a; color: #ffffff;}' \
    -theme-str 'element normal {background-color: #1a1a1a; color: #ffffff;}' \
    -theme-str 'element selected {background-color: #333333; color: #ffffff;}' \
    -theme-str 'element-icon {size: 30px;}' \
    -theme-str '* {font: "Sans 16";}' \
    -theme-str 'main {children: [message, listview];}' \
    -theme-str 'message {text: "System Actions"; background-color: #000000; color: #ffffff; border-radius: 8px 8px 0 0; padding: 10px; text-align: center;}')

case $selected in
    Shutdown) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
    Logout) openbox --exit ;;
    Suspend) systemctl suspend ;;
    Lock) betterlockscreen --lock ;;
esac
