#!/bin/bash
# Save as ~/.config/tint2/executors/network_speed.sh

INTERFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}' || echo "eth0")

# Get initial stats
RX1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes 2>/dev/null || echo 0)
TX1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes 2>/dev/null || echo 0)

# Wait 1 second to measure speed
sleep 1

# Get final stats
RX2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes 2>/dev/null || echo 0)
TX2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes 2>/dev/null || echo 0)

# Calculate speed in bytes per second
RX_SPEED=$(( ($RX2 - $RX1) ))  # bytes/s
TX_SPEED=$(( ($TX2 - $TX1) ))  # bytes/s

# Convert to human-readable format (KB/s or MB/s)
if [ $RX_SPEED -gt 1048576 ]; then
    RX_SPEED=$(echo "scale=1; $RX_SPEED/1048576" | bc)MB/s
elif [ $RX_SPEED -gt 1024 ]; then
    RX_SPEED=$(echo "scale=0; $RX_SPEED/1024" | bc)KB/s
else
    RX_SPEED=${RX_SPEED}B/s
fi

if [ $TX_SPEED -gt 1048576 ]; then
    TX_SPEED=$(echo "scale=1; $TX_SPEED/1048576" | bc)MB/s
elif [ $TX_SPEED -gt 1024 ]; then
    TX_SPEED=$(echo "scale=0; $TX_SPEED/1024" | bc)KB/s
else
    TX_SPEED=${TX_SPEED}B/s
fi

# Output in compact format for panel
echo "↓$RX_SPEED ↑$TX_SPEED"
