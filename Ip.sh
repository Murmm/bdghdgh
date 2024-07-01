_ERR=$(grep "command failed" < .ngrok.log)

if [[ -z "$_ERR" ]]; then
    echo $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $(jq -r '.inputs.username' $GITHUB_EVENT_PATH)@/" | sed "s/:/ -p /")
else
    if [[ "$_ERR" = *"Your ngrok-agent version"* ]]; then
        echo "Updating ngrok-agent to the latest version..."
        ngrok update
        _ERR=$(grep "command failed" < .ngrok.log)
        if [[ -z "$_ERR" ]]; then
            echo $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $(jq -r '.inputs.username' $GITHUB_EVENT_PATH)@/" | sed "s/:/ -p /")
        else
            echo "$_ERR"
            exit 4
        fi
    else
        echo "$_ERR"
        exit 4
    fi
fi
