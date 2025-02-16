#!/bin/bash

# screen -dmS h1-enum bash -c "bash init.sh" && cd ../bc/
# screen -dmS bc-enum bash -c "bash init.sh" && cd ../in/
# screen -dmS in-enum bash -c "bash init.sh" && cd ../h1/

SCRIPT="./script.sh"
LAST_MODIFIED=""
current_path=$(pwd)
fourth_component=$(echo $current_path | cut -d'/' -f5)
NOTIFY_ID=$fourth_component

while true; do
    # Check if the script exists
    if [[ ! -f "$SCRIPT" ]]; then
        echo "Error: $SCRIPT not found!"
        exit 1
    fi

    # Get the last modified time
    CURRENT_MODIFIED=$(stat -c %Y "$SCRIPT")
    if [[ "$CURRENT_MODIFIED" != "$LAST_MODIFIED" ]]; then
        echo "Changes detected in Phantom Sight. Reloading..."
        source "$SCRIPT" || { echo "Error: Failed to source $SCRIPT"; exit 1; }
        LAST_MODIFIED="$CURRENT_MODIFIED"
        echo "Updated and sourced Phantom Sight successfully."
    fi

    # Check if the main function exists
    if ! declare -f main > /dev/null; then
        echo "Error: main function not found in $SCRIPT"
        exit 1
    fi

    # Run the main function
    echo "Starting the main function..."
    main &
    PID=$!
    wait $PID
    sleep 1800
done
