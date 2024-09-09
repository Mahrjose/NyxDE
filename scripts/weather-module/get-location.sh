#! /usr/bin/env bash

getLocation() {

    # getLocation: Fetches geographical location data based on either city/state/country information or latitude/longitude coordinates.
    #
    # Arguments:
    #   --by-city        : Use city/state/country to retrieve location data.
    #     --city         : Name of the city (required when using --by-city).
    #     --state        : Name of the state (optional).
    #     --country      : Name of the country (optional).
    #   --by-coordinates : Use latitude/longitude to retrieve location data.
    #     --lat          : Latitude coordinate (required when using --by-coordinates).
    #     --lon          : Longitude coordinate (required when using --by-coordinates).
    #
    # Returns:
    #   A JSON object containing location data, including the name, latitude, longitude, state (if available), and country.
    #
    # Notes:
    #   The function makes a request to the OpenWeatherMap API to retrieve the location data based on the provided arguments.
    #   If an invalid or unsupported argument is provided, it returns an error message.

    if [ "$1" == "--by-city" ]; then

        local city=""
        local state=""
        local country=""

        shift 1

        while [[ $# -gt 0 ]]; do
            case $1 in
            --city)
                city=$2
                shift 2
                ;;
            --state)
                state=$2
                shift 2
                ;;
            --country)
                country=$2
                shift 2
                ;;
            esac
        done

        # Build URL based on available parameters
        local url="http://api.openweathermap.org/geo/1.0/direct?q=${city}"
        [[ -n "$state" ]] && url+=",${state}"
        [[ -n "$country" ]] && url+=",${country}"
        url+="&limit=5&appid=${OPENWEATHER_APIKEY}"

    elif [ "$1" == "--by-coordinates" ]; then

        shift 1

        local latitude="$2"
        local longitude="$4"

        local url
        local limit=5

        url="http://api.openweathermap.org/geo/1.0/reverse?lat=${latitude}&lon=${longitude}&limit=${limit}&appid=${OPENWEATHER_APIKEY}"

    else
        echo "Error: wrong argument, use either --by-city or --by-coordinate as first argument (\$1)" >&2
        return 1
    fi

    # Fetch and process the response
    local response
    local httpStatusCode
    local responseBody
    local location

    response=$(curl -s -w "%{http_code}" "${url}")
    httpStatusCode="${response: -3}"
    responseBody="${response%???}"

    if [[ $httpStatusCode -ne 200 ]]; then
        echo "Error: Failed to fetch location (HTTP status code $httpStatusCode)" >&2
        return 1
    fi

    location=$(jq '.[0] | { name: .name, lat: .lat, lon: .lon, state: .state, country: .country }' <<<"${responseBody}")
    echo "$location"
}
