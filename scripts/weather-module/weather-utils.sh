#! /usr/bin/env bash

getWeatherIcon() {

    # getWeatherIcon: Returns an emoji representation of the current weather based on the provided icon code.
    # The icon code is typically provided by weather APIs.
    # Arguments:
    #   iconCode: The weather icon code (required), usually a string like "01d", "02n", etc.
    # Returns:
    #   A string containing the corresponding weather emoji based on the icon code.

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

    # getCountryName: Retrieves the country name corresponding to the provided ISO country code.
    # Looks up a local JSON file for the mapping of country codes to names.
    # Arguments:
    #   countryCode: The ISO 3166-1 alpha-2 country code (required), such as "US", "GB", etc.
    # Returns:
    #   A string containing the full country name corresponding to the given code.

    local countryName
    local countryCode="$1"

    countryName=$(jq -r --arg code "$countryCode" '.[] | select(.code == $code) | .name' ../../utils/country-info.json)

    echo "$countryName"
}

getFlagEmoji() {

    # getFlagEmoji: Returns the flag emoji corresponding to a given country code.
    # It looks up the country code in a local JSON file to find the associated flag emoji.
    # Arguments:
    #   countryCode: The ISO 3166-1 alpha-2 country code (required), such as "US", "FR", etc.
    # Returns:
    #   A string containing the flag emoji for the corresponding country.

    local flag
    local countryCode="$1"

    flag=$(jq -r --arg code "$countryCode" '.[] | select(.code == $code) | .flag' ../../utils/country-info.json)

    echo "$flag"
}

getDirectionEmoji() {

    # getDirectionEmoji: Converts a wind degree value into the corresponding directional emoji.
    # The degree represents the direction of the wind (0°-360°), which is then mapped to directional emojis.
    # Arguments:
    #   degree: The wind direction degree (required), a number between 0 and 360.
    # Returns:
    #   A string containing the directional emoji corresponding to the given degree.

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
