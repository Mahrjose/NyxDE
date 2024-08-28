#!/usr/bin/env bash

# Fetches the weather information and processes the data.
#
# Parameters:
# - $1: The location query (e.g., "New+York").
#
# Returns:
# - Outputs a JSON string with weather text and tooltip information.
# - Returns 0 on success, 1 on failure.

getWeather() {
    local location="$1"

    # Fetch the simple weather text
    local weatherText
    weatherText=$(curl -s "https://wttr.in/$location?format=1")

    if [[ $? -ne 0 ]]; then
        return 1
    fi

    # Clean up the weather text by removing extra spaces and the '+' sign
    weatherText=$(echo "$weatherText" | sed -E "s/\s+/ /g" | sed 's/+//')

    # Fetch the detailed weather tooltip
    local weatherTooltip
    weatherTooltip=$(curl -s "https://wttr.in/$location?format=4")

    if [[ $? -ne 0 ]]; then
        return 1
    fi

    # Clean up the tooltip, remove the second '+' sign, and format the location
    weatherTooltip=$(echo "$weatherTooltip" | sed -E "s/\s+/ /g" | sed 's/+//2')
    local formattedLocation
    formattedLocation=$(echo "$location" | sed 's/\+/, /g')
    weatherTooltip=$(echo "$weatherTooltip" | sed "s/$location/$formattedLocation/")

    # Output the JSON with weather text and tooltip
    echo "{\"text\":\"$weatherText\", \"tooltip\":\"$weatherTooltip\"}"
    return 0
}

# Main function to orchestrate the script's logic
main() {
    local location="$1"

    # Try fetching the weather information up to 5 times
    for i in {1..5}; do
        getWeather "$location" && exit 0
        sleep 2
    done

    # If all attempts fail, return an error message
    echo "{\"text\":\" N/A\", \"tooltip\":\"N/A\"}"
    exit 1
}

# Check if location is provided as a parameter
if [[ -z "$1" ]]; then
    echo "Error: Location not provided." >&2
    exit 1
fi

# Call the main function with the provided location
main "$1"
