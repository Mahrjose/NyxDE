#!/usr/bin/env bash

# Format the location to replace '+' with ', '
location=$(echo "$1" | sed 's/\+/, /g')

for i in {1..5}
do
    # Get the weather text
    text=$(curl -s "https://wttr.in/$1?format=1")
    if [[ $? == 0 ]]
    then
        # Remove the + sign from the temperature
        text=$(echo "$text" | sed -E "s/\s+/ /g" | sed 's/+//')
        
        # Get the tooltip with detailed weather info
        tooltip=$(curl -s "https://wttr.in/$1?format=4")
        if [[ $? == 0 ]]
        then
            # Replace the location format and remove the + sign in tooltip
            tooltip=$(echo "$tooltip" | sed -E "s/\s+/ /g" | sed 's/+//2')
            tooltip=$(echo "$tooltip" | sed "s/$1/$location/")
            echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
            exit
        fi
    fi
    sleep 2
done

# Return an error if the weather information cannot be retrieved
echo "{\"text\":\" N/A\", \"tooltip\":\"N/A\"}"
