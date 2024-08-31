#!/usr/bin/env bash

formatData() {

    # formatData: Formats and prepares weather information for display.
    # Extracts and formats details such as location, temperature, wind, and more.
    # Arguments:
    #   json         : JSON data containing weather details (required)
    #   locationInfo : JSON data containing location information (required)
    # Returns:
    #   JSON string with formatted weather text and tooltip for display.

    local locationInfo="$2" # Json data, includes city, lat, lon, country, state
    local json="$1"         # Json data, includes various weather info

    # --------------------------------------------------------------------- #
    # Extract and format location data (latitude, longitude, city, country) #
    # ----------------------------------------------------------------------#

    local lat
    local lon
    lat=$(printf "%.3f" "$(jq -r '.lat' <<<"$locationInfo")")
    lon=$(printf "%.3f" "$(jq -r '.lon' <<<"$locationInfo")")

    local city
    local country
    local flag
    city=$(jq -r '.name' <<<"$locationInfo")
    country=$(getCountryName "$(jq -r '.sys.country' <<<"$json")")
    flag=$(getFlagEmoji "$(jq -r '.sys.country' <<<"$json")")

    # ----------------------------------------------------------------------#
    #         Extract and format temperature and weather description        #
    # ----------------------------------------------------------------------#

    local temperature
    local feelsLike
    local tempMin
    local tempMax
    local weatherDescription
    temperature=$(printf "%.1f" "$(jq -r '.main.temp' <<<"$json")")
    feelsLike=$(printf "%.1f" "$(jq -r '.main.feels_like' <<<"$json")")
    tempMin=$(printf "%.1f" "$(jq -r '.main.temp_min' <<<"$json")")
    tempMax=$(printf "%.1f" "$(jq -r '.main.temp_max' <<<"$json")")
    weatherDescription=$(jq -r '.weather[0].description' <<<"$json")

    # ----------------------------------------------------------------------#
    #  Extract and format wind data (speed, direction, gusts) and humidity  #
    # ----------------------------------------------------------------------#

    local humidity
    local windSpeed
    local windDirection
    local windGusts
    humidity=$(jq -r '.main.humidity' <<<"$json")
    windSpeed=$(jq -r '.wind.speed' <<<"$json")
    windDirection=$(getDirectionEmoji "$(jq -r '.wind.deg' <<<"$json")")
    windGusts=$(jq -r '.wind.gust // 0' <<<"$json")

    # ----------------------------------------------------------------------------------#
    # Extract and format additional weather details (pressure, cloud cover, visibility) #
    # ----------------------------------------------------------------------------------#

    local pressure
    local cloudCover
    local visibility
    pressure=$(jq -r '.main.pressure' <<<"$json")
    cloudCover=$(jq -r '.clouds.all' <<<"$json")
    visibility=$(($(jq -r '.visibility' <<<"$json") / 1000)) # Convert meters to km

    # ----------------------------------------------------------------------#
    #             Extract and format sunrise and sunset times               #
    # ----------------------------------------------------------------------#

    local sunrise
    local sunset
    sunrise=$(jq -r '.sys.sunrise' <<<"$json")
    sunset=$(jq -r '.sys.sunset' <<<"$json")

    # ----------------------------------------------------------------------#
    #     Determine appropriate weather icon and construct display text     #
    # ----------------------------------------------------------------------#

    local icon
    local text
    local iconCode
    iconCode=$(jq -r '.weather[0].icon' <<<"$json")
    icon=$(getWeatherIcon "$iconCode")
    text="$icon ${temperature}°C"

    # ----------------------------------------------------------------------#
    #        Generate a dynamic message based on weather conditions         #
    # ----------------------------------------------------------------------#

    local weatherID
    local message
    weatherID=$(jq -r '.weather[0].id' <<<"$json")
    message=$(generateDynamicMessage "$temperature" "$feelsLike" "$weatherID")

    # ----------------------------------------------------------------------#
    #              Construct tooltip with all formatted data                #
    # ----------------------------------------------------------------------#

    local toolTip
    toolTip="\
    \n\
    📍 Location: ${city}, $country $flag (${lat}, $lon)\n\
    \n\
    🌡️ Current Weather: ${temperature}°C | ${weatherDescription^}\n\
        🔥 Feels Like: ${feelsLike}°C\n\
        🔼 High: ${tempMax}°C, 🔽 Low: ${tempMin}°C\n\
    \n\
    📊 Additional Details:          \n\
        💧 Humidity   : ${humidity}%   \n\
        🌬️ Wind       : ${windSpeed} km/h | Direction ${windDirection}   \n\
        🌪️ Wind Gusts : ${windGusts} km/h    \n\
        ☁️ Cloud      : ${cloudCover}%      \n\
        👀 Visibility : ${visibility} km     \n\
        📊 Pressure   : ${pressure} hPa        \n\
    \n\
    🌅 Sunrise: $(date -d @$sunrise +'%I:%M %p') 🌄 | Sunset: $(date -d @$sunset +'%I:%M %p') 🌃    \n\
    \n\
    $message \n\
    "

    # Return the final JSON string with formatted text and tooltip
    echo "{\"text\":\"$text\", \"tooltip\":\"$toolTip\"}"
}

