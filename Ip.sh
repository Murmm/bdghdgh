#!/bin/bash

# Check if ngrok-agent is installed and in the PATH
if ! command -v ngrok &> /dev/null; then
    echo "Error: ngrok-agent is not installed or not in the PATH."
    echo "Please install ngrok-agent and ensure it's in the PATH."
    exit 1
fi

# Check if the minimum required version of ngrok-agent is installed
REQUIRED_VERSION="3.2.0"
CURRENT_VERSION=$(ngrok version | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+')
if ! [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$CURRENT_VERSION" | sort -V | head -n 1)" == "$REQUIRED_VERSION" ]]; then
    echo "Updating ngrok-agent to the latest version..."
    ngrok update
fi

# Fetch the SSH connection details from the ngrok log
SSH_CONNECTION=$(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $(jq -r '.inputs.username' $GITHUB_EVENT_PATH)@/" | sed "s/:/ -p /")

if [ -z "$SSH_CONNECTION" ]; then
    # Check for errors in the ngrok log
    ERROR=$(grep "command failed" < .ngrok.log)
    if [[ "$ERROR" == *"Your ngrok-agent version"* ]]; then
        echo "$ERROR"
        exit 4
    else
        echo "Error: Failed to fetch the SSH connection details."
        exit 1
    fi
else
    echo "$SSH_CONNECTION"
fi
