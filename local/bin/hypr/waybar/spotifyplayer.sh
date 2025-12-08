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

generate_json
# Monitor D-Bus signals for Mpris events
# This monitors both PlaybackStatus and Metadata changes, which is more reliable.
dbus-monitor --session "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',arg0='org.mpris.MediaPlayer2.Player'" | while read -r line; do
    # Only regenerate the JSON when a PropertiesChanged signal is detected
    if echo "$line" | grep -q "PropertiesChanged"; then
        generate_json
    fi
done