#!/bin/bash

# A key function that generates the Waybar JSON output
generate_json() {
    PLAYER="playerctl -p spotify"

    player_status=$($PLAYER status 2> /dev/null)

    if [ "$player_status" == "Playing" ] || [ "$player_status" == "Paused" ]; then
        artist=$($PLAYER metadata artist 2> /dev/null)
        title=$($PLAYER metadata title 2> /dev/null)
        player_name=$($PLAYER metadata --format '{{playerName}}' 2> /dev/null)
        
        # Sanitization
        artist=$(echo "$artist" | sed 's/[\\"]/\\&/g;s/&/&amp;/g')
        title=$(echo "$title" | sed 's/[\\"]/\\&/g;s/&/&amp;/g')

        # Determine class
        if [ "$player_status" == "Playing" ]; then
            class="playing"
            icon=" "
        else
            class="paused"
            icon=" "
        fi

        text="$artist - $title"
        
        # Output the JSON
        echo "{\"text\": \" $icon $text\", \"tooltip\": \"$player_name: $artist - $title\", \"class\": \"$class\"}"
    else
        # No player running
        echo "{\"text\": \"\", \"class\": \"hidden\"}"
    fi
}

# Initial output on Waybar start
generate_json

# Start monitoring playerctl for changes
# The `--follow` flag makes playerctl block until an event occurs (e.g., play/pause/new track).
# When an event happens, it prints the player status, triggering the loop to continue.
playerctl --follow status 2> /dev/null | while read -r status; do
    generate_json
done