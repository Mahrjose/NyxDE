#! /usr/bin/env bash

getWeatherIcon() {

    # getWeatherIcon: Returns the appropriate emoji for a given weather icon code.
    # Arguments:
    #   iconCode: The weather icon code (required)
    # Returns:
    #   A string containing the corresponding weather emoji.

    local iconCode="$1"

    case "$iconCode" in
    "01d") echo "☀️" ;;         # Clear sky (day)
    "01n") echo "🌑" ;;          # Clear sky (night)
    "02d") echo "🌤️" ;;         # Few clouds (day)
    "02n") echo "🌥️" ;;         # Few clouds (night)
    "03d" | "03n") echo "☁️" ;; # Scattered clouds
    "04d" | "04n") echo "🌥️" ;; # Broken clouds
    "09d" | "09n") echo "🌦️" ;; # Shower rain
    "10d" | "10n") echo "🌧️" ;; # Rain
    "11d" | "11n") echo "⛈️" ;; # Thunderstorm
    "13d" | "13n") echo "❄️" ;; # Snow
    "50d" | "50n") echo "🌫️" ;; # Mist
    *) echo "❓" ;;              # Unknown weather condition
    esac
}

getCountryName() {

    # getCountryName: Fetches the country name from the local JSON file based on the country code.
    # Arguments:
    #   countryCode: The ISO 3166-1 alpha-2 country code (required)
    # Returns:
    #   A string containing the corresponding country name.

    local countryName
    local countryCode="$1"

    countryName=$(jq -r --arg code "$countryCode" '.[] | select(.code == $code) | .name' ../utils/country-info.json)

    echo "$countryName"
}

getFlagEmoji() {

    # getFlagEmoji: Retrieves the emoji flag corresponding to a country code from the local JSON file.
    # Arguments:
    #   countryCode: The ISO 3166-1 alpha-2 country code (required)
    # Returns:
    #   A string containing the corresponding flag emoji.

    local flag
    local countryCode="$1"

    flag=$(jq -r --arg code "$countryCode" '.[] | select(.code == $code) | .flag' ../utils/country-info.json)

    echo "$flag"
}

getDirectionEmoji() {

    # getDirectionEmoji: Converts a degree value to a corresponding directional emoji.
    # Arguments:
    #   degree: The degree of the direction (0-360) (required)
    # Returns:
    #   A string containing the corresponding directional emoji.

    local degree="$1"
    local emoji

    # Mapping wind degree to directional emoji
    if ((degree >= 0 && degree <= 22)) || ((degree > 337 && degree <= 360)); then
        emoji="⬆️" # North
    elif ((degree > 22 && degree <= 67)); then
        emoji="↗️" # North-East
    elif ((degree > 67 && degree <= 112)); then
        emoji="➡️" # East
    elif ((degree > 112 && degree <= 157)); then
        emoji="↘️" # South-East
    elif ((degree > 157 && degree <= 202)); then
        emoji="⬇️" # South
    elif ((degree > 202 && degree <= 247)); then
        emoji="↙️" # South-West
    elif ((degree > 247 && degree <= 292)); then
        emoji="⬅️" # West
    elif ((degree > 292 && degree <= 337)); then
        emoji="↖️" # North-West
    else
        emoji="❓" # Unknown direction
    fi

    echo "$emoji"
}
