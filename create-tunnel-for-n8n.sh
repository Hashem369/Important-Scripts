#!/bin/bash

echo "Starting Cloudflare Tunnel in the background..."

# Start the tunnel in the background, redirecting all output to a file
cloudflared tunnel --url http://127.0.0.1:5678 > /tmp/tunnel.log 2>&1 &
TUNNEL_PID=$!

echo "Waiting for URL to be available..."
sleep 10 # Give it a moment to start

# Extract the URL from the log file
TUNNEL_URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' /tmp/tunnel.log | head -n 1)

if [ -z "$TUNNEL_URL" ]; then
    echo "Could not retrieve tunnel URL. Check /tmp/tunnel.log"
    kill $TUNNEL_PID
    exit 1
fi

echo "Tunnel URL is: $TUNNEL_URL"

# Now use the URL to start n8n
echo "Starting n8n with the webhook URL..."
WEBHOOK_URL=$TUNNEL_URL n8n start --host 0.0.0.0

# When n8n stops, clean up by killing the tunnel
echo "Stopping n8n and the tunnel."
kill $TUNNEL_PID
