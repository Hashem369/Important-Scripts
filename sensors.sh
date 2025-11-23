#!/bin/bash
# Save as ~/.config/tint2/executors/temperatures.sh

# Get raw sensors output
SENSORS_OUTPUT=$(sensors)

# Extract CPU temperature (k10temp)
CPU_TEMP=$(echo "$SENSORS_OUTPUT" | grep -A 2 'k10temp-pci' | grep 'temp1' | awk '{print $2}' | sed 's/+//' | sed 's/°C.*//')
CPU_TEMP=${CPU_TEMP:-"0.0"}

# Extract GPU temperature (radeon)
GPU_TEMP=$(echo "$SENSORS_OUTPUT" | grep -A 2 'radeon-pci' | grep 'temp1' | awk '{print $2}' | sed 's/+//' | sed 's/°C.*//')
GPU_TEMP=${GPU_TEMP:-"0.0"}

# Handle decimal points properly
CPU_TEMP=$(echo "$CPU_TEMP" | sed 's/,/./')
GPU_TEMP=$(echo "$GPU_TEMP" | sed 's/,/./')

# Format output - only show if we got real values
if [[ "$CPU_TEMP" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [[ "$GPU_TEMP" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "CPU: ${CPU_TEMP}°C | GPU: ${GPU_TEMP}°C"
else
    echo "CPU: --°C | GPU: --°C"
fi
