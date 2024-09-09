#!/usr/bin/env bash

getWeather() {

    # getWeather: Fetches weather data for a location using city information or coordinates.
    # It determines the location type, constructs an API request, and formats the weather data.
    # Arguments:
    #   --city, --state, --country : Location parameters for city/state/country.
    #   --lat, --lon               : Geographic coordinates (latitude/longitude).
    # Returns:
    #   None

    local locationInfo
    local latitude
    local longitude
    local currentTime

    currentTime=$(date +"%I:%M %p")

    if [ "$1" == "--city" ]; then
        locationInfo="$(getLocation --by-city "$@")"
    else
        locationInfo="$(getLocation --by-coordinates "$@")"
    fi

    latitude="$(jq -r '.lat' <<<"${locationInfo}")"
    longitude="$(jq -r '.lon' <<<"${locationInfo}")"

    local hourlyForecast
    local multiDayForecast
    local location

    location="$(jq -r '.name' <<<"$locationInfo")"
    hourlyForecast=$(getWeatherForecast --hourly "$location")
    multiDayForecast=$(getWeatherForecast --multidays "$location")

    local url
    local response

    url="https://api.openweathermap.org/data/2.5/weather?lat={$latitude}&lon={$longitude}&units=metric&appid={$OPENWEATHER_APIKEY}"
    response=$(curl -s "${url}" | jq .)

    formatData "$response" "$locationInfo" "$hourlyForecast" "$multiDayForecast" "$currentTime"
}

getWeatherByCoordinates() {

    # getWeatherByCoordinates: Fetches weather data using geographic coordinates.
    # Parses latitude and longitude from the command-line arguments and retrieves the weather.
    # Defaults to a specific location if coordinates are not provided.
    # Arguments:
    #   --lat : Latitude value  (required, defaults to 23.543).
    #   --lon : Longitude value (required, defaults to 89.626).
    # Returns:
    #   None

    local latitude=""
    local longitude=""

    while [[ $# -gt 0 ]]; do

        case "$1" in
        --lat)
            [ -z "${latitude}" ] && latitude="$2"
            shift 2
            ;;
        --lon)
            [ -z "${longitude}" ] && longitude="$2"
            shift 2
            ;;
        --city | --state | --country)
            echo "Please use either location parameters (--city, --state, --country) or coordinate parameters (--lat, --lon), but not both." >&2
            exit 1
            ;;
        *)
            echo "Unknown option \"$1\"" >&2
            exit 1
            ;;
        esac
    done

    if [ -z "$latitude" ] || [ -z "$longitude" ]; then
        echo "Warning: either --lat or --lon missing. Defaulting to --lat 23.543 --lon 89.626 (Madhukhali)" >&2
        latitude="23.543"
        longitude="89.626" # Madhukhali Corodinates
    fi

    getWeather --lat "$latitude" --lon "$longitude"
}

getWeatherByCity() {

    # getWeatherByCity: Fetches weather data using city, state, and country information.
    # Parses the city, state, and country from command-line arguments. Defaults to Madhukhali, Bangladesh if not provided.
    # Arguments:
    #   --city    : Name of the city    (required, defaults to Madhukhali).
    #   --state   : Name of the state   (optional, defaults to Null).
    #   --country : Name of the country (optional, defaults to Bangladesh).
    # Returns:
    #   None

    local city=""
    local state=""
    local country=""

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
        --lon | --lat)
            echo "Please use either location parameters (--city, --state, --country) or coordinate parameters (--lat, --lon), but not both." >&2
            exit 1
            ;;

        *)
            echo "Unknown option \"$1\"" >&2
            exit 1
            ;;
        esac
    done

    # Set default values if not provided
    if [ -z "$city" ]; then
        echo "Warning: --city is required and not given. Defaulting to --city Madhukhali --country Bangladesh" >&2
        city="Madhukhali"
        country="Bangladesh"
    fi

    # Call the function to fetch daily weather with the resolved arguments
    getWeather --city "$city" --state "$state" --country "$country"

}

main() {

    # main: The main entry point of the script.
    # Loads the API key, processes user input, and calls appropriate functions to fetch
    # weather data based on city/state/country or coordinates.
    # Arguments:
    #   Group 1: Location by city/state/country
    #     --city    : Name of the city    (required, defaults to Madhukhali).
    #     --state   : Name of the state   (optional, defaults to Null).
    #     --country : Name of the country (optional, defaults to Bangladesh).
    #   Group 2: Location by coordinates
    #     --lat     : Latitude coordinate  (required, defaults to 23.543).
    #     --lon     : Longitude coordinate (required, defaults to 89.626).
    # Returns:
    #   None

    local ENV_FILE="../../.env"

    # Load APIKEY from `.env` file
    if [ -f $ENV_FILE ]; then
        source ../../.env
    else
        echo "Error: .env file not found or APIKEY not set." >&2
        return 1
    fi

    # Includes -> generateDynamicMessage()
    source generate-weather-messages.sh

    # Includes -> getLocation()
    source get-location.sh

    # Includes -> getFlagEmoji(), getCountryName(), getWeatherIcon(), getDirectionEmoji()
    source weather-utils.sh

    # Includes -> hourlyWeatherForecast(), multiDayWeatherForecast(), getWeatherForecast()
    source weather-forecast.sh

    # Includes -> formatInfo()
    source format-data.sh

    local city=""
    local state=""
    local country=""

    local latitude=""
    local longitude=""

    # Parse command-line arguments
    if [ "$1" == "--lat" ] || [ "$1" == "--lon" ]; then
        getWeatherByCoordinates "$@"

    elif [ "$1" == "--city" ] || [ "$1" == "--state" ] || [ "$1" == "--country" ]; then
        getWeatherByCity "$@"

    else
        echo "Warning: No arguments provided. Defaulting to --city Madhukhali --country Bangladesh" >&2
        getWeatherByCity --city "Madhukhali" --country "Bangladesh"
    fi
}

main "$@"
