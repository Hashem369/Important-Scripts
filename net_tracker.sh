#!/bin/bash
# ~/true_daily_usage.sh - Daily usage tracker that works across logouts

# Configuration
INTERFACE="usb0"  # Will auto-detect if this doesn't exist
DATA_DIR="$HOME/.daily_usage_tracker"
mkdir -p "$DATA_DIR"
DATABASE="$DATA_DIR/usage.db"
STATE_FILE="$DATA_DIR/state.txt"
CURRENT_DAY_FILE="$DATA_DIR/current_day.txt"
LOG_FILE="$DATA_DIR/debug.log"

# Auto-detect interface if needed
if [ ! -d "/sys/class/net/$INTERFACE" ]; then
    # Try to find active interface
    INTERFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i == "dev") print $(i+1)}' | head -1)
    
    # Fallback to common interface patterns
    if [ -z "$INTERFACE" ]; then
        INTERFACE=$(ls /sys/class/net/ 2>/dev/null | grep -E 'usb|enx|eth|wlan' | head -1)
    fi
    
    # Final fallback
    if [ -z "$INTERFACE" ]; then
        echo "↓ERR ↑ERR"
        exit 1
    fi
fi

# Check if interface exists
if [ ! -d "/sys/class/net/$INTERFACE" ]; then
    echo "↓ERR ↑ERR"
    exit 1
fi

# Get current date in YYYYMMDD format (for day tracking)
CURRENT_DAY=$(date +%Y%m%d)

# Initialize current day tracking if needed
if [ ! -f "$CURRENT_DAY_FILE" ]; then
    echo "$CURRENT_DAY" > "$CURRENT_DAY_FILE"
    > "$DATABASE"
    echo "0;0" > "$STATE_FILE"  # Initialize total usage to 0
fi

# Check if we've passed midnight
STORED_DAY=$(cat "$CURRENT_DAY_FILE")
if [ "$STORED_DAY" != "$CURRENT_DAY" ]; then
    # Midnight rollover - reset everything
    echo "[$(date)] Midnight rollover detected" >> "$LOG_FILE"
    echo "$CURRENT_DAY" > "$CURRENT_DAY_FILE"
    > "$DATABASE"
    echo "0;0" > "$STATE_FILE"  # Reset totals to 0
fi

# Get current byte counters
RX_BYTES=$(cat "/sys/class/net/$INTERFACE/statistics/rx_bytes" 2>/dev/null)
TX_BYTES=$(cat "/sys/class/net/$INTERFACE/statistics/tx_bytes" 2>/dev/null)

if [ -z "$RX_BYTES" ] || [ -z "$TX_BYTES" ]; then
    echo "↓? ↑?"
    exit 1
fi

# Get previous state (total usage)
if [ -f "$STATE_FILE" ]; then
    TOTAL_RX=$(cut -d';' -f1 "$STATE_FILE")
    TOTAL_TX=$(cut -d';' -f2 "$STATE_FILE")
else
    TOTAL_RX=0
    TOTAL_TX=0
fi

# Get the last recorded values (if any)
if [ -s "$DATABASE" ]; then
    LAST_ENTRY=$(tail -1 "$DATABASE")
    LAST_RX=$(echo "$LAST_ENTRY" | cut -d';' -f2)
    LAST_TX=$(echo "$LAST_ENTRY" | cut -d';' -f3)
    
    # Calculate usage since last update
    RX_DIFF=$((RX_BYTES - LAST_RX))
    TX_DIFF=$((TX_BYTES - LAST_TX))
    
    # Handle counter resets (when values wrap around)
    if [ $RX_DIFF -lt 0 ]; then
        RX_DIFF=0
    fi
    if [ $TX_DIFF -lt 0 ]; then
        TX_DIFF=0
    fi
    
    # Update totals
    TOTAL_RX=$((TOTAL_RX + RX_DIFF))
    TOTAL_TX=$((TOTAL_TX + TX_DIFF))
    
    # Save new totals
    echo "$TOTAL_RX;$TOTAL_TX" > "$STATE_FILE"
    
    # Record new entry
    echo "$(date +%s);$RX_BYTES;$TX_BYTES" >> "$DATABASE"
else
    # First run or after midnight - initialize database
    echo "$(date +%s);$RX_BYTES;$TX_BYTES" > "$DATABASE"
    
    # Initialize totals if needed
    if [ ! -f "$STATE_FILE" ]; then
        echo "0;0" > "$STATE_FILE"
    fi
fi

# Convert to human-readable format
format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        printf "%.1fKB" $(echo "scale=1; $bytes/1024" | bc 2>/dev/null || echo "$bytes/1024" | awk '{printf "%.1fKB", $1}')
    elif [ $bytes -lt 1073741824 ]; then
        printf "%.1fMB" $(echo "scale=1; $bytes/1048576" | bc 2>/dev/null || echo "$bytes/1048576" | awk '{printf "%.1fMB", $1}')
    else
        printf "%.1fGB" $(echo "scale=1; $bytes/1073741824" | bc 2>/dev/null || echo "$bytes/1073741824" | awk '{printf "%.1fGB", $1}')
    fi
}

RX_DISPLAY=$(format_bytes $TOTAL_RX)
TX_DISPLAY=$(format_bytes $TOTAL_TX)

echo "↓$RX_DISPLAY ↑$TX_DISPLAY"