weatherForecast() {

    #!!! TODO: Find a free forecast API. Openweather API don't support this in free plan.
    pass
}

dailyWeather() {

    # dailyWeather: Fetches daily weather information for a given city.
    # Arguments:
    #   --city    : Name of the city    (required)
    #   --state   : Name of the state   (optional)
    #   --country : Name of the country (optional)
    # Returns:
    #   JSON containing various information related to weather forecast for 'today'

    local locationInfo
    local latitude
    local longitude

    locationInfo="$(getLocation "$@")"
    latitude="$(jq '.lat' <<<"${locationInfo}")"
    longitude="$(jq '.lon' <<<"${locationInfo}")"

    local url
    local response

    url="https://api.openweathermap.org/data/2.5/weather?lat={$latitude}&lon={$longitude}&units=metric&appid={$APIKEY}"
    response=$(curl -s "${url}" | jq .)
    formatData "$response" "$locationInfo"
}

main() {

    # main: Entry point of the script to fetch weather information.
    # Loads the API key, sets default values, and calls weather functions.
    # Arguments:
    #   --city    : Name of the city    (optional, defaults to Dhaka if not provided)
    #   --state   : Name of the state   (optional)
    #   --country : Name of the country (optional, defaults to Bangladesh if not provided)
    # Returns:
    #   None

    # Load APIKEY from `.env` file
    if [ -f ../.env ]; then
        export $(cat ../.env | xargs)
    else
        echo "Error: .env file not found or APIKEY not set." >&2
        return 1
    fi

    # Includes -> generateDynamicMessage()
    source ./weather-scripts/generate-weather-messages.sh

    # Includes -> getLocation()
    source ./weather-scripts/get-location.sh

    # Includes -> getFlagEmoji(), getCountryName(), getWeatherIcon(), getDirectionEmoji()
    source ./weather-scripts/weather-utils.sh

    local city=""
    local state=""
    local country=""

    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --city)
            city="$2"
            shift 2
            ;;
        --state)
            state="$2"
            shift 2
            ;;
        --country)
            country="$2"
            shift 2
            ;;
        *)
            echo "Unknown option \"$1\"" >&2
            exit 1
            ;;
        esac
    done

    # Set default values if not provided
    if [ -z "$city" ]; then
        echo "Warning: --city is required and not given. Defaulting to --city Dhaka --country Bangladesh" >&2
        city="Dhaka"
        country="Bangladesh"
    fi

    # Call the function to fetch daily weather with the resolved arguments
    dailyWeather --city "$city" --state "$state" --country "$country"
}

main "$@"
