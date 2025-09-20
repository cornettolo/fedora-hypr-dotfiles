#!/bin/bash

# Get a list of all open windows using hyprctl clients
selected_window=$(
  hyprctl clients |
    grep -E 'title:|class:|address:' |
    awk -F': ' '
      {
        if ($1 == "Window") {
          address = $2
        } else if ($1 == "title") {
          title = $2
        } else if ($1 == "class") {
          class = $2
          if (address != "" && class != "" && title != "") {
            # You can add more classes to this condition if you find they cause problems
            # if (class != "your_class_to_exclude" && title !~ /your_title_to_exclude/i) {
            #    print address " | " class " | " title
            # }
            # To show all windows, just use the print statement directly
            print address " | " class " | " title
          }
          address = ""
          class = ""
          title = ""
        }
      }
    ' |
  rofi -dmenu -i -p "Switch to:"
)

# Check if a window was selected
if [[ ! -z "$selected_window" ]]; then
  # Extract the window address from the Rofi output
  address=$(echo "$selected_window" | awk -F' | ' '{print $1}')
  
  # Focus the selected window using its address
  hyprctl dispatch focuswindow address:"$address"
fi