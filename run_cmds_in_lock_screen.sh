#!/bin/bash
# Get current layout
#CURRENT_LAYOUT=$(ibus engine)
ibus engine 'xkb:us::eng'
# Keep this before the last one
xscreensaver-command -lock
# Revert back to the previous layout
#ibus engine $CURRENT_LAYOUT
