#!/bin/bash
INTERFACE="usb0"  # REPLACE WITH YOUR ACTUAL INTERFACE

# Get today's data in oneline format and extract rx/tx
TODAY_DATA=$(vnstat -i "$INTERFACE" --oneline   | tr ';' '\n')
RX=$(echo "$TODAY_DATA" | sed -n '9p')
TX=$(echo "$TODAY_DATA" | sed -n '10p')

# Format output for panel (e.g., "↓120MB ↑45MB")
echo "↓${RX} ↑${TX}"
