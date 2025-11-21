URL=''
ngrok http 5678 \
--domain=$URL > /tmp/ngrok-tunnel.log 2>&1 &
#--basic-auth="username:password"

TUNNEL_PID=$!

if [ -z "$TUNNEL_PID" ]; then
    echo "Could not run ngrok. Check /tmp/ngrok-tunnel.log"
    kill $TUNNEL_PID
    exit 1
fi

WEBHOOK_URL=$URL n8n start --host 0.0.0.0

kill $TUNNEL_PID
echo "ngrok stoped"
