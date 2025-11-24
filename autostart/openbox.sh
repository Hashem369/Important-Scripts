# Start D-Bus session
#eval $(dbus-launch --sh-syntax)
#export DBUS_SESSION_BUS_ADDRESS
#export DBUS_SESSION_BUS_PID

# Start desktop environment variables
#export XDG_CURRENT_DESKTOP=Openbox
#export GNOME_DESKTOP_SESSION_ID=this-is-deprecated

# enable keyring
#eval $(gnome-keyring-daemon --start --components=secrets) &
#dbus-update-activation-environment --systemd DISPLAY XAUTHORITY \
#    GNOME_KEYRING_CONTROL SSH_AUTH_SOCK GNOME_KEYRING_PID
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &

# Change the resolution
xrandr --output VGA-0 --mode 1920x1080

# Set wallpaper
nitrogen --restore &

# Start panels
tint2 &
# Top Panel
tint2 -c /home/hashem/.config/tint2/horizontal-dark-transparent.tint2rc &

# Set dark GTK theme
gtk-theme-variant=dark &

# Start file manager (optional, can start manually)
# pcmanfm --daemon &

# Enable Redshift
redshift -m randr -v &
# Enable xscreensaver
#xscreensaver -no-splash &

# Lock screen after inactivety
xautolock -time 10 -locker betterlockscreen --lock &
# auto numlock
numlockx on
# audio systemtray

#pulseaudio --start &
start-pulseaudio-x11 &
pnmixer &
# start safeeyes:
safeeyes --enable & 

